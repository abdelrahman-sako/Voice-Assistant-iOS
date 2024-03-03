//
//  WaselRemoteDataSource.swift
//  TiaIOS
//
//  Created by Abdul Rahman on 1/27/19.
//  Copyright © 2019 NSIT. All rights reserved.
//

import Foundation

class RemoteDataSource:RemoteDataSourceProtocol{
    
    

    func uploadData(model: UploadDataModel, handler: @escaping Handler<UploadDataResponseModel>) {
        
        let url = "\(AssistantConfig.config.uploadURL ?? "")?id=\(SharedPreference.shared.getCurrentUserId())"
        let endPoint = EndPoint(url: url, httpMethod: .post)
        remoteContext.multipartRequest(endPoint: endPoint, params: nil, multipartName: "", uploadFiles: [model.data], mimeType: model.mimeType,fileName: model.fileName) { result in
            switch  result {
            case .success(let data):
                self.parser(data: data, model: UploadDataResponseModel.self, handler: handler)
               // let dataString = String(data: data, encoding: .utf8) ?? ""
             //   Logging.shared.logSuccessCase(url: url, tag: .upload, method: .post, parameter: "", response: dataString)
            case .failure(let error):
                handler(.failure(error))
               // Logging.shared.log(url: url, tag: .upload, method: .post, parameter: "", response: error.response,exception: error.logDescription)
            }
        }
    }
    
    
    
    func getLastBotResponse(handler: @escaping Handler<LastBotResponseModel>) {
        let url = AssistantConfig.config.lastBotMessageUrl
        let endPoint = EndPoint(url: url, httpMethod: .get)
        
        let params:[String:String] = [
            "RecepientID" :AssistantConfig.config.botId,
            "SenderID":AssistantConfig.config.senderId
        ]
        remoteContext.withTokenRequest(endPoint: endPoint, parameters: params) { result in
            switch  result {
            case .success(let data):
                self.parser(data: data, model: LastBotResponseModel.self, handler: handler)
               // let dataString = String(data: data, encoding: .utf8) ?? ""
                //Logging.shared.logSuccessCase(url: url, tag: .lastMessage, method: .get, parameter: params.description, response: dataString)
            case .failure(let error):
                handler(.failure(error))
//                Logging.shared.log(url: url, tag: .lastMessage, method: .get, parameter: params.description, response: error.response,exception: error.logDescription)
            }
        }
    }
    
