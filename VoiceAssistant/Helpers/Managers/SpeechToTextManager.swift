//
//  SpeechToTextManager.swift
//  Voice Assistant
//
//  Created by Osama Hasan on 15/01/2024.
//

import Foundation
import Speech
import UIKit

protocol SpeechToTextDelegate: AnyObject {
    func speechToTextDidStartRecognition()
    func speechToText(didRecognizeText text: String)
    func speechToText(didFinishWithText text: String)
    func speechToText(updateVoicePowerInDB dbPower: Float)
    func speechToText(didInstallBuffer buffer: AVAudioPCMBuffer)
    func speechToTextFinishRecording()
}

extension SpeechToTextDelegate {
    func speechToText(didInstallBuffer buffer: AVAudioPCMBuffer) {}
}

protocol SpeechAudioSessionControlling {
    var category: AVAudioSession.Category { get }
    var isInputAvailable: Bool { get }
    var recordPermission: AVAudioSession.RecordPermission { get }
    func setCategory(_ category: AVAudioSession.Category) throws
    func setSessionActive(_ active: Bool, completion: @escaping (Bool) -> Void)
    func requestRecordPermission(_ response: @escaping (Bool) -> Void)
}

extension AVAudioSession: SpeechAudioSessionControlling {
    func setSessionActive(_ active: Bool, completion: @escaping (Bool) -> Void) {
        if #available(iOS 27.0, *) {
            if active {
                activate(options: []) { activated, error in
                    if let error {
                        print(error)
                    }
                    completion(activated && error == nil)
                }
            } else {
                deactivate(options: []) { deactivated, error in
                    if let error {
                        print(error)
                    }
                    completion(deactivated && error == nil)
                }
            }
        } else {
            let performSetActive = {
                do {
                    try self.setActive(active)
                    completion(true)
                } catch {
                    print(error)
                    completion(false)
                }
            }
            if Thread.isMainThread {
                DispatchQueue.global(qos: .userInitiated).async(execute: performSetActive)
            } else {
                performSetActive()
            }
        }
    }
}

class SpeechToTextManager {
    
    var delegate:SpeechToTextDelegate?
    
