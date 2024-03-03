//
//  LabibaRestfulBotConnector.swift
//  LabibaBotFramwork
//
//  Created by Abdulrahman Qasem on 4/19/20.
//  Copyright © 2020 Abdul Rahman. All rights reserved.
//

import Foundation
//import Alamofire
import CoreLocation

protocol MessageAnalyizerDelegate:AnyObject {
    
    func botConnector( didRecieveActivity activity:ConversationDialog) -> Void
    func botConnector( didRequestLiveChatTransferWithMessage message:String) -> Void
    func botConnector( didRequestHumanAgent message:String) -> Void
    func botConnectorDidRecieveTypingActivity() -> Void
    func botConnectorRemoveTypingActivity() -> Void
    func sendGetStarted()
}

class LabibaRestfulBotConnector{ //
    
    var attachmentPayload:PayloadModel?
    static let shared = LabibaRestfulBotConnector()
    var delegate:MessageAnalyizerDelegate?
//    func readExampleData() -> Data {
//        if let path = Labiba.bundle.url(forResource: "JsonExample", withExtension: "json") {
//            do {
//                let data = try Data(contentsOf: path, options: .mappedIfSafe)
//                return data
//                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
//                if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [Dictionary<String,Any>]
//                {
//                    print(jsonArray) // use the json here
//                } else {
//                    print("bad json")
//                }
//            } catch {
//                print(error)
//            }
//        }
//        
//        return Data()
//    }
    
