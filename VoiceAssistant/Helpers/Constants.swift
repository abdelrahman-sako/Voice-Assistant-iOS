//
//  Constants.swift
//  Visit Jordan Bot
//
//  Created by AhmeDroid on 9/21/16.
//  Copyright © 2016 Imagine Technologies. All rights reserved.
//

import UIKit

struct Constants {
    
    struct NotificationNames {
        static let UserLocationUpdated = NSNotification.Name(rawValue: "UserLocationUpdated")
        static let FullscreenVideoRequested = NSNotification.Name(rawValue: "FullscreenVideoRequested")
        static let ChangeTextViewKeyboardType = NSNotification.Name(rawValue: "ChangeTextViewKeyboardType")
        static let StopTextToSpeech = NSNotification.Name(rawValue: "stopTextToSpeech")
        static let StopSpeechToText = NSNotification.Name(rawValue: "StopSpeechToText")
        static let StartSpeechToText = NSNotification.Name(rawValue: "startSpeechToText")
        static let FinishCurrentTextToSpeechPhrase = NSNotification.Name(rawValue: "FinishCurrentTextToSpeechPhrase")
        static let ChangeInputToTextViewType = NSNotification.Name(rawValue: "ChangeInputToTextViewType")
        static let ChangeInputToVoiceAssistantType = NSNotification.Name(rawValue: "ChangeInputToVoiceAssistantType")
        static let StopMedia = NSNotification.Name(rawValue: "StopMedia")
        static let CheckMediaEndDisplaying = NSNotification.Name(rawValue: "CheckMediaEndDisplaying")
        static let ScoketDidOpen = NSNotification.Name(rawValue: "ScoketDidOpen")
        static let ShowHideDynamicGIF = NSNotification.Name(rawValue: "ShowHideDynamicGIF")
        static let CardSelectionAbility = NSNotification.Name(rawValue: "CardSelectionAbility")
        static let languageChanged = NSNotification.Name(rawValue: "languageChanged")
        static let activationDidComplete = NSNotification.Name("ActivationDidComplete")
        static let reachabilityDidChange = NSNotification.Name("ReachabilityDidChange")
    }
    
    static var content_type:String{
        get{
            return UserDefaults.standard.object(forKey: "content_type") as? String ?? ""
        }set{
            UserDefaults.standard.set(newValue, forKey: "content_type")
            UserDefaults.standard.synchronize()
        }
    }
    static var Keyboard_type:String{
        get{
            return UserDefaults.standard.object(forKey: "Keyboard_type") as? String ?? ""
        }set{
            UserDefaults.standard.set(newValue, forKey: "Keyboard_type")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var mainBundle:Bundle{
        get{
            return Bundle(for: VoiceAssistantViewController.self)
        }
    }
    
}
