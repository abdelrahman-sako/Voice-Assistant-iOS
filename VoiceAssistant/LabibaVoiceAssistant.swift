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
    
    
    public func showGifImage(url:String){
        vc.showGifImage(uslString: url)
    }
}

extension LabibaVoiceAssistant : VoiceAssistantCommunicationDelegate {
    func onCustomCell(tableView: UITableView, dialog: [String:Any]) -> UITableViewCell? {
        return delegate?.onCustomCell(tableView: tableView, dialog: dialog)
    }
    
    
    func onResult(tableView:UITableView,results: [String : Any]) -> UITableViewCell? {
        return delegate?.onResult(tableView:tableView,sheet: vc, results: results)
    }
    
}


public protocol LabibaVoiceAssistantDelegate {
    func onInitSuccess(sheet:ActionSheet)
    func onError(sheet:ActionSheet,error:LabibaErrors)
    func onResult(tableView:UITableView,sheet:ActionSheet,results:[String:Any])->UITableViewCell?
   // func onCustomCell(tableView:UITableView,dialog:[String:Any])-> UITableViewCell?
}

extension LabibaVoiceAssistantDelegate{
    func onCustomCell(tableView:UITableView,dialog:[String:Any])-> UITableViewCell? {
        return nil
    }
}

protocol VoiceAssistantCommunicationDelegate {
    func onResult(tableView:UITableView,results:[String:Any])-> UITableViewCell?
    func onCustomCell(tableView:UITableView,dialog:[String:Any])-> UITableViewCell?
}

public enum LabibaErrors : String{
    case missingConfig = "missingConfig"
    case voicesAreRequired = "voicesAreRequired"
}
