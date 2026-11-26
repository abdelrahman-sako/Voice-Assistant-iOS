//
//  TextToSpeechManager.swift
//  Voice Assistant
//
//  Created by Osama Hasan on 15/01/2024.
//

import Foundation
import AVFoundation

protocol TextToSpeechDelegate {
    func textToSpeechDidStart()
    func textToSpeechDidStop()
}

protocol TextToSpeechAudioSessionControlling {
    func setCategory(_ category: AVAudioSession.Category) throws
}

extension AVAudioSession: TextToSpeechAudioSessionControlling {}

class TextToSpeechManeger:NSObject{
    private var audioEngine = AVAudioEngine()
    private var player:AVAudioPlayer?
    private var playerItem:AVPlayerItem?
    private var TTS_Models_Array:[TTSMessageModel] = []
    private var isPlaying:Bool = false
    private var voiceRate:Float = 1.3
    private var volume:Float = 1.0
    private var playbackGeneration: Int = 0
    private let audioSessionQueue = SpeechToTextManager.sharedAudioSessionQueue
    private let audioSession: TextToSpeechAudioSessionControlling
    private var downloadTask:AnyCancelable?
    var delegate:TextToSpeechDelegate?
    static let Shared = TextToSpeechManeger()
    var botConnector:BotConnector = BotConnector.shared
    private var ToDeletDialogs:[ConversationDialog] = []
  
    private convenience override init(){
        self.init(audioSession: AVAudioSession.sharedInstance())
    }

    init(audioSession: TextToSpeechAudioSessionControlling) {
        self.audioSession = audioSession
        super.init()
        addStopTTSObserver()
    }
    

    func getURL(for model:TTSMessageModel) {//-> URL? {
        var message = model.message.replacingOccurrences(of: "\"", with: "")
        message = message.isEmpty ? "\n" : message
      let TTS_Model = TextToSpeechModel(text: message, googleVoice: GoogleVoice(voiceLang: LabibaLanguages(rawValue:model.langCode) ?? .ar), clientid: "0",isSSML: model.isSSML, isBase64: AssistantConfig.config.audioType)
        DataSource.shared.textToSpeech(model: TTS_Model) { result in
            switch result{
            case .success(let model):
                if let url = URL(string: model.file ?? ""){
                    self.ToDeletDialogs.first?.voiceUrl = url.absoluteString
                    self.ToDeletDialogs.removeFirst()
                    self.downloadFileFromURL(url: url)
                }else{
                  self.playBase64Content(base64String: model.audioContent ?? "")
                }
            case .failure(_):
                self.isPlaying = false
                if self.TTS_Models_Array.count > 0 {
                    self.TTS_Models_Array.remove(at: 0)
                }
                self.playNextAudio()
            }
        }

        
        //        let url  = URL(string: "https://translate.google.com/translate_tts?ie=UTF-8&tl=\( model.langCode)&client=tw-ob&q=\(model.message)".addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
        //self.downloadFileFromURL(url: url)
        //        return URL(string: "https://translate.google.com/translate_tts?ie=UTF-8&tl=\( model.langCode)&client=tw-ob&q=\(model.message)".addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
        
    }
    
    
    func append(dialog:ConversationDialog)  {
        ToDeletDialogs.append(dialog)
        let message = dialog.message ?? "\n"
      //  message = message.isEmpty ? "\n" : message
        //if !Labiba.EnableTextToSpeech   { return }
        
        var filteredText = message//dialog.message ?? " "
        //        filteredText = filteredText.withoutHtmlTags
        filteredText.removeHtmlTags()
      
        let langCode = filteredText.detectedLangauge() ?? "ar"
        var rate:Float = 1
        switch langCode {
        case "ar":
            //langCode = "ar-JO"
            rate = AssistantConfig.config.voices.VoiceRateAR
        default:
            // langCode = "en-US"
            rate = AssistantConfig.config.voices.voiceRateEN
        }
        if let linkRange = filteredText.detectedHyperLinkRange(){
            filteredText.removeSubrange(linkRange)
        }
        // TTS_Models_Array += longMessageDivider(text: filteredText, langCode: langCode, rate: rate)
        var  messageModel:TTSMessageModel!
        if let ssml = dialog.SSML {
            messageModel = TTSMessageModel(message: ssml, langCode: langCode, rate: rate,isSSML: true, isBsae64: AssistantConfig.config.audioType)
        }else{
          messageModel = TTSMessageModel(message: filteredText, langCode: langCode, rate: rate, isBsae64: AssistantConfig.config.audioType)
        }
        TTS_Models_Array.append(messageModel)
        playNextAudio()
        
        
    }
    
