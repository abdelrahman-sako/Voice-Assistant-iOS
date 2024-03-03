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

class SpeechToTextManager {
    
    var delegate:SpeechToTextDelegate?
    
    private var audioEngine = AVAudioEngine()
    private var speechRecognizer:SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale.init(identifier: "ar"))
    private var request:SFSpeechAudioBufferRecognitionRequest? = SFSpeechAudioBufferRecognitionRequest()
    private var recognitionTask:SFSpeechRecognitionTask?
    
    private var timer:Timer?
    private var isVoiceRecognitionAuthorized:Bool = false
    private(set) var isRecording:Bool = false
    private let audioSession =  AVAudioSession.sharedInstance()
    
    static let shared = SpeechToTextManager()
    
    private init() {
        addObservers()
        if #available(iOS 13, *) {
            print("supported locals: ",speechRecognizer?.supportsOnDeviceRecognition.description)
        } else {
            // Fallback on earlier versions
        }
    }
    
    deinit {
        removerObservers()
    }
    
    private func recordAndRecognizeSpeech()  {
        if !isVoiceRecognitionAuthorized {
            checkVoiceRecognitionAuthorization()
        }
        if audioSession.category != .playAndRecord{
            return
        }
        
        request = SFSpeechAudioBufferRecognitionRequest()
        setLocal()
        self.audioEngine.inputNode.removeTap(onBus: 0)
        let node = audioEngine.inputNode
       // let recordingFormate = AVAudioFormat(settings: [AVFormatIDKey: kAudioFormatLinearPCM, AVLinearPCMBitDepthKey: 16, AVLinearPCMIsFloatKey: true, AVSampleRateKey: Float64(44100), AVNumberOfChannelsKey: 1])//node.outputFormat(forBus: 0)
        let recordingFormate = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormate) {[weak self] (buffer, _) in
            self?.request?.append(buffer)
            self?.calculatePower(forBuffer: buffer)
        }
        
        
        audioEngine.prepare()
        do{
            try audioEngine.start()
        }catch{
            print(error)
        }
        guard let myRecognizer = SFSpeechRecognizer() else {
            print("recognizer is not supported for the current local")
            return
        }
        
        if !myRecognizer.isAvailable {
            // recognizer is not availabel right now
            showSiriEnablementMessage()
            return
        }
        self.startSpeechTimer(withDuration: 8)
        guard let request = request else {
            return
        }
        isRecording = true
       //request.contextualStrings  = [ "$ ", "dollar","Dollars", "Dollar"]
        
        recognitionTask = speechRecognizer?.recognitionTask(with: request , resultHandler: {[weak self] (result, err) in
            if let result = result {
                if result.isFinal {
                    self?.finishRecording(with:result.bestTranscription.formattedString )
//                   self?.finishRecording(with:result.bestTranscription.formattedString.withoutPunctuationCharacters.withoutSpecialCharacters )
                    return
                }
                self?.startSpeechTimer(withDuration: AssistantConfig.config.listeningDuration)
                let bestString = result.bestTranscription.formattedString
                self?.delegate?.speechToText(didRecognizeText: bestString)
                print(bestString)
            }else if let err = err {
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
       }
    }
    
    // MARK: - Control
    
    func setSessionCategoryForSpeechToText()  {
           do {
             try audioSession.setCategory(AVAudioSession.Category.playAndRecord)
           }catch let err {
               print(err)
           }
       }
    
    private func stop()  {
        self.audioEngine.inputNode.removeTap(onBus: 0)
        self.audioEngine = AVAudioEngine()
        self.recognitionTask?.finish()
        self.recognitionTask = nil
        self.request = nil
        self.audioEngine.stop()
        self.delegate?.speechToTextFinishRecording()
    }
    
    func start()  {
        setSessionCategoryForSpeechToText()
        NotificationCenter.default.post(name: Constants.NotificationNames.StopTextToSpeech,
                                        object: nil)
        NotificationCenter.default.post(name: Constants.NotificationNames.StopMedia, object: nil)
        self.recordAndRecognizeSpeech()
    }
    
    
    // MARK:- Observers
    
    func removerObservers() {
        NotificationCenter.default.removeObserver(startSpeechToTextOb!, name: Constants.NotificationNames.StartSpeechToText, object: nil)
        NotificationCenter.default.removeObserver(startSpeechToTextOb!, name: Constants.NotificationNames.StopSpeechToText, object: nil)
    }
    // var startSpeechToTextOb: NSObjectProtocol?
    var startSpeechToTextOb:Any?
    private func addObservers()  {
        startSpeechToTextOb =  NotificationCenter.default.addObserver(forName: Constants.NotificationNames.StartSpeechToText, object: nil, queue: OperationQueue.main) { [weak self] (notification) in
            self?.delegate?.speechToTextDidStartRecognition()
            DispatchQueue.main.async(execute: {[weak self] in
                self?.start()
                
            })
        }
        NotificationCenter.default.addObserver(forName: Constants.NotificationNames.StopSpeechToText, object: nil, queue: OperationQueue.main) { [weak self](notification) in
            self?.finishRecording()
        }
    }
    
    private func setLocal() {
        self.speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: AssistantConfig.config.lastMessageLangCode))
    }
    
   
    
    // MARK:- Authuraization
    private func checkVoiceRecognitionAuthorization() {
        SFSpeechRecognizer.requestAuthorization {
            [unowned self] (authStatus) in
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
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self](granted) in
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
