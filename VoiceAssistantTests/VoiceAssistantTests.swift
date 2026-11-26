//
//  VoiceAssistantTests.swift
//  VoiceAssistantTests
//
//  Created by Osama Hasan on 11/02/2024.
//

import XCTest
import AVFoundation
import Speech
@testable import VoiceAssistant

private final class MockSpeechAudioSession: SpeechAudioSessionControlling {
    var category: AVAudioSession.Category = .ambient
    var isInputAvailable: Bool = true
    var recordPermission: AVAudioSession.RecordPermission = .granted
    var setCategoryError: Error?
    var setActiveError: Error?
    var setActiveCalls: [Bool] = []
    var holdActivationCompletion = false
    var onActivationRequested: (() -> Void)?
    private var pendingActivationCompletion: ((Bool) -> Void)?

    func setCategory(_ category: AVAudioSession.Category) throws {
        if let setCategoryError {
            throw setCategoryError
        }
        self.category = category
    }

    func setSessionActive(_ active: Bool, completion: @escaping (Bool) -> Void) {
        setActiveCalls.append(active)
        if holdActivationCompletion {
            pendingActivationCompletion = completion
            onActivationRequested?()
            return
        }
        if setActiveError != nil {
            completion(false)
            return
        }
        completion(true)
    }

    func completePendingActivation(success: Bool) {
        let completion = pendingActivationCompletion
        pendingActivationCompletion = nil
        completion?(success)
    }

    func requestRecordPermission(_ response: @escaping (Bool) -> Void) {
        response(recordPermission == .granted)
    }
}

private final class MockSpeechToTextDelegate: SpeechToTextDelegate {
    var finishRecordingCallCount = 0
    var onFinishRecording: (() -> Void)?
    var recognizedFinalTexts: [String] = []

    func speechToTextDidStartRecognition() {}
    func speechToText(didRecognizeText text: String) {}
    func speechToText(didFinishWithText text: String) {
        recognizedFinalTexts.append(text)
    }
    func speechToText(updateVoicePowerInDB dbPower: Float) {}
    func speechToTextFinishRecording() {
        finishRecordingCallCount += 1
        onFinishRecording?()
    }
}

private final class MockTTSAudioSession: TextToSpeechAudioSessionControlling {
    var categoriesSet: [AVAudioSession.Category] = []
    var setCategoryCalledOnMainThread: [Bool] = []
    var onSetCategory: (() -> Void)?

    func setCategory(_ category: AVAudioSession.Category) throws {
        categoriesSet.append(category)
        setCategoryCalledOnMainThread.append(Thread.isMainThread)
        onSetCategory?()
    }
}

final class VoiceAssistantTests: XCTestCase {

    func testInvalidZeroSampleRateFormatIsRejected() {
        let zeroSampleRateFormat = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: 0,
            channels: 2,
            interleaved: false
        )
        XCTAssertNotNil(zeroSampleRateFormat)
        XCTAssertFalse(SpeechToTextManager.isValidRecordingFormat(zeroSampleRateFormat!))

