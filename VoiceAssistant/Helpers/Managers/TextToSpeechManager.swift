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

class TextToSpeechManeger:NSObject{
    private var audioEngine = AVAudioEngine()
    private var player:AVAudioPlayer?
    private var playerItem:AVPlayerItem?
    private var TTS_Models_Array:[TTSMessageModel] = []
    private var isPlaying:Bool = false
    private var voiceRate:Float = 1.3
    private var volume:Float = 1.0
    private let audioSession =  AVAudioSession.sharedInstance()
    private var downloadTask:AnyCancelable?
    var delegate:TextToSpeechDelegate?
    static let Shared = TextToSpeechManeger()
    var botConnector:BotConnector = BotConnector.shared
    private var ToDeletDialogs:[ConversationDialog] = []
  
    private override init(){
        super.init()
        addStopTTSObserver()
    }
    

    func getURL(for model:TTSMessageModel) {//-> URL? {
        let message = model.message.replacingOccurrences(of: "\"", with: "")
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
        guard let message = dialog.message, !message.isEmpty  else {
            return
        }
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
            for i in 1...segmentCount {
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
        //        do {
        //            let url = URL(fileURLWithPath: url.path)
        //            let isReachable = try url.checkResourceIsReachable()
        //            // ... you can set breaking points after that line, and if you stopped at them it means file exist.
        //        } catch let e {
        //            print("couldnt load file \(e.localizedDescription)")
        //        }
        do {
            try audioSession.setCategory(AVAudioSession.Category.playback)
            self.player = try AVAudioPlayer(contentsOf: url)
            //self.player = try AVAudioPlayer(data: data!)
            delegate?.textToSpeechDidStart()
            player?.prepareToPlay()
            
            player?.volume = volume
            player?.enableRate = true
            player?.rate = voiceRate
            player?.delegate = self
            DispatchQueue.global(qos: .background).async { [weak self] in
                self?.player?.play()
            }
        } catch let error as NSError {
            //self.player = nil
            print(error.localizedDescription)
        } catch {
            print("AVAudioPlayer init failed")
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
    
    func setSessionCategoryForSpeechToText()  {
        do {
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord)
        }catch let err {
            print(err)
        }
    }
    
    @objc func playerFailed(_ note: Notification) {
        isPlaying = false
        player?.pause()
    }
    
    
  
  func playBase64Content(base64String: String) {
    if let audioPlayer = convertBase64ToVoice(base64String: base64String) {
        do {
            try audioSession.setCategory(AVAudioSession.Category.playback)
            delegate?.textToSpeechDidStart()
            audioPlayer.prepareToPlay()

           audioPlayer.volume = volume
           audioPlayer.enableRate = true
           audioPlayer.rate = voiceRate
           audioPlayer.delegate = self

         // Play the audio
         audioPlayer.play()
        }catch {
            print("Failed to create AVAudioPlayer: \(error)")
          }
       
    } else {
      print("Failed to convert Base64 to voice.")
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
        try audioSession.setCategory(AVAudioSession.Category.playback)
      player = try AVAudioPlayer(data: audioData)
      
      // Prepare the audio player for playback
      player?.prepareToPlay()
      
      return player
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
        isPlaying = false
        if TTS_Models_Array.count > 0 {
            TTS_Models_Array.remove(at: 0)
        }
        NotificationCenter.default.post(name: Constants.NotificationNames.FinishCurrentTextToSpeechPhrase,object: nil)
        if  TTS_Models_Array.count == 0 { // comment for nathealth
             delegate?.textToSpeechDidStop()
          //  if Labiba.Temporary_Bot_Type != .keyboardType  {
                setSessionCategoryForSpeechToText()
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
        
        playNextAudio()
    }
}