    func closeConversation(handler: @escaping Handler<[String]>) {
        //api/LiveChat/v1.0/CloseConversation/\(Labiba._pageId)/\(Labiba._senderId ?? "")/mobile
        
        let url = AssistantConfig.config.closeConversationUrl
        let endPoint = EndPoint(url: url, httpMethod: .post)
        
        remoteContext.request(endPoint: endPoint, parameters: "") { result in
            switch  result {
            case .success(let data):
                self.parser(data: data, model: [String].self, handler: handler)
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
    
    //    func updateToken(handler: @escaping Handler<UpdateTokenModel>) {
    //        let url = "\(Labiba._basePath)/api/Auth/Login"
    //        let endPoint = EndPoint(url: url, httpMethod: .post)
    //        let params:[String:Any] = [
    //            "Username":Labiba.jwtAuthParamerters.username,
    //            "Password":Labiba.jwtAuthParamerters.password
    //        ]
    //        remoteContext.request(endPoint: endPoint, parameters: params) { result in
    //            switch  result {
    //            case .success(let data):
    //                self.parser(data: data, model: UpdateTokenModel.self, handler: handler)
    //            case .failure(let error):
    //                handler(.failure(error))
    //            }
    //        }
    //    }
    
    func messageHandler(model: [String : Any], handler: @escaping Handler<[LabibaModel]>) {
        let url = AssistantConfig.config.messegingUrl
        
        let endPoint = EndPoint(url: url, httpMethod: .post,headers: ["Content-Type":ContentType.json.rawValue])
        let params = model
        if !AssistantConfig.config.base64Enabbled {
            remoteContext.withTokenRequest(endPoint: endPoint, parameters: params) { result in
                switch  result {
                case .success(let data):
                    self.parser(data: data, model: [LabibaModel].self, handler: handler)

                case .failure(let error):
                    handler(.failure(error))
                }
                
            }
        }else{
            remoteContext.withTokenRequest(endPoint: endPoint, parameters: params.toBase64()) { result in
                switch  result {
                case .success(let data):
                    self.parserBase64(data: data, model: [LabibaModel].self, handler: handler)
                    //let dataString = String(data: data, encoding: .utf8) ?? ""
//                    Logging.shared.logSuccessCase(url: url, tag: .messaging, method: .post, parameter: params.description, response: dataString)
                case .failure(let error):
                    handler(.failure(error))
//                    Logging.shared.log(url: url, tag: .messaging, method: .post, parameter: params.description, response: error.response,exception: error.logDescription)
                }
            }
        }
        
        
    }
    
//    func getRatingQuestions(handler: @escaping Handler<[GetRatingFormQuestionsModel]>) {
//        let url = "\(Labiba._basePath)/api/MobileAPI/FetchQuestions"
//        let endPoint = EndPoint(url: url, httpMethod: .get)
//        let params:[String:Any] = [
//            "bot_id" : SharedPreference.shared.currentUserId
//        ]
//        remoteContext.withTokenRequest(endPoint: endPoint, parameters: params) { result in
//            switch  result {
//            case .success(let data):
//                self.parser(data: data, model: [GetRatingFormQuestionsModel].self, handler: handler)
//                let dataString = String(data: data, encoding: .utf8) ?? ""
//                Logging.shared.logSuccessCase(url: url, tag: .ratingQuestions, method: .post, parameter: params.description, response: dataString)
//            case .failure(let error):
//                handler(.failure(error))
//                Logging.shared.log(url: url, tag: .ratingQuestions, method: .post, parameter: params.description, response: error.response,exception: error.logDescription)
//            }
//        }
//    }
    
//    func submitRating(ratingModel: SubmitRatingModel, handler: @escaping Handler<SubmitRatingResponseModel>) {
//        let url = "\(Labiba._basePath)/api/ratingform/submit"
//        let endPoint = EndPoint(url: url, httpMethod: .post)
//        let params = ratingModel.dictionary
//        
//        remoteContext.withTokenRequest(endPoint: endPoint, parameters: params) { result in
//            switch  result {
//            case .success(let data):
//                self.parser(data: data, model: SubmitRatingResponseModel.self, handler: handler)
//                let dataString = String(data: data, encoding: .utf8) ?? ""
//                Logging.shared.logSuccessCase(url: url, tag: .ratingSubmit, method: .post, parameter: params.description, response: dataString)
//            case .failure(let error):
//                handler(.failure(error))
//                Logging.shared.log(url: url, tag: .ratingSubmit, method: .post, parameter: params.description, response: error.response,exception: error.logDescription)
//            }
//        }
//    }
    
    
//    func getHelpPageData(handler: @escaping Handler<HelpPageModel>) {
//        let url = Labiba._helpUrl
//        let endPoint = EndPoint(url: url, httpMethod: .get)
//        let params:[String:Any] = [
//            "bot_id" : SharedPreference.shared.currentUserId
//        ]
//        
//        remoteContext.withTokenRequest(endPoint: endPoint, parameters: params) { result in
//            switch  result {
//            case .success(let data):
//                self.parser(data: data, model: HelpPageModel.self, handler: handler)
//                let dataString = String(data: data, encoding: .utf8) ?? ""
//                Logging.shared.logSuccessCase(url: url, tag: .help, method: .post, parameter: params.description, response: dataString)
//            case .failure(let error):
//                handler(.failure(error))
//                Logging.shared.log(url: url, tag: .help, method: .post, parameter: params.description, response: error.response,exception: error.logDescription)
//            }
//        }
//    }
    
    
//    func getPrechatForm(handler: @escaping Handler<[PrechatFormModel]>) {
//        let url =  "\(Labiba._basePath)\(Labiba._prechatFormServicePath)"
//        let endPoint = EndPoint(url: url, httpMethod: .post)
//        let params:[String:Any] = [
//            "bot_id" : SharedPreference.shared.currentUserId
//        ]
//        
//        remoteContext.withTokenRequest(endPoint: endPoint, parameters: params) { result in
//            switch  result {
//            case .success(let data):
//                self.parser(data: data, model: [PrechatFormModel].self, handler: handler)
//                let dataString = String(data: data, encoding: .utf8) ?? ""
//                Logging.shared.logSuccessCase(url: url, tag: .prechatForm, method: .post, parameter: params.description, response: dataString)
//            case .failure(let error):
//                handler(.failure(error))
//                Logging.shared.log(url: url, tag: .prechatForm, method: .post, parameter: params.description, response: error.response,exception: error.logDescription)
//            }
//        }
//    }
    
    func textToSpeech(model: TextToSpeechModel, handler: @escaping Handler<TextToSpeachResponseModel>) {
        let url =  AssistantConfig.config.textToSpeachUrl
        let endPoint = EndPoint(url: url, httpMethod: .post)
        
        let params:[String:Any] = [
            "text":AssistantConfig.config.base64Enabbled  ? model.text.toBase64() : model.text,
            "voicename" : model.googleVoice.voicename,
            "clientid" : model.clientid,
            "language" : model.googleVoice.language,
            "isSSML":"\(model.isSSML)",
            "type": "\(model.isBase64)"
        ]
        
        
        remoteContext.withTokenRequest(endPoint: endPoint, parameters: params) { result in
            switch  result {
            case .success(let data):
                self.parser(data: data, model: TextToSpeachResponseModel.self, handler: handler)
                let dataString = String(data: data, encoding: .utf8) ?? ""
//                Logging.shared.logSuccessCase(url: url, tag: .voice, method: .post, parameter: params.description, response: dataString)
            case .failure(let error):
                handler(.failure(error))
//                Logging.shared.log(url: url, tag: .voice, method: .post, parameter: params.description, response: error.response,exception: error.logDescription)
            }
        }
        
    }
    
//    func sendLog(model: LoggingModel, handler: @escaping Handler<Bool>) {
//        let url =  "\(Labiba._basePath)\(Labiba._loggingServicePath)"
//        let endPoint = EndPoint(url: url, httpMethod: .post)
//        
//        let params = model.dictionary
//        
//        //        if Labiba.loggingAndRefferalEncodingType == .base64 {
//        //            remoteContext.request(endPoint: endPoint, parameters: "\"\(params.toBase64()!)\"") { result in
//        //                switch result {
//        //                case .success(_):
//        //                    print("log success")
//        //                case .failure(let error):
//        //                    print("log faild with error: \(error.localizedDescription)")
//        //                }
//        //            }
//        //        }else{
//        remoteContext.request(endPoint: endPoint, parameters: params) { result in
//            switch result {
//            case .success(_):
//                print("log success")
//            case .failure(let error):
//                print("log faild with error: \(error.localizedDescription)")
//            }
//        }
//        //        }
//        
//    }
    
    func downloadFile(fileURL: URL, handler: @escaping Handler<URL>)-> AnyCancelable {
        return remoteContext.downLoad(url: fileURL) { result in
            switch result {
            case .success(let url):
                handler(.success(url))
//                Logging.shared.logSuccessCase(url:  fileURL.absoluteString, tag: .downloadVoiceClip, method: .get, parameter: "No Parameters", response: url.absoluteString)
            case .failure(let error):
                handler(.failure(error))
//                Logging.shared.log(url: fileURL.absoluteString, tag: .downloadVoiceClip, method: .get, parameter: "No Parameters", response: error.response,exception: error.logDescription)
            }
        }
    }
    
    
    
    
    
    //MARK: - Close All Session Tasks
    
    func close() {
        remoteContext.close()
    }
    
    
    
    //MARK: - Parsers
    
    private func parser<T:Decodable>(data:Data,model:T.Type, handler: @escaping Handler<T>) {
        
        let decoder =  JSONDecoder()
        do {
            let model = try decoder.decode(T.self, from: data)
            
            handler(.success(model))
        } catch {
            //  handler(.failure(ErrorModel(message: error.localizedDescription)))
            handler(.failure(LabibaError(error: error, statusCode: 200)))
        }
    }
    
    
    private func parserBase64<T:Decodable>(data:Data,model:T.Type, handler: @escaping Handler<T>) {
        
        let decoder =  JSONDecoder()
        do {
            if let base64Response = String(data: data, encoding: .utf8) {
                let refactoredBase64 = base64Response.replacingOccurrences(of: "\"", with: "")
                
                let response = refactoredBase64.base64URLDecode()
                if let response {
                    let model = try decoder.decode(T.self, from: response)
                    handler(.success(model))
                    return
                }
                
                handler(.failure(LabibaError(error: ErrorModel(message: "Error"), statusCode: 200)))
               
            }
            
            handler(.failure(LabibaError(error: ErrorModel(message: "Error"), statusCode: 200)))
            
        } catch {
            //  handler(.failure(ErrorModel(message: error.localizedDescription)))
            handler(.failure(LabibaError(error: error, statusCode: 200)))
        }
    }
    
    //MARK: - Properties
    lazy var remoteContext = RemoteContext()
    
}


func getHeaders(withToken:Bool = true) -> [String : String]{
    var headers = [String : String]()
    headers["Content-Type"] = "application/json"
    // headers["device-Key"] = "3c754e4987ea1dc515eh8a01a10583ff"
    return headers
}

