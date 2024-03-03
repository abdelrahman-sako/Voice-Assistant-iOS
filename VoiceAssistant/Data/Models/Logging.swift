////
////  Logging.swift
////  LabibaBotFramwork
////
////  Created by Abdulrahman Qasem on 01/12/2022.
////  Copyright © 2022 Abdul Rahman. All rights reserved.
////
//
//import Foundation
//class Logging {
//    static let shared = Logging()
//    private init(){
//        
//    }
//    enum LoggingTag:String {
//        case messaging         = "MESSAGING"
//        case lastMessage       = "GET_LAST_MESSAGE"
//        case upload            = "UPLOAD_FILES"
//        case voice             = "VOICE"
//        case downloadVoiceClip = "DOWNLOAD_VOICE_CLIP"
//        case ratingQuestions   = "GET_RATING_QUESTIONS"
//        case ratingSubmit      = "SUBMIT_RATING"
//        case help              = "HELP"
//        case prechatForm       = "PRECHAT_FORM"
//        case upadateToken      = "UPDATE_TOKEN"
//        
//        var exception:String {
//            return rawValue + "_ERROR"
//        }
//        
//        var normal:String {
//            return rawValue
//        }
//    }
//    
//    // Log Success Case
//    func logSuccessCase(url:String,headers:String? = nil,tag:LoggingTag,method:HTTPMethod,parameter:String ,response:String)  {
//        guard Labiba.Logging.isSuccessLoggingEnabled else {
//            return
//        }
//        log(url: url, tag: tag, method: method, parameter: parameter, response: response,exception: "Success")
//    }
//    
//    func log(url:String,headers:String? = nil,tag:LoggingTag,method:HTTPMethod,parameter:String ,response:String,exception:String? = nil) {
//        var encodedExeption = exception
//        guard Labiba.Logging.isEnabled else {
//            return
//        }
//        UIDevice.current.isBatteryMonitoringEnabled = true
//        let deviceDetails:String = """
//ModelName: \(UIDevice.modelName)
//SystemName: \(UIDevice.current.systemName)
//SystemVersion: \(UIDevice.current.systemVersion)
//Model: \(UIDevice.current.model)
//BatteryLevel: \(UIDevice.current.batteryLevel*100)%
//"""
//        var requestDetails:String = """
//URL: \(url)
//Method: \(method.rawValue)
//Headers:\(headers ?? "")
//Body: \(parameter)
//"""
//        let userDetails:String = """
//SenderID: \(Labiba._senderId ?? "")
//RecepientID: \(Labiba._pageId)
//"""
//        var filteredRespose = response
//        if filteredRespose.range(of: "<[a-z][\\s\\S]*>", options: .regularExpression, range: nil, locale: nil) != nil
//            && exception != nil {
//            // exception != nil : this condition is to pass the ssml part in successful requests
//            //  romove  HTML tags in the following line because server may consider HTML as an attack code:403
//            filteredRespose = "HTML response" + filteredRespose.replacingOccurrences(of: "<", with: "").replacingOccurrences(of: ">", with: "")
//        }
//        
//        if Labiba.loggingAndRefferalEncodingType == .base64 {
//            requestDetails = requestDetails.toBase64()
//            filteredRespose = filteredRespose.toBase64()
//             encodedExeption = encodedExeption?.toBase64()
//        }
//        
//        let model = LoggingModel(Tag: exception == nil ? tag.normal : tag.exception,
//                                 DeviceDetails: deviceDetails,
//                                 UserDetails: userDetails,
//                                 Request: requestDetails,
//                                 Response: filteredRespose,
//                                 Exception: encodedExeption ?? "",
//                                 SDKVersion: Labiba.version)
//        
//        let data = try! JSONEncoder().encode(model)
//        prettyPrintedResponse(data: data)
//        DataSource.shared.sendLog(model: model) { _ in}
//    }
//}
//
