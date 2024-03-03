//
//  LabibaVoiceAssistant.swift
//  Voice Assistant
//
//  Created by Osama Hasan on 17/01/2024.
//

import Foundation
import UIKit

public class LabibaVoiceAssistant {
    
    public static let shared = LabibaVoiceAssistant()
    

    public var delegate:LabibaVoiceAssistantDelegate?
    var vc : VoiceAssistantViewController!
    
    public func start(view:UIViewController){
        vc = ActionSheet.Create(vc: VoiceAssistantViewController.self)
        guard let _ = AssistantConfig.config else {
            delegate?.onError(sheet: vc, error: .missingConfig)
            return
        }
        
    
        vc.delegete = self
        vc.modalPresentationStyle = .overFullScreen
        vc.show(inViewController: view)
        delegate?.onInitSuccess(sheet: vc)
    }
}

extension LabibaVoiceAssistant : VoiceAssistantCommunicationDelegate {
    func onResult(results: [String : Any]) {
        delegate?.onResult(sheet: vc, results: results)
    }
    
    
}


public protocol LabibaVoiceAssistantDelegate {
    func onInitSuccess(sheet:ActionSheet)
    func onError(sheet:ActionSheet,error:LabibaErrors)
    func onResult(sheet:ActionSheet,results:[String:Any])
}

protocol VoiceAssistantCommunicationDelegate {
    func onResult(results:[String:Any])
}

public enum LabibaErrors : String{
    case missingConfig = "missingConfig"
    case voicesAreRequired = "voicesAreRequired"
}