    func parseResponse(response:[LabibaModel])  {
        if response.isEmpty{
            delegate?.botConnectorRemoveTypingActivity()
            return
        }
        mainLoop: for (index,model) in response.enumerated() {
            var cancelCard = false
            
            guard  let msgType = model.messaging_type , msgType == "RESPONSE" else {
                return
            }
            var timestamp:Date? = Date()
            if response.count > index+1 {
                if !(response[index+1].message?.text?.isEmpty  ?? true){
                    timestamp = nil
                }
            }
            // delegate?.botConnector(self, didRequestHumanAgent: "request human agent")
            let dialog = ConversationDialog(by: .bot, time: timestamp)
            let message = model.message
            // message?.text = "livechat.transfer:\(message?.text ?? "")"
            if message?.text?.contains("livechat.transfer:")  ?? false {
                delegate?.botConnector(didRequestLiveChatTransferWithMessage: "livechat.transfer")
                message?.text = message?.text?.replacingOccurrences(of: "livechat.transfer:", with: "")
            }else  if message?.text?.contains("livechat.transfer.once:")  ?? false{
                delegate?.botConnector( didRequestLiveChatTransferWithMessage: "livechat.transfer.once")
                message?.text = message?.text?.replacingOccurrences(of: "livechat.transfer.once:", with: "")
            }
            //  message?.text = message?.text?.replacingOccurrences(of: "livechat.transfer:", with: "").replacingOccurrences(of: "livechat.transfer.once:", with: "")// I know that it doesn't make sense, but this is how they asked me to work, they said that this is Hussam fault  :( :(
            //            dialog.message = message?.text
            //                        message?.text = "مَا هُوَ رَقْمُ الْعَمِيلِ الخَاْصِّ بِكْ !@:@<speak> <s> <emphasis level='strong'> أهلَوْ سَهْلَ </emphasis> </s> <break strength='strong'/> أنا بووجيْ مسؤولِتْ حْسابَكْ لِجْدِيدِهْ <break strength='strong'/> <s> كِيـفْ بَأْدَرْ أَساعْدَكِلْيُومْ؟ </s> </speak>"
            //   message?.text = "مرحبا، انا مساعدك الإفتراضي من يلو. يرجى اختيار اللغة:\u{200f}"
            if let messages = message?.text?.components(separatedBy: "@:@"){
                if messages.count > 0 {
                    dialog.message = messages[0]
                }
                if messages.count > 1 {
                    if !messages[1].isEmpty {
                        dialog.SSML = messages[1]
                    }
                }
            }else{
                dialog.message = message?.text
            }
            
            
            // MARK:- handel GIF
            if  let message = dialog.message{
                if   message.hasPrefix("GIF_") || message.hasPrefix("LOOP_GIF_") {
                    let isLooping = message.hasPrefix("LOOP_GIF_")
                    let offsetIndex = isLooping ? message.index(message.startIndex, offsetBy: 9) : message.index(message.startIndex, offsetBy: 4)
                    print(message[offsetIndex..<message.endIndex].base)
                    NotificationCenter.default.post(name: Constants.NotificationNames.ShowHideDynamicGIF,
                                                    object: ["show":true , "url":String(message[offsetIndex...]),"isLooping":isLooping])
                    return
                }else if message.hasPrefix("ANIMATE_GRADIENT_DEFAULT") {
                    NotificationCenter.default.post(name: Constants.NotificationNames.ShowHideDynamicGIF,
                                                    object: ["show":false])
                    
                }
            }
            
            // MARK:- metadata
            if  let metadata = message?.metadata
            {
                if metadata == "mute" {
                    dialog.enableTTS = false
                }
            }
            
            Constants.content_type = "" // default value if content type nil
            let attach = message?.attachment
            // MARK:- choices
            if let quick_replies = message?.quick_replies {
                let firstReply = quick_replies.first
                let title = firstReply?.title
                if  (title?.isEmpty ?? true ){
                    if let content_type = firstReply?.content_type
                    {
                        Constants.content_type = content_type
                        if Constants.content_type != "" && Constants.content_type != "text"
                        {
                            let validate = Constants.content_type
                            let splits = validate.split(separator: ",")
                            let index0 = splits[0]
                            let char = String(index0)
                            let dialogChoice = DialogChoice(title: "Calender")
                            var isKeyboardType:Bool = false
                            switch QuickReplyContentType(rawValue:content_type) {
                            case .some(let contentType):
                                switch contentType {
                                case .location :
                                    dialog.requestLocation = true
                                    fallthrough
                                case .dateAndTime ,.date ,.time , .location ,.QRCode,.camera,.image,.gallery:
                                    dialogChoice.title = contentType.title
                                    dialogChoice.action = contentType.action
                                    dialog.choices = [dialogChoice]
                                case .userEmail ,.number , .userPhoneNumber ,.freeText,.otp:
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        NotificationCenter.default.post(name: Constants.NotificationNames.ChangeInputToTextViewType,object: char)
                                    }
                                    isKeyboardType = true
                                }
                            case .none:
                                break
                            }
                            if !isKeyboardType{
                                NotificationCenter.default.post(name: Constants.NotificationNames.ChangeInputToVoiceAssistantType,
                                                                object: nil)
                            }
                        }
                        
                    }
                }
                else
                {
                    NotificationCenter.default.post(name: Constants.NotificationNames.ChangeInputToVoiceAssistantType,
                                                    object: nil)
                    Constants.content_type = ""
                    Constants.Keyboard_type = ""
                    dialog.choices = quick_replies.map
                    { (reply) -> DialogChoice in
                        
                        let dialogChoice = DialogChoice(title: reply.title ?? "")
                        if let content_type = firstReply?.content_type
                        {
                            if  content_type == "QR_CODE" {
                                dialogChoice.action = DialogChoiceAction.QRCode
                            }
                        }
                        
                        if dialogChoice.title.hasPrefix("CALENDAR:")
                        {
                            let index = dialogChoice.title.index(dialogChoice.title.startIndex, offsetBy: 9)
                            dialogChoice.title = dialogChoice.title.substring(from: index)
                            dialogChoice.action = DialogChoiceAction.calendar
                        }
                        if let _payStr = reply.getPayloadObj()
                        {
                            if let token = _payStr.ParamToken, token.uppercased().hasPrefix("CHOICE_ACTION:")
                            {
                                NotificationCenter.default.post(name: Constants.NotificationNames.ChangeTextViewKeyboardType,
                                                                object: "Disable")
                                let action = token.uppercased()
                                    .replacingOccurrences(of: "CHOICE_ACTION:", with: "")
                                    .trimmingCharacters(in: .whitespacesAndNewlines)
                                dialogChoice.action = DialogChoiceAction(rawValue: action)
                            }
                        }
                        return dialogChoice
                    }
                }
            } else {
                if let payload = message?.attachment?.payload {
                    switch payload {
                    case .string(let message):
                        if let attachType = attach?.type, attachType == "backPropagation"{
                            //Labiba.delegate?.labibaDataUpdate?(payload: message)
                            return
                        }else{
                            switch message {
                            case "goRealtime":
                                delegate?.botConnector( didRequestHumanAgent: message)
                                print("redirect to human agent with message: ",message)
                            case "redirectToStart":
                                DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now()+0.5, execute: {
                                    DispatchQueue.main.async {
                                        self.delegate?.sendGetStarted()
                                    }
                                })
                            default:
                                break
                            }
                        }
                        
                        
                    case .payloadModel(let  payload):
                        if let attachType = attach?.type{
                            NotificationCenter.default.post(name: Constants.NotificationNames.ChangeInputToVoiceAssistantType,
                                                            object: nil)
                            if attachType == "template", let elements = payload.elements
                            {
                                
                                
                                let dialogChoice = DialogChoice(title: "Click to choose".local)
                                dialogChoice.action = DialogChoiceAction.menu
                                dialog.choices = [dialogChoice]
                                self.attachmentPayload = payload
                                
                                dialog.cards = DialogCards(presentation: .menu)
                                
                                dialog.cards?.items = elements.map({ (elm) -> DialogCard in
                                    let card = DialogCard(title: elm.title ?? "")
                                    card.imageUrl = elm.image_url
                                    // card.subtitle = elm["subtitle"].string
                                    if let buttons = elm.buttons {
                                        card.buttons = buttons.map({ (btn) -> DialogCardButton in
                                            let title = btn.title ?? ""
                                            let type = AttachmentElementButtonType(rawValue: btn.type ?? "")
                                            switch type {
                                            case .some(let type):
                                                switch type {
                                                case .postback ,.phoneNumber , .email , .createPost:
                                                    return DialogCardButton(title: title, payload: btn.payload ,type: type)
                                                }
                                            case .none:
                                                return DialogCardButton(title: title, url: btn.url)
                                            }
                                            
                                        })
                                    }
                                    return card
                                })
                                ShowDialog()
                                cancelCard = true
                            } else if let attachUrl = payload.url {
                                switch attachType
                                {
                                case "audio":
                                    dialog.media = DialogMedia(type: .Audio)
                                case "video":
                                    dialog.media = DialogMedia(type: .Video)
                                default:
                                    dialog.media = DialogMedia(type: .Photo)
                                }
                                
                                dialog.media?.url = attachUrl
                            }
                        }
                    }
                }else{
                    NotificationCenter.default.post(name: Constants.NotificationNames.ChangeTextViewKeyboardType,
                                                    object: "Enable")
                }
                
            }
            