        let validFormat = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: 44100,
            channels: 1,
            interleaved: false
        )
        XCTAssertNotNil(validFormat)
        XCTAssertTrue(SpeechToTextManager.isValidRecordingFormat(validFormat!))
    }

    func testStartAbortsCleanlyWhenAudioSessionActivationFailsWithInsufficientPriority() {
        let mockSession = MockSpeechAudioSession()
        mockSession.setActiveError = NSError(
            domain: NSOSStatusErrorDomain,
            code: Int(AVAudioSession.ErrorCode.insufficientPriority.rawValue)
        )
        let delegate = MockSpeechToTextDelegate()
        let finishExpectation = expectation(description: "finish recording notified after async activation failure")
        delegate.onFinishRecording = {
            finishExpectation.fulfill()
        }
        let manager = SpeechToTextManager(
            audioSession: mockSession,
            speechAuthorizationStatusProvider: { .authorized }
        )
        manager.delegate = delegate

        manager.start()
        XCTAssertTrue(manager.isStarting)

        wait(for: [finishExpectation], timeout: 2.0)

        XCTAssertFalse(manager.isStarting)
        XCTAssertFalse(manager.isRecording)
        XCTAssertEqual(mockSession.setActiveCalls, [true])
        XCTAssertEqual(delegate.finishRecordingCallCount, 1)
    }

    func testStartAbortsCleanlyWhenNoAudioInputIsAvailable() {
        let mockSession = MockSpeechAudioSession()
        mockSession.isInputAvailable = false
        let delegate = MockSpeechToTextDelegate()
        let finishExpectation = expectation(description: "finish recording notified when no audio input is available")
        delegate.onFinishRecording = {
            finishExpectation.fulfill()
        }
        let manager = SpeechToTextManager(
            audioSession: mockSession,
            speechAuthorizationStatusProvider: { .authorized }
        )
        manager.delegate = delegate

        manager.start()

        wait(for: [finishExpectation], timeout: 2.0)

        XCTAssertFalse(manager.isStarting)
        XCTAssertFalse(manager.isRecording)
        XCTAssertEqual(delegate.finishRecordingCallCount, 1)
    }

    func testStopWhileAsyncActivationIsPendingCancelsStart() {
        let mockSession = MockSpeechAudioSession()
        mockSession.holdActivationCompletion = true
        mockSession.isInputAvailable = false
        let activationRequested = expectation(description: "activation requested")
        mockSession.onActivationRequested = {
            DispatchQueue.main.async {
                activationRequested.fulfill()
            }
        }
        let delegate = MockSpeechToTextDelegate()
        let manager = SpeechToTextManager(
            audioSession: mockSession,
            speechAuthorizationStatusProvider: { .authorized }
        )
        manager.delegate = delegate

        manager.start()
        XCTAssertTrue(manager.isStarting)
        wait(for: [activationRequested], timeout: 2.0)

        manager.simulateStopWithoutSubmittingForTesting()
        XCTAssertFalse(manager.isStarting)
        XCTAssertFalse(manager.isRecording)
        XCTAssertEqual(delegate.finishRecordingCallCount, 1)

        mockSession.completePendingActivation(success: true)
        let settleExpectation = expectation(description: "late activation callback settled")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            settleExpectation.fulfill()
        }
        wait(for: [settleExpectation], timeout: 2.0)

        XCTAssertFalse(manager.isStarting)
        XCTAssertFalse(manager.isRecording)
        XCTAssertEqual(delegate.finishRecordingCallCount, 1)
    }

    func testStartAbortsWithoutActivatingSessionWhenMicPermissionNotGranted() {
        let mockSession = MockSpeechAudioSession()
        mockSession.recordPermission = .denied
        let delegate = MockSpeechToTextDelegate()
        let manager = SpeechToTextManager(
            audioSession: mockSession,
            speechAuthorizationStatusProvider: { .authorized }
        )
        manager.delegate = delegate

        manager.start()

        XCTAssertFalse(manager.isRecording)
        XCTAssertTrue(mockSession.setActiveCalls.isEmpty)
        XCTAssertEqual(delegate.finishRecordingCallCount, 1)
    }

    func testStopForFinalTranscriptionPreservesIsRecordingAndExecutesCommand() {
        let mockSession = MockSpeechAudioSession()
        let delegate = MockSpeechToTextDelegate()
        let manager = SpeechToTextManager(
            audioSession: mockSession,
            speechAuthorizationStatusProvider: { .authorized }
        )
        manager.delegate = delegate

        manager.simulateActiveRecordingForTesting()
        manager.simulateSilenceTimerStopForTesting()

        XCTAssertTrue(manager.isRecording)
        XCTAssertEqual(delegate.finishRecordingCallCount, 1)

        manager.simulateFinalTranscriptionForTesting("book a flight to London")

        XCTAssertEqual(delegate.recognizedFinalTexts, ["book a flight to London"])
        XCTAssertFalse(manager.isRecording)
    }

    func testInterruptionClearsIsRecordingSoLateFinalResultDoesNotExecuteCommand() {
        let mockSession = MockSpeechAudioSession()
        let delegate = MockSpeechToTextDelegate()
        let manager = SpeechToTextManager(
            audioSession: mockSession,
            speechAuthorizationStatusProvider: { .authorized }
        )
        manager.delegate = delegate

        manager.simulateActiveRecordingForTesting()
        manager.simulateStopWithoutSubmittingForTesting()

        XCTAssertFalse(manager.isRecording)

        manager.simulateFinalTranscriptionForTesting("ignored text")

        XCTAssertTrue(delegate.recognizedFinalTexts.isEmpty)
    }

    func testTextToSpeechSetsSpeechCategoryOffMainThread() {
        let mockTTSSession = MockTTSAudioSession()
        let categoryConfigured = expectation(description: "TTS setCategory runs off main thread")
        mockTTSSession.onSetCategory = {
            categoryConfigured.fulfill()
        }
        let ttsManager = TextToSpeechManeger(audioSession: mockTTSSession)

        ttsManager.setSessionCategoryForSpeechToText()

        wait(for: [categoryConfigured], timeout: 2.0)

        XCTAssertEqual(mockTTSSession.categoriesSet, [.playAndRecord])
        XCTAssertEqual(mockTTSSession.setCategoryCalledOnMainThread, [false])
    }

    func testTextToSpeechPlayURLSetsPlaybackCategoryOffMainThread() {
        let mockTTSSession = MockTTSAudioSession()
        let categoryConfigured = expectation(description: "TTS play(url:) setCategory runs off main thread")
        mockTTSSession.onSetCategory = {
            categoryConfigured.fulfill()
        }
        let ttsManager = TextToSpeechManeger(audioSession: mockTTSSession)

        ttsManager.play(url: URL(fileURLWithPath: "/tmp/nonexistent-tts-test.mp3"))

        wait(for: [categoryConfigured], timeout: 2.0)

        XCTAssertEqual(mockTTSSession.categoriesSet, [.playback])
        XCTAssertEqual(mockTTSSession.setCategoryCalledOnMainThread, [false])
    }

}
