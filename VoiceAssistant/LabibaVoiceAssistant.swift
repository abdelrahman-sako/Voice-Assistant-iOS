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
    
    public func sendMessage(message:String,isAdded:Bool = true){
        vc.viewModel.sendMessage(message: message,addToMessages: isAdded)
    }
    
    public func addBotMessage(message:String,tableview:UITableView)->UITableViewCell{
        let cell = tableview.dequeueCell(withType: BotTextMessageCell.self) as! BotTextMessageCell 
        cell.setMessageData(data: message)
        
        return cell
    }
    
    
    public func addTyping(){
        vc.viewModel.addTyping()
    }
    
    public func removeTyping(){
        vc.viewModel.removeTyping()
    }
}

extension LabibaVoiceAssistant : VoiceAssistantCommunicationDelegate {
    func onMessageSent() {
        delegate?.onMessageSent()
    }
    
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
//    func onResult(indexPath:IndexPath,tableView:UITableView,sheet:ActionSheet,results:[String:Any])->UITableViewCell?
    func onResult(tableView:UITableView,sheet:ActionSheet,results:[String:Any])->UITableViewCell?

    func onMessageSent()
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
    func onMessageSent()
}

public enum LabibaErrors : String{
    case missingConfig = "missingConfig"
    case voicesAreRequired = "voicesAreRequired"
}
