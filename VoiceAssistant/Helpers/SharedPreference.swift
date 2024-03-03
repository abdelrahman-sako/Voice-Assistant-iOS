//
//  SharedPreference.swift
//  Wasel
//
//  Created by Abdul Rahman on 6/15/19.
//  Copyright © 2019 Abdul Rahman. All rights reserved.
//

import Foundation

class SharedPreference{
    
    private enum Keys : String {
        case botLangCode = "botCode"
        case userIdAR = "userIdAR"
        case userIdEN = "userIdEN"
        case userIdDE = "userIdDE"
        case userIdRU = "userIdRU"
        case userIdZH = "userIdZH"
        case jwt = "jwt"
        case senderId = "senderId"
    }
    
    
    
    static var shared = SharedPreference()
    private var standered = UserDefaults.standard
    
    private init(){}
    
    var botLangCode:LabibaLanguages{
        get{
            if let lang = standered.string(forKey: Keys.botLangCode.rawValue) {
                return LabibaLanguages(rawValue:lang) ?? .en
            }
            return LabibaLanguages.en
        }
        
        set {
            standered.set(newValue.rawValue, forKey: Keys.botLangCode.rawValue)
        }
    }
    
    var jwt:String {
        get {
            return standered.object(forKey: Keys.jwt.rawValue) as? String ?? ""
        }
        set {
            standered.set(newValue, forKey: Keys.jwt.rawValue)
        }
    }
    
    var senderId:String {
        get {
            return standered.object(forKey: Keys.senderId.rawValue) as? String ?? ""
        }
        set {
            standered.set(newValue, forKey: Keys.senderId.rawValue)
        }
    }
    
    

    
    func getCurrentUserId()-> String{
        var currentLanguageCode = SharedPreference.shared.botLangCode
        switch currentLanguageCode {
        case .ar:
            return standered.object(forKey: Keys.userIdAR.rawValue) as? String ?? "en"

        case .en:
            return standered.object(forKey: Keys.userIdEN.rawValue) as? String ?? "en"
        case .de:
            return standered.object(forKey: Keys.userIdDE.rawValue) as? String ?? "en"

        case .ru:
            return standered.object(forKey: Keys.userIdRU.rawValue) as? String ?? "en"

        case .zh:
            return standered.object(forKey: Keys.userIdZH.rawValue) as? String ?? "en"

        }
    }
   

    
    func setUserIDs(ar:String , en:String , de:String = "" , ru:String = "" , zh:String = "")  {
        standered.set(ar, forKey: Keys.userIdAR.rawValue)
        standered.set(en, forKey: Keys.userIdEN.rawValue)
        if !de.isEmpty {standered.set(de, forKey: Keys.userIdDE.rawValue)}
        if !ru.isEmpty {standered.set(ru, forKey: Keys.userIdRU.rawValue)}
        if !zh.isEmpty {standered.set(zh, forKey: Keys.userIdZH.rawValue)}
    }
}
