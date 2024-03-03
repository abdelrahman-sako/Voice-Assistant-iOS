//
//  Language.swift
//  LabibaBotClient_Example
//
//  Created by Suhayb Ahmad on 8/8/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation

func localString(_ key: String) -> String
{

    return key.localForChosnLangCodeBB
}

extension String
{

//   public var local:String {
//    let language = Language.current
//    let path = Bundle.main.path(forResource: language, ofType: "lproj")!
//    let bundle = Bundle(path: path)!
//    return NSLocalizedString(self, tableName: nil, bundle: bundle, value: "", comment: "")
//        //return Labiba.bundle.localizedString(forKey: self, value: nil, table: nil)
//    }

    public var local: String
    {
        let language = LbLanguage.current
        guard let path = Constants.mainBundle.path(forResource: language == "en" ? "Base" : language, ofType: "lproj") else {
            
//        }
//        guard let path = Bundle.main.path(forResource: language == "en" ? "Base" : language, ofType: "lproj")
//        else
//        {

            let basePath = Bundle.main.path(forResource: "Base", ofType: "lproj")!

            return Bundle(path: basePath)!.localizedString(forKey: self, value: "", table: nil)
        }

        return Bundle(path: path)!.localizedString(forKey: self, value: "", table: nil)
    }
    
    public var localBasedOnLastMessage: String
    {
        let language = AssistantConfig.config.lastMessageLangCode
        
        guard let path = Constants.mainBundle.path(forResource: language == "en" ? "Base" : language, ofType: "lproj") else {
            
            let basePath = Bundle.main.path(forResource: "Base", ofType: "lproj")!
            
            return Bundle(path: basePath)!.localizedString(forKey: self, value: "", table: nil)
        }
        
        return Bundle(path: path)!.localizedString(forKey: self, value: "", table: nil)
    }
    
    public var localForChosnLangCodeBB: String  //  for the bot Bundel (framework Bundel)
    {
        let language = SharedPreference.shared.botLangCode
        guard let path = Constants.mainBundle.path(forResource: language.rawValue == "en" ? "Base" : language.rawValue, ofType: "lproj") else {
            
            let basePath = Bundle.main.path(forResource: "Base", ofType: "lproj")!
            
            return Bundle(path: basePath)!.localizedString(forKey: self, value: "", table: nil)
        }
        
        return Bundle(path: path)!.localizedString(forKey: self, value: "", table: nil)
    }
    
    public var localForChosnLangCodeMB: String // for the main Bundel (App Bundel)
    {
        let language = SharedPreference.shared.botLangCode
        guard let path = Bundle.main.path(forResource: language.rawValue, ofType: "lproj") else {
            
            let basePath = Bundle.main.path(forResource: "Base", ofType: "lproj")!
            
            return Bundle(path: basePath)!.localizedString(forKey: self, value: "", table: nil)
        }
        return Bundle(path: path)!.localizedString(forKey: self, value: "", table: "AppLocalizable")
    }
    
}

class LbLanguage
{

    static var isArabic: Bool
    {
        return SharedPreference.shared.botLangCode  == .ar
    }

    static var current: String
    {
        if #available(iOS 16, *) {
            return Locale.current.language.languageCode?.identifier ?? "en"
        } else {
            return Locale.current.languageCode!
        }
    }
    
}
