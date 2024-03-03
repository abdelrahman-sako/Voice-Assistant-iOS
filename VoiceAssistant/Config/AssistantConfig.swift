//
//  AssistantConfig.swift
//  Voice Assistant
//
//  Created by Osama Hasan on 15/01/2024.
//

import Foundation
import UIKit

public class AssistantConfig {
    
    
    private init(){}
    
    
    private(set) static var config: ClientConfig!
    private(set) static var loaderTheme =  LoaderTheme()
    private(set) static var micViewTheme =  VoiceAssistantViewTheme()
    private(set) static var botViewheme =  BotChatViewTheme()
    private(set) static var userViewTheme =  UserChatViewTheme()
    private(set) static var sheetViewTheme =  SheetTheme()
    
    
    public static func setClientConfig(configration:ClientConfig){
        config = configration
    }
    

    
    public static func setLoaderTheme(theme:LoaderTheme){
        loaderTheme = theme
    }
    
    public static func setBotViewTheme(theme:BotChatViewTheme){
        botViewheme = theme
    }
    public static func setUserViewTheme(theme:UserChatViewTheme){
        userViewTheme = theme
    }
    public static func setMicViewTheme(theme:VoiceAssistantViewTheme){
        micViewTheme = theme
    }
    
    public static func setSheetViewTheme(theme:SheetTheme){
        sheetViewTheme = theme
    }
    
    public static func setVoiceMan(ar:String? ,en:String?){
        let voice = Voice()
        if let  ar {
            voice.voiceManAR = ar
        }
        if let en {
            voice.voiceManEN = en
        }
        config.voices = voice
    }
    
    
    
}

public class ClientConfig {
    public let baseURL: String
    public let messagingEndPoint: String
    public let voiceEndPoint: String
    public var uploadURL: String? = ""
    public let voiceURL: String
    public let updateTokenURL: String? = ""
    
    public var base64Enabbled : Bool = false
    public let temporaryBotType : BotType = .keyboardType
    public var timeoutInterval: TimeInterval = 60.0
    public var listeningDuration:Double = 2
    public var voices = Voice()
    var referral:[String:Any] = ["ref":"[{\"source\":\"mobile\"}]","source":"","type":""]
    private var _lastMessageLangCode = "en"
    
   

    public var font:(regAR:String , boldAR:String , regEN:String , boldEN:String)? =  ( "ChalkboardSE-Light", "ChalkboardSE-Bold",  "ChalkboardSE-Light", "ChalkboardSE-Bold")
    
    public var bypassSSLCertificateValidation:Bool = false
    
    public init(baseURL: String, messagingEndPoint: String, voiceEndPoint: String, voiceURL: String, botIdAR: String, botIdEN: String) {
        self.baseURL = baseURL
        self.messagingEndPoint = messagingEndPoint
        self.voiceEndPoint = voiceEndPoint
        self.voiceURL = voiceURL
        SharedPreference.shared.setUserIDs(ar: botIdAR, en: botIdEN)
        
    }
    
    public func setBotLanguage(LangCode:LabibaLanguages){
        SharedPreference.shared.botLangCode = LangCode
    }
    
    public func setLastMessageLangCode(_ text: String)
    {
        _lastMessageLangCode = text.detectedLangauge() ?? "en"
    }
}

extension ClientConfig {
    
    public var lastMessageLangCode:String{
        get{
            return _lastMessageLangCode
        }
    }
    
    var botId:String{
        get{
            return SharedPreference.shared.getCurrentUserId()
        }
    }
    
    var messegingUrl:String{
        get{
            return "\(baseURL)\(messagingEndPoint)"
        }
    }
    
    var textToSpeachUrl:String{
        get{
            return "\(voiceURL)\(voiceEndPoint)"
        }
    }
    
    var lastBotMessageUrl:String{
        get{
            return "\(baseURL)/api/getLastBotResponse"
        }
    }
    
