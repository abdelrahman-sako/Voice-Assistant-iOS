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

    func setCategory(_ category: AVAudioSession.Category) throws {
        if let setCategoryError {
            throw setCategoryError
        }
        self.category = category
    }

    func setSessionActive(_ active: Bool) throws {
        setActiveCalls.append(active)
        if let setActiveError {
            throw setActiveError
        }
    }

    func requestRecordPermission(_ response: @escaping (Bool) -> Void) {
        response(recordPermission == .granted)
    }
}

private final class MockSpeechToTextDelegate: SpeechToTextDelegate {
    var finishRecordingCallCount = 0
    var recognizedFinalTexts: [String] = []

    func speechToTextDidStartRecognition() {}
    func speechToText(didRecognizeText text: String) {}
    func speechToText(didFinishWithText text: String) {
        recognizedFinalTexts.append(text)
    }
    func speechToText(updateVoicePowerInDB dbPower: Float) {}
    func speechToTextFinishRecording() {
        finishRecordingCallCount += 1
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
        let manager = SpeechToTextManager(
            audioSession: mockSession,
            speechAuthorizationStatusProvider: { .authorized }
        )
        manager.delegate = delegate

        manager.start()

        XCTAssertFalse(manager.isRecording)
        XCTAssertEqual(mockSession.setActiveCalls, [true])
        XCTAssertEqual(delegate.finishRecordingCallCount, 1)
    }

    func testStartAbortsCleanlyWhenNoAudioInputIsAvailable() {
        let mockSession = MockSpeechAudioSession()
        mockSession.isInputAvailable = false
        let delegate = MockSpeechToTextDelegate()
        let manager = SpeechToTextManager(
            audioSession: mockSession,
            speechAuthorizationStatusProvider: { .authorized }
        )
        manager.delegate = delegate

        manager.start()

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

}