    func longMessageDivider(text:String , langCode:String ,rate:Float) -> [TTSMessageModel] {
        if text.count > 180 {
            var segmentArray:[TTSMessageModel] = []
            let segmentCount = text.count/180
            let reminder = text.count % 180
            var customString = text
            for _ in 1...segmentCount {
                let startIndex = customString.startIndex
                var endIndex = customString.index(startIndex, offsetBy: 180)
                if customString[endIndex] != " " {
                    let stringForSpace = String(customString[endIndex...])
                    let firstSpaceIndex = stringForSpace.firstIndex(of: " ") ?? stringForSpace.startIndex
                    let addedValue = stringForSpace[stringForSpace.startIndex...firstSpaceIndex].count
                    endIndex = customString.index(startIndex, offsetBy: 180 + addedValue)
                }
              segmentArray.append( TTSMessageModel(message: String(customString[..<endIndex]), langCode: langCode, rate: rate, isBsae64: AssistantConfig.config.audioType) )
                customString = String(customString[endIndex...])
            }
            if reminder > 0 {
              segmentArray.append(TTSMessageModel(message: String(customString[customString.startIndex..<customString.endIndex]), langCode: langCode, rate: rate, isBsae64: AssistantConfig.config.audioType))
            }
            return segmentArray
        }else{
          return [TTSMessageModel(message: text, langCode: langCode, rate: rate, isBsae64: AssistantConfig.config.audioType)]
        }
    }
    
