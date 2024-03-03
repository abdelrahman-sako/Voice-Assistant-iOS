//
//  VoiceAssistantViewModel.swift
//  Voice Assistant
//
//  Created by Osama Hasan on 15/01/2024.
//

import Foundation


class VoiceAssistantViewModel : NSObject {
    var messages : [ConversationDialog] = []
    
    var botConnector:BotConnector = BotConnector.shared

    var isTyping = false
    var onReceiveData:(()->Void)?
    var onInsert:(()->Void)?
    var onRemove:(()->Void)?
    var onSendData:(()->Void)?
    var createPost:(([String:Any])->Void)?
    
    var ttsManager = TextToSpeechManeger.Shared
    
    var willBeAddedQueue: [ConversationDialog] = []
    
    override init() {
        super.init()
        botConnector.delegate = self
        ttsManager.delegate = self
    }

    func startConversation(){
        botConnector.sendMessage("CONVERSATION-RELOAD")
    }
    
    func sendMessage(message:String){
        let dialog = ConversationDialog(by: .user)
        dialog.message = message
        messages.append(dialog)
        botConnector.sendMessage(message)
        onSendData?()

        
    }
    
    func stopVoice(){
        ttsManager.stop()
    }
    
    func stringJSONToDictionary(jsonString:String) -> [String:Any]?{
        // Convert JSON string to Data
        guard let jsonData = jsonString.data(using: .utf8) else {
            return nil
        }

        // Convert Data to [String: Any]
        do {
            if let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                return dictionary
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
    
    
    func handleCreatePost(activity: ConversationDialog){
        if let items =  activity.cards?.items,items.contains(where: {$0.buttons.contains(where: {$0.type == .createPost})}){
            guard let payload = items.first?.buttons.first?.payload,let dictionary = stringJSONToDictionary(jsonString: payload) else{
                return
            }
            
            createPost?(dictionary)
        }
    }
}

extension VoiceAssistantViewModel : BotConnectorDelegate {
    func botConnector(_ botConnector: BotConnector, didRecieveActivity activity: ConversationDialog) {
       
        
        
        
        if(messages.contains(where: {$0.party == .bot})){
            willBeAddedQueue.append(activity)
            return
        }
        

        
        if let message = activity.message {
            AssistantConfig.config.setLastMessageLangCode(message)
            TextToSpeechManeger.Shared.append(dialog: activity)
            messages.append(activity)
            onReceiveData?()
        }
        
        handleCreatePost(activity: activity)
        
        
    }
    
    func botConnector(_ botConnector: BotConnector, didRequestLiveChatTransferWithMessage message: String) {
        
    }
    
    func botConnector(_ botConnector: BotConnector, didRequestHumanAgent message: String) {
        
    }
    
    func botConnectorDidRecieveTypingActivity(_ botConnector: BotConnector) {
     
        let typing = ConversationDialog(by: .bot,isTyping: true)
        messages.append(typing)
        onReceiveData?()
    }
    
    func botConnectorRemoveTypingActivity(_ botConnector: BotConnector) {
       messages = []
       onReceiveData?()
    }
    
    
}


extension VoiceAssistantViewModel :TextToSpeechDelegate {
    func textToSpeechDidStart() {
        
    }
    
    func textToSpeechDidStop() {
        if let item =  willBeAddedQueue.first{
            messages = []
            messages.append(item)
            ttsManager.append(dialog: item)
            willBeAddedQueue.removeFirst()
            handleCreatePost(activity: item)
            onReceiveData?()
        }
    }
    
    
}