            if (!cancelCard)
            {
                self.delegate?.botConnector( didRecieveActivity: dialog)
            }
        }
    }
    
    
//    func parsHumanAgentResponse(model:HumanAgentModel)  {
//        var timestamp:Date? = Date()
//        let dialog = ConversationDialog(by: .bot, time: timestamp)
//        guard model.result?.fulfillment?.count ?? 0 > 0 else {
//            return
//        }
//        if let response  = model.result?.fulfillment?[0] {
//            dialog.message = response.message
//            if let imageUrl =  response.imageUrl {
//                dialog.media = DialogMedia(type: .Photo)
//                dialog.media?.url = imageUrl
//            }
//            self.delegate?.botConnector( didRecieveActivity: dialog)
//        }
//    }
    
    func ShowDialog()
    {
        let dialog = ConversationDialog(by: .bot, time: Date())
        
        if let elements = self.attachmentPayload?.elements
        {
            
            dialog.cards = DialogCards(presentation: .menu)
            dialog.cards?.items = elements.map({ (elm) -> DialogCard in
                
                let card = DialogCard(title: elm.title ?? "")
                
                switch self.attachmentPayload?.image_aspect_ratio ?? ""{
                case "SQUARE" :
                    card.type = .square
                case "HORIZONTAL ","HORIZONTAL" :
                    card.type = .horizontal
                default:
                    break
                }
                
                if card.title.hasPrefix("MENU:")
                {
                    dialog.cards?.presentation = .menu
                    card.title = card.title.replacingOccurrences(of: "MENU:", with: "")
                }
                
                if card.title.hasPrefix("CAROUSEL:")
                {
                    dialog.cards?.presentation = .carousel
                    card.title = card.title.replacingOccurrences(of: "CAROUSEL:", with: "")
                }
                if card.title.hasPrefix("VMENU:")
                {
                    dialog.cards?.presentation = .vmnue
                    card.title = card.title.replacingOccurrences(of: "VMENU:", with: "")
                }
                
                card.imageUrl = elm.image_url
                card.subtitle = elm.subtitle
                
                if let buttons = elm.buttons
                {
                    
                    card.buttons = buttons.map({ (btn) -> DialogCardButton in
                        let title = btn.title ?? ""
                        let type = AttachmentElementButtonType(rawValue: btn.type ?? "")
                        switch type {
                        case .some(let type):
                            switch type {
                            case .postback ,.phoneNumber , .email , .createPost:
                                return DialogCardButton(title: title, payload: btn.payload ,type: type)
                            }
                        case .none:
                            return DialogCardButton(title: title, url: btn.url)
                        }
                    })
                }
                return card
            })
        }
        self.delegate?.botConnector( didRecieveActivity: dialog)
    }
    
    let example:String = """
[
  {
    "message": {
      "metadata": null,
      "attachment": null,
      "quick_replies": null,
      "text": "Hello there, it's BOJI.<br><br>I am going to be your virtual assistant from the Bank of Jordan today<br>I can help you with any the financial services for your account, cards or Bills, also you can check the nearest branches and ATMs"
    },
    "recipient": {
      "id": "387F2299-983B-4007-A2DC-6F8AAEFFD9F4"
    },
    "messaging_type": "RESPONSE"
  },
  {
    "message": {
      "metadata": null,
      "attachment": null,
      "quick_replies": [
        {
          "payload": "",
          "title": "Switch to Arabic",
          "image_url": null,
          "content_type": "text"
        },
        {
          "payload": "",
          "title": "Continue",
          "image_url": null,
          "content_type": "text"
        }
      ],
      "text": "If you want to speak in Arabic you can say Arabic or choose from below, if you'd like to continue in English, you can say or choose Continue"
    },
    "recipient": {
      "id": "387F2299-983B-4007-A2DC-6F8AAEFFD9F4"
    },
    "messaging_type": "RESPONSE"
  }
]
"""
}