    //var data:Data?
//    func downloadFileFromURL(url:URL){
//
//        var downloadTask:URLSessionDownloadTask
//        let session = BotConnector.shared.sessionManager?.session ?? URLSession.shared
//        downloadTask = session.downloadTask(with: url  , completionHandler: {[weak self](url, response, err) in
//            guard let url = url else{return}
//          //  self?.data = try! Data(contentsOf: url)
//            self?.play(url: url)
//        })
//
//        downloadTask.resume()
//    }
    func downloadFileFromURL(url:URL){
        
        downloadTask =  DataSource.shared.downloadFile(fileURL: url) { [weak self]result in
            switch result {
            case .success(let url):
                self?.play(url: url)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    
    func play(url:URL) {
        NotificationCenter.default.post(name: Constants.NotificationNames.StopSpeechToText,
                                        object: nil)
        print("playing \(url)")
        playbackGeneration &+= 1
        let generation = playbackGeneration
        let targetVolume = volume
        let targetRate = voiceRate
        audioSessionQueue.async { [weak self] in
            guard let self else { return }
            do {
                try self.audioSession.setCategory(AVAudioSession.Category.playback)
                let newPlayer = try AVAudioPlayer(contentsOf: url)
                newPlayer.prepareToPlay()
                newPlayer.volume = targetVolume
                newPlayer.enableRate = true
                newPlayer.rate = targetRate
                newPlayer.delegate = self

                DispatchQueue.main.async { [weak self] in
                    guard let self, self.playbackGeneration == generation else {
                        newPlayer.stop()
                        return
                    }
                    self.player = newPlayer
                    self.delegate?.textToSpeechDidStart()
                    self.audioSessionQueue.async {
                        newPlayer.play()
                    }
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            } catch {
                print("AVAudioPlayer init failed")
            }
        }
    }
    
    func setVolume(volume:Float)  {
        self.volume = volume
        player?.volume = volume
    }
    
    
    private func playNextAudio() {
        if TTS_Models_Array.count > 0 && !isPlaying{
            isPlaying = true
            getURL(for: TTS_Models_Array[0])
            voiceRate = TTS_Models_Array[0].rate
        }
    }
    
    func addStopTTSObserver()  {
        NotificationCenter.default.addObserver(forName: Constants.NotificationNames.StopTextToSpeech, object: nil, queue: OperationQueue.main) { [weak self](notification) in
            self?.stop()
        }
    }
    

    
    func stop() {
        playbackGeneration &+= 1
        if !isPlaying {
            return
        }
        downloadTask?.cancelRequest()
        setSessionCategoryForSpeechToText()
        player?.pause()
        player = nil
        isPlaying = false
        if TTS_Models_Array.count > 0 {
            TTS_Models_Array.removeAll()
        }
        delegate?.textToSpeechDidStop()
    }
    
    func setSessionCategoryForSpeechToText() {
        configureAudioSession(category: .playAndRecord)
    }

    private func configureAudioSession(
        category: AVAudioSession.Category,
        completion: ((Bool) -> Void)? = nil
    ) {
        audioSessionQueue.async { [weak self] in
            guard let self else {
                if let completion {
                    DispatchQueue.main.async {
                        completion(false)
                    }
                }
                return
            }
            let succeeded: Bool
            do {
                try self.audioSession.setCategory(category)
                succeeded = true
            } catch let err {
                print(err)
                succeeded = false
            }
            if let completion {
                DispatchQueue.main.async {
                    completion(succeeded)
                }
            }
        }
    }
    
    @objc func playerFailed(_ note: Notification) {
        isPlaying = false
        player?.pause()
    }
    
    
  
  func playBase64Content(base64String: String) {
    playbackGeneration &+= 1
    let generation = playbackGeneration
    let targetVolume = volume
    let targetRate = voiceRate
    audioSessionQueue.async { [weak self] in
        guard let self else { return }
        do {
            try self.audioSession.setCategory(AVAudioSession.Category.playback)
            guard let audioPlayer = self.convertBase64ToVoice(base64String: base64String) else {
                print("Failed to convert Base64 to voice.")
                return
            }
            audioPlayer.volume = targetVolume
            audioPlayer.enableRate = true
            audioPlayer.rate = targetRate
            audioPlayer.delegate = self

            DispatchQueue.main.async { [weak self] in
                guard let self, self.playbackGeneration == generation else {
                    audioPlayer.stop()
                    return
                }
                self.player = audioPlayer
                self.delegate?.textToSpeechDidStart()
                self.audioSessionQueue.async {
                    audioPlayer.play()
                }
            }
        } catch {
            print("Failed to create AVAudioPlayer: \(error)")
        }
    }
  }
  
  func convertBase64ToVoice(base64String: String) -> AVAudioPlayer? {
    // Convert Base64 string to Data
    guard let audioData = Data(base64Encoded: base64String) else {
      print("Invalid Base64 string.")
      return nil
    }
    
    do {
      // Create an AVAudioPlayer with the audio data
      let audioPlayer = try AVAudioPlayer(data: audioData)
      
      // Prepare the audio player for playback
      audioPlayer.prepareToPlay()
      
      return audioPlayer
    } catch {
      print("Failed to create AVAudioPlayer: \(error)")
      return nil
    }
  }
}

class TTSMessageModel{
    var message:String
    var langCode:String
    var rate:Float
    var isSSML:Bool
    var isBase64:Int
  init(message:String ,langCode:String ,rate:Float ,isSSML:Bool = false, isBsae64:Int) {
        self.message = message
        self.langCode = langCode
        self.rate = rate
        self.isSSML = isSSML
        self.isBase64 = isBsae64
    }
}




extension TextToSpeechManeger: AVAudioPlayerDelegate{
    
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        let handleFinish = { [weak self] in
            guard let self else { return }
            if !self.isPlaying {
                return
            }
            self.isPlaying = false
            if self.TTS_Models_Array.count > 0 {
                self.TTS_Models_Array.remove(at: 0)
            }
            NotificationCenter.default.post(name: Constants.NotificationNames.FinishCurrentTextToSpeechPhrase,object: nil)
            if self.TTS_Models_Array.count == 0 { // comment for nathealth
                 self.delegate?.textToSpeechDidStop()
              //  if Labiba.Temporary_Bot_Type != .keyboardType  {
                    self.setSessionCategoryForSpeechToText()
                if AssistantConfig.config.voices.enableAutoListening {
                        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.2) {
                            DispatchQueue.main.async {
                                NotificationCenter.default.post(name: Constants.NotificationNames.StartSpeechToText,
                                object: nil)
                            }
                            
                        }
                        
                 //   }
                }
                
            }
            
            self.playNextAudio()
        }
        if Thread.isMainThread {
            handleFinish()
        } else {
            DispatchQueue.main.async(execute: handleFinish)
        }
    }
}