    private var audioEngine = AVAudioEngine()
    private var speechRecognizer:SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale.init(identifier: "en"))
    private var request:SFSpeechAudioBufferRecognitionRequest? = SFSpeechAudioBufferRecognitionRequest()
    private var recognitionTask:SFSpeechRecognitionTask?
    
    private var timer:Timer?
    private var isVoiceRecognitionAuthorized:Bool = false
    private(set) var isRecording:Bool = false
    private(set) var isStarting:Bool = false
    private var hasInstalledTap:Bool = false
    private var startGeneration: Int = 0
    static let sharedAudioSessionQueue = DispatchQueue(label: "com.voiceassistant.speech.audiosession", qos: .userInitiated)
    private let audioSessionQueue = SpeechToTextManager.sharedAudioSessionQueue
    private let audioSession: SpeechAudioSessionControlling
    private let speechAuthorizationStatusProvider: () -> SFSpeechRecognizerAuthorizationStatus
    
    static let shared = SpeechToTextManager()
    
    init(
        audioSession: SpeechAudioSessionControlling = AVAudioSession.sharedInstance(),
        speechAuthorizationStatusProvider: @escaping () -> SFSpeechRecognizerAuthorizationStatus = { SFSpeechRecognizer.authorizationStatus() }
    ) {
        self.audioSession = audioSession
        self.speechAuthorizationStatusProvider = speechAuthorizationStatusProvider
        addObservers()
        if #available(iOS 13, *) {
            print("supported locals: ",speechRecognizer?.supportsOnDeviceRecognition.description ?? "unkown")
        } else {
            // Fallback on earlier versions
        }
    }
    
    deinit {
        removerObservers()
    }

    static func isValidRecordingFormat(_ format: AVAudioFormat) -> Bool {
        return format.sampleRate > 0 && format.channelCount > 0
    }
    
    private func recordAndRecognizeSpeech()  {
        guard !isStarting else { return }

        let authStatus = speechAuthorizationStatusProvider()
        isVoiceRecognitionAuthorized = (authStatus == .authorized)
        guard isVoiceRecognitionAuthorized else {
            checkVoiceRecognitionAuthorization()
            notifyFinishRecording()
            return
        }

        guard audioSession.recordPermission == .granted else {
            microphoneAuthrization()
            notifyFinishRecording()
            return
        }

        startGeneration &+= 1
        let generation = startGeneration
        isStarting = true

        setSessionCategoryForSpeechToText { [weak self] activated in
            guard let self else { return }
            guard self.startGeneration == generation else { return }
            self.isStarting = false

            guard activated,
                  self.audioSession.category == .playAndRecord,
                  self.audioSession.isInputAvailable else {
                self.notifyFinishRecording()
                return
            }

            self.startRecognitionSessionAfterAudioActivation()
        }
    }

    private func startRecognitionSessionAfterAudioActivation() {
        setLocal()
        guard let myRecognizer = speechRecognizer else {
            print("recognizer is not supported for the current local")
            notifyFinishRecording()
            return
        }

        guard myRecognizer.isAvailable else {
            // recognizer is not availabel right now
            notifyFinishRecording()
            showSiriEnablementMessage()
            return
        }

        cleanupAudioSessionState(cancelTask: true)

        let node = audioEngine.inputNode
       // let recordingFormate = AVAudioFormat(settings: [AVFormatIDKey: kAudioFormatLinearPCM, AVLinearPCMBitDepthKey: 16, AVLinearPCMIsFloatKey: true, AVSampleRateKey: Float64(44100), AVNumberOfChannelsKey: 1])//node.outputFormat(forBus: 0)
        let recordingFormate = node.outputFormat(forBus: 0)
        guard Self.isValidRecordingFormat(recordingFormate) else {
            abortRecording()
            return
        }

        let newRequest = SFSpeechAudioBufferRecognitionRequest()
        request = newRequest

        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormate) {[weak self] (buffer, _) in
            self?.request?.append(buffer)
            self?.calculatePower(forBuffer: buffer)
        }
        hasInstalledTap = true
        
        audioEngine.prepare()
        do{
            try audioEngine.start()
        }catch{
            print(error)
            abortRecording()
            return
        }

        self.startSpeechTimer(withDuration: 8)
        isRecording = true
       //request.contextualStrings  = [ "$ ", "dollar","Dollars", "Dollar"]
        
        recognitionTask = myRecognizer.recognitionTask(with: newRequest , resultHandler: {[weak self] (result, err) in
            if let result = result {
                if result.isFinal {
                    self?.finishRecording(with:result.bestTranscription.formattedString )
//                   self?.finishRecording(with:result.bestTranscription.formattedString.withoutPunctuationCharacters.withoutSpecialCharacters )
                    return
                }
                self?.startSpeechTimer(withDuration: AssistantConfig.config?.listeningDuration ?? 2)
                let bestString = result.bestTranscription.formattedString
                self?.delegate?.speechToText(didRecognizeText: bestString)
                print(bestString)
            }else if let err = err {
                self?.isRecording = false
                print(err.localizedDescription)
                
            }
        })
    }
    
    private func calculatePower(forBuffer buffer: AVAudioPCMBuffer) {
        delegate?.speechToText(didInstallBuffer: buffer)
        guard let channelData = buffer.floatChannelData else {
            return
        }
        let channelDataValue = channelData.pointee
        let channelDataValueArray = stride(from: 0,
                                           to: Int(buffer.frameLength),
                                           by: buffer.stride).map{ channelDataValue[$0] }
        let bufferFrameLength = Float(buffer.frameLength)
        let rms = sqrt(channelDataValueArray.map{ $0 * $0 }.reduce(0, +) / bufferFrameLength )
        let avgPower = 20 * log10(rms)
        var meterLevel:Float = 0.0
        if avgPower.isFinite{
            if avgPower < -80.0 {
                meterLevel = 0.0
            } else if avgPower >= 1.0 {
                meterLevel =  1.0
            } else {
                meterLevel = (abs(-80.0) - abs(avgPower)) / abs(-80.0)
            }
        }
        if meterLevel < 0.5 {
            meterLevel = 0
        }else {
            meterLevel -= 0.4
        }
        delegate?.speechToText(updateVoicePowerInDB: meterLevel)
    }
    
    
   private func  startSpeechTimer(withDuration sconds:Double){
        timer?.invalidate()
        timer = nil
        timer = Timer.scheduledTimer(withTimeInterval: sconds, repeats: false, block: { [weak self](timer) in
            self?.stop()
        })
    }
    
    private func finishRecording(with text:String? = nil) {
       if isRecording { // isRecording  is using  to prevent SpeechToTextManager from submit text if recording stoped by TextToSpeechManager
            if let message = text {
                self.delegate?.speechToText(didFinishWithText: message)
            }
            isRecording =  false
            timer?.invalidate()
            self.stop()
       } else if isStarting {
            startGeneration &+= 1
            isStarting = false
            notifyFinishRecording()
       }
    }
    
    // MARK: - Control
    
    func setSessionCategoryForSpeechToText(completion: @escaping (Bool) -> Void) {
        audioSessionQueue.async { [weak self] in
            guard let self else {
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            do {
                try self.audioSession.setCategory(AVAudioSession.Category.playAndRecord)
                self.audioSession.setSessionActive(true) { activated in
                    DispatchQueue.main.async {
                        completion(activated)
                    }
                }
            } catch let err {
                print(err)
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }

    private func cleanupAudioSessionState(cancelTask: Bool) {
        timer?.invalidate()
        timer = nil
        if cancelTask {
            startGeneration &+= 1
            isStarting = false
            isRecording = false
        }
        if hasInstalledTap {
            audioEngine.inputNode.removeTap(onBus: 0)
            hasInstalledTap = false
        }
        if audioEngine.isRunning {
            audioEngine.stop()
        }
        audioEngine.reset()
        audioEngine = AVAudioEngine()
        request?.endAudio()
        if cancelTask {
            recognitionTask?.cancel()
        } else {
            recognitionTask?.finish()
        }
        recognitionTask = nil
        request = nil
    }

    private func notifyFinishRecording() {
        if Thread.isMainThread {
            delegate?.speechToTextFinishRecording()
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.delegate?.speechToTextFinishRecording()
            }
        }
    }

    private func abortRecording() {
        cleanupAudioSessionState(cancelTask: true)
        notifyFinishRecording()
    }
    
    private func stop()  {
        cleanupAudioSessionState(cancelTask: false)
        notifyFinishRecording()
    }
    
    func start()  {
        NotificationCenter.default.post(name: Constants.NotificationNames.StopTextToSpeech,
                                        object: nil)
        NotificationCenter.default.post(name: Constants.NotificationNames.StopMedia, object: nil)
        self.recordAndRecognizeSpeech()
    }

#if DEBUG
    func simulateActiveRecordingForTesting() {
        isRecording = true
    }

    func simulateSilenceTimerStopForTesting() {
        stop()
    }

    func simulateStopWithoutSubmittingForTesting() {
        finishRecording()
    }

    func simulateFinalTranscriptionForTesting(_ text: String) {
        finishRecording(with: text)
    }
#endif
    
    
    // MARK:- Observers
    
    func removerObservers() {
        observerTokens.forEach { NotificationCenter.default.removeObserver($0) }
        observerTokens.removeAll()
    }
    private var observerTokens: [NSObjectProtocol] = []
    private func addObservers()  {
        let startObserver = NotificationCenter.default.addObserver(forName: Constants.NotificationNames.StartSpeechToText, object: nil, queue: OperationQueue.main) { [weak self] (notification) in
            self?.delegate?.speechToTextDidStartRecognition()
            DispatchQueue.main.async(execute: {[weak self] in
                self?.start()
                
            })
        }
        let stopObserver = NotificationCenter.default.addObserver(forName: Constants.NotificationNames.StopSpeechToText, object: nil, queue: OperationQueue.main) { [weak self](notification) in
            self?.finishRecording()
        }
        let interruptionObserver = NotificationCenter.default.addObserver(forName: AVAudioSession.interruptionNotification, object: nil, queue: OperationQueue.main) { [weak self] notification in
            guard let userInfo = notification.userInfo,
                  let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
                  let type = AVAudioSession.InterruptionType(rawValue: typeValue),
                  type == .began else {
                return
            }
            self?.finishRecording()
        }
        observerTokens = [startObserver, stopObserver, interruptionObserver]
    }
    
    private func setLocal() {
        let langCode = AssistantConfig.config?.lastMessageLangCode ?? "en"
        self.speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: langCode))
    }
    
   
    
    // MARK:- Authuraization
    private func checkVoiceRecognitionAuthorization() {
        SFSpeechRecognizer.requestAuthorization {
            [weak self] (authStatus) in
            guard let self = self else { return }
            switch authStatus {
            case .authorized:
                self.isVoiceRecognitionAuthorized = true
                self.microphoneAuthrization()
            case .denied ,.restricted ,.notDetermined:
                self.errorMessageToAppSetting(message: "make_sure_voice_recognition_enabled".localForChosnLangCodeBB)
            @unknown default:
                break
            }
        }
    }
    
    private func microphoneAuthrization()  {
        audioSession.requestRecordPermission { [weak self](granted) in
            if !granted {
                self?.errorMessageToAppSetting(message: "make_sure_mic_enabled".localForChosnLangCodeBB)
            }
        }
    }
    
    
    private func errorMessageToAppSetting(message:String) {
        showErrorMessage(message, okHandelr: {
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                }
            }
            self.finishRecording()
            
        }, cancelHandler: {
            self.finishRecording()
        })
    }
    
    private func showSiriEnablementMessage() {
        showErrorMessage("make_sure_siri_enabled".localForChosnLangCodeBB, okHandelr: { [weak self]  in
            self?.finishRecording()
        })
    }
    
}
