//
//  BaseConnector.swift
//  LabibaBotClient_Example
//
//  Created by Suhayb Ahmad on 8/8/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//



import UIKit
import CoreLocation

protocol BotConnectorDelegate:AnyObject {
    
    func botConnector(_ botConnector:BotConnector, didRecieveActivity activity:ConversationDialog) -> Void
    func botConnector(_ botConnector:BotConnector, didRequestLiveChatTransferWithMessage message:String) -> Void
    func botConnector(_ botConnector:BotConnector, didRequestHumanAgent message:String) -> Void
    func botConnectorDidRecieveTypingActivity(_ botConnector:BotConnector) -> Void
    func botConnectorRemoveTypingActivity(_ botConnector:BotConnector) -> Void
}

protocol BotConnectorInterface:AnyObject {
    
    func botConnector(_ botConnector:BotConnector, didRecieveActivity activity:ConversationDialog) -> Void
    func botConnectorDidRecieveTypingActivity(_ botConnector:BotConnector) -> Void
}

class BotConnector: NSObject {
    
    
    
    
    var currentRequest: DataRequest?
    
    static let shared = BotConnector()
    
    
   
    var userId:String = "2314"
    var conversationId:String!
    var currentToken:String!
    
    weak var delegate:BotConnectorDelegate?
    var activitiesList = [ConversationDialog]()
    
    var clientId:String!
    var scenarioId:String!
    //MARK: Non implemented methodes
    func sendVoice(_ voiceLocalPath:String, completion:@escaping (String?) -> Void) -> Void {}
    
    //MARK: Initializer
    var messageAnalyizer:LabibaRestfulBotConnector!
    //  var sessionManager:SessionManager?
    var opQueue:OperationQueue?
    private override init() {
        super.init()

        messageAnalyizer = LabibaRestfulBotConnector.shared
        
        messageAnalyizer.delegate = self
        
    }
    
    
    
    
    var isTherePendingRequest:Bool = false
    
    func sendMessage(_ message: String? = nil, payload: String? = nil, withAttachments attachments: [[String : Any]]? = nil, withEntities entities: [[String : Any]]? = nil) {
        let pageId = AssistantConfig.config.botId;
        let senderId = AssistantConfig.config.senderId;
        let time = Int(Date().timeIntervalSince1970 * 1000)
        let null = NSNull()
        var filteredMessage = message
        filteredMessage?.removeHiddenCharacters() // there is a hidden chars produced by Speech framework
       
        let msgLoad: [String: Any] = [
            "object": "page",
            "entry": [[
                "id": "221231835260127",
                "time": time,
                "messaging": [[
                    "Id": "00000000-0000-0000-0000-000000000000",
                    "sender": ["id": senderId],
                    "recipient": ["id": pageId],
                    "referral": AssistantConfig.config.referral,
                    "timestamp": time,
                    "message": (filteredMessage == nil && attachments == nil) ? null as Any : [
                        "mid": null,
                        "text": filteredMessage ?? null,
                        "messaging_type": null,
                        "attachments": (attachments ?? null) as Any
                    ] as [String: Any],
                    "postback": [
                        "payload": payload ?? null,
                        "referral": null
                    ] as [String: Any]
                ]]
            ]]
        ]
        
        print("\n***********************************  PARAMETERS  *********************************** \n")
        if let data = try? JSONSerialization.data(withJSONObject: msgLoad, options: .prettyPrinted)
        {
            print(String(data: data, encoding: .utf8)!)
        }
        print("\n*********************************** END PARAMETERS ***********************************\n")
      
            sendData(parameters: msgLoad)

        self.delegate?.botConnectorDidRecieveTypingActivity(self)
        AssistantConfig.config.resetReferral()
        NotificationCenter.default.post(name: Constants.NotificationNames.ChangeTextViewKeyboardType,object:nil) // to rest keyboard content type
    }
    
    func removeEmptyStringsOrNulls(jsonData: [String: Any]) -> [String: Any] {
      var newJsonData = [String: Any]()
      for (key, value) in jsonData {
        if value is String {
          if (value as! String) == ""  {
            continue
          }
        }
          if  value is NSNull {
              continue
          }
          if value is [String:Any?] || value is [String:Any] {
              print("Value_________\(value)" )
              print("Key_________\(key)" )
              
               let temp  = removeEmptyStringsOrNulls(jsonData: value as! [String:Any])
             
              if temp.isEmpty {
                 continue
              }
              newJsonData[key]  = temp
              continue
          }
          if value is [[String:Any?]] || value is [[String:Any]] {
              var entity :[[String:Any]] = []
              for item in (value as! [[String:Any]]){
                   let vl = removeEmptyStringsOrNulls(jsonData: item as [String:Any])

                  entity.append(vl)
              }
              newJsonData[key] = entity
              continue
          }
          
          if value is [String:Any] {
              if (value as! [String:Any]).isEmpty {
                  newJsonData[key] = NSNull()
                  newJsonData[key] = removeEmptyStringsOrNulls(jsonData: value as! [String:Any])
              }
          }
          

        newJsonData[key] = value
      }
        
        return newJsonData
    }
    
