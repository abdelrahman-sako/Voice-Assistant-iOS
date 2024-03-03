//
//  TextToSpeechModel.swift
//  LabibaBotFramwork
//
//  Created by Abdulrahman on 2/3/20.
//  Copyright © 2020 Abdul Rahman. All rights reserved.
//

import Foundation

public struct GoogleVoice{
    
    private var voiceLang: LabibaLanguages
    private var name: String?
    private var lang: String?
    init(voiceLang :LabibaLanguages ) {
        self.voiceLang = voiceLang
        switch voiceLang {
        case .ar:
            name = AssistantConfig.config.voices.voiceManAR
        case .en:
             name = AssistantConfig.config.voices.voiceManEN
        case .ru:
             name = AssistantConfig.config.voices.voiceManAR
        case .de:
             name = AssistantConfig.config.voices.voiceManAR
        case .zh:
             name = AssistantConfig.config.voices.voiceManAR
        }
    }
   var voicename:String {
         switch voiceLang {
         case .ar:
            return name != nil ? name! : "ar-XA-Wavenet-A"
         case .en:
            return name != nil ? name! : "en-US-Wavenet-F"
         case .ru:
            return name != nil ? name! : "ru-RU-Wavenet-E"
         case .de:
            return name != nil ? name! : "de-DE-Wavenet-F"
         case .zh:
            return name != nil ? name! : "cmn-CN-Wavenet-D"
        }
    }
    
   var language:String {
         switch voiceLang {
         case .ar:
            return lang != nil ? lang! : "ar-XA"
         case .en:
            return lang != nil ? lang! : "en-US"
         case .ru:
            return lang != nil ? lang! : "ru-RU"
         case .de:
            return lang != nil ? lang! : "de-DE"
         case .zh:
            return lang != nil ? lang! : "cmn-CN"
        }
    }
    
}

class TextToSpeechModel{
    var text:String
    var googleVoice:GoogleVoice
    var clientid:String
    var isSSML:Bool
    var isBase64:Int
  
  init(text:String,googleVoice:GoogleVoice,clientid:String,isSSML:Bool = false, isBase64:Int) {
        self.text = text
        self.googleVoice = googleVoice
        self.clientid = clientid
        self.isSSML = isSSML
        self.isBase64 = isBase64
    }
    func testText() -> String {
        return "دَفِعْ 1.912 دينار اردني لِفَاتُورَة <br> <br>مِنْ حْسَابْ جَّارِيْ 000@:@<speak> رَحْ تِدْفَعْ 1.912 دينار اردني لَفَاتُوْرِةْ مِنْ حْسَابْ جَّارِيْ 000</speak>‎"
    }
}