    var closeConversationUrl:String{
        get{
            return  "\(baseURL)/api/LiveChat/v1.0/CloseConversation/\(botId)/\(senderId)/mobile"
            
        }
    }
    
    var senderId : String{
        get{
            if SharedPreference.shared.senderId.isEmpty{
                let uuid = UUID().uuidString
                SharedPreference.shared.senderId = uuid
                return uuid
            }
            return SharedPreference.shared.senderId
        }
    }
    
    
    var audioType : Int{
        get{
            return base64Enabbled ? 1 : 2
        }
    }
}

extension ClientConfig {
    public  func setUserParams( first_name:String? = nil , last_name:String? = nil , profile_pic:String? = nil , gender:String? = nil , location:String? = nil, country:String? = nil , username:String? = nil , email:String? = nil , token:String? = nil , customParameters:[String:String]? = nil){
        //   let access_token = SharedPreference.shared.refreshToken
        let model = RefModel(access_token: "", clientfirstname: first_name, clientlastname: last_name, clientprofilepic: profile_pic, clientgender: gender, client_location: location, client_country: country, client_username: username, client_email: email, token: token , customParameters: customParameters)
        referral = ReferralModel(ref: model.arrayJsonString()).modelAsDic()
    }
    
    
    public func resetReferral() {
        createCustomReferral(object: nil)
    }
    
    public func createCustomReferral(object:[String:Any]?) {
        let model = RefModel()
        referral = ReferralModel(ref: model.customRefModel(object: object)).modelAsDic()
    }
}

public class LoaderTheme{
    public var loaderText:String = "تحميل..."
    public var color:UIColor = .black
}


public class Voice {
    public init() {
        
    }
    public var voiceManAR:String = "ar-XA-Wavenet-A"
    public var voiceManEN :String = "en-US-Wavenet-F"
    public var voiceRateEN :Float = 0.7
    public var VoiceRateAR :Float = 0.7
    public var enableAutoListening :Bool = false
}

// MARK: - Classes
public class GradientSpecs: NSObject
{
    public var colors: [UIColor]
    public var locations: [CGFloat]
    public var start: CGPoint
    public var end: CGPoint
    public var viewBackgroundColor: UIColor?
    
    public init(colors: [UIColor], locations: [CGFloat], start: CGPoint, end: CGPoint , viewBackgroundColor:UIColor? = nil)
    {
        self.colors = colors
        self.locations = locations
        self.start = start
        self.end = end
        self.viewBackgroundColor = viewBackgroundColor
    }
}


public class TextStyle {
    
    public var font:UIFont?
    public var color:  UIColor = .black
    public init(){}
    
    public init(font:UIFont? = nil,color:UIColor = .black) {
        self.font = font
        self.color = color
    }

}

public class ViewStyle{
    public var corners:CACornerMask = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    public var radius:CGFloat = 25
    public var backgroundColor : UIColor = .white
    public var tintColor:UIColor = .clear
    
    public init(){}
    public init(radius: CGFloat = 0, backgroundColor: UIColor = .black, tintColor: UIColor = .clear,corners:CACornerMask = [.layerMinXMinYCorner, .layerMaxXMinYCorner]) {
        self.radius = radius
        self.backgroundColor = backgroundColor
        self.tintColor = tintColor
        self.corners = corners
    }
}


public class VoiceAssistantViewTheme{
    public var viewStyle = ViewStyle()
    public var image:UIImage?
    public var waveColors:[UIColor] = [.black]
    public init(){}
}


public class UserChatViewTheme{
    public var viewStyle = ViewStyle()
    public var textStyle = TextStyle()
    public init(){}

}

public class BotChatViewTheme{
    public var viewStyle = ViewStyle()
    public var defualtTextStyle = TextStyle()
    public var scallTextStyle = TextStyle()
    public init(){}

}


public class SheetTheme {
    public var viewStyle = ViewStyle()
    
}