    func startConversation() {
        // showLoadingIndicator()
       // LocalCache.shared.conversationId = SharedPreference.shared.currentUserId
//        if SharedPreference.shared.isHumanAgentStarted {
//            WebViewEventHumanAgent.Shared.forceEnd()
//        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            CircularGradientLoadingIndicator.show()
        }
        self.sendMessage("CONVERSATION-RELOAD")
    }
    
    
    
    func sendData(parameters:[String:Any])  {
        isTherePendingRequest = true
         let p = removeEmptyStringsOrNulls(jsonData: parameters)
        if let data = try? JSONSerialization.data(withJSONObject: p, options: .prettyPrinted)
        {
            print(String(data: data, encoding: .utf8)!)
        }
        DataSource.shared.messageHandler(model: p) { result in
            CircularGradientLoadingIndicator.dismiss()
            switch result {
            case .success(let model):
                self.delegate?.botConnectorRemoveTypingActivity(self)
                self.messageAnalyizer.parseResponse(response: model)

            case .failure(let err):
                print(err.localizedDescription)
                showErrorMessage(err.localizedDescription)
                self.delegate?.botConnectorRemoveTypingActivity(self)
            }
            self.isTherePendingRequest = false
        }
        
    }
    

    
    func sendPhoto(_ photo: UIImage)
    {
        if let data = photo.jpegData(compressionQuality: 0.8)
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.delegate?.botConnectorDidRecieveTypingActivity(self)
            }
            let model = UploadDataModel(data: data, fileName: "photo.jpg", mimeType: "image/jpeg")
            DataSource.shared.uploadData(model: model) { result in
                switch result {
                case .success(let model):
                    if (model.urls?.count ?? 0) > 0, let link = model.urls?[0] {
                        self.sendMessage(withAttachments: [
                            [
                                "type": "image",
                                "payload": ["url": link]
                            ]
                        ])
                    }else {
                        self.sendMessage("Failure")
                    }
                case .failure(let err):
                    print(err.localizedDescription)
                    showErrorMessage(err.localizedDescription)
                    self.delegate?.botConnectorRemoveTypingActivity(self)
                }
            }
        }
    }
    
    
    func sendFile(_ url: URL) {
        if let data = try? Data(contentsOf: url)
        {
            self.delegate?.botConnectorDidRecieveTypingActivity(self)
            let model = UploadDataModel(data: data, fileName: url.lastPathComponent, mimeType: url.mimeType)
            DataSource.shared.uploadData(model: model){ result in
                switch result {
                case .success(let model):
                    if (model.urls?.count ?? 0) > 0, let link = model.urls?[0] {
                        if let fileURL = URL(string: link) {
                            let dialog = ConversationDialog(by: .user, time: Date())
                            dialog.attachment = AttachmentCard(link: link)
                            self.delegate?.botConnector(self, didRecieveActivity: dialog)
                            self.sendMessage(withAttachments: [
                                [
                                    "type": fileURL.isImage() ?  "image":"file",
                                    "payload": ["url": link]
                                ]
                            ])
                        }
                    }else {
                        self.sendMessage("Failure")
                    }
                case .failure(let err):
                    print(err.localizedDescription)
                    showErrorMessage(err.localizedDescription)
                    self.delegate?.botConnectorRemoveTypingActivity(self)
                }
                
            }
        }
    }
    
    func getLastBotResponse()  {
        self.delegate?.botConnectorDidRecieveTypingActivity(self)
        
        DataSource.shared.getLastBotResponse { response in
            //self.loader.dismiss()
            switch response {
            case .success(let model):
                if let labibaModel = model.lastBotResponse {
                    self.messageAnalyizer.parseResponse(response: labibaModel)
                }
            case .failure(let err):
                print(err.localizedDescription)
                showErrorMessage(err.localizedDescription)
                self.delegate?.botConnectorRemoveTypingActivity(self)
            }
        }
    }
    
    func resumeConnection() {
        if isTherePendingRequest {
            isTherePendingRequest = false
            currentRequest?.cancel()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.getLastBotResponse()
            }
            
        }
    }
    
    func sendLocation(_ location: CLLocationCoordinate2D) {
        let attachment =
        [["payload":["coordinates":[
            "lat":location.latitude ,
            "long" :location.longitude]],
          "type":"location"]]
        self.sendMessage(withAttachments :attachment)
    }
    //MARK: Implemented methodes
    
    func ShowDialog(){
        messageAnalyizer.ShowDialog()
    }
    
    
    
}



//extension BotConnector:LocationServiceDelegate {
//    func locationService(_ service: LocationService, didReceiveLocation location: CLLocationCoordinate2D) {
//        sendLocation(location)
//    }
//}

extension BotConnector: URLSessionDelegate {
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        //Trust the certificate even if not valid
        let urlCredential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
        
        completionHandler(.useCredential, urlCredential)
    }
}

extension BotConnector : MessageAnalyizerDelegate {
    func botConnector(didRecieveActivity activity: ConversationDialog) {
        delegate?.botConnector(self, didRecieveActivity: activity)
    }
    
    func botConnector(didRequestLiveChatTransferWithMessage message: String) {
        delegate?.botConnector(self, didRequestLiveChatTransferWithMessage: message)
    }
    
    func botConnector(didRequestHumanAgent message: String) {
        delegate?.botConnector(self, didRequestHumanAgent: message)
    }
    
    func botConnectorDidRecieveTypingActivity() {
        delegate?.botConnectorRemoveTypingActivity(self)
    }
    
    func botConnectorRemoveTypingActivity() {
        delegate?.botConnectorRemoveTypingActivity(self)
    }
    func sendGetStarted() {
        self.sendMessage("get started")
    }
}
