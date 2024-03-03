//
//  VoiceAssistantViewController.swift
//  Voice Assistant
//
//  Created by Osama Hasan on 15/01/2024.
//

import UIKit
import Combine

class VoiceAssistantViewController: ActionSheet {
    
    
    @IBOutlet weak var messagesTableView: ContentSizedTableView!
    
    let viewModel = VoiceAssistantViewModel()
    lazy var voiceTypeDialog = VoiceAssistantView.create()
    var delegete:VoiceAssistantCommunicationDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTableView()
        registerCells()
        actionSheetSetup(animatedView: messagesTableView,withViews: [voiceTypeDialog])
        
        viewModel.startConversation()
        bindViewModel()
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        addInterationDialog()
        
    }
    
    func setupUI(){
        
        
        messagesTableView.layer.cornerRadius = AssistantConfig.sheetViewTheme.viewStyle.radius
        
        messagesTableView.layer.maskedCorners = AssistantConfig.sheetViewTheme.viewStyle.corners
        
        
    }
    
    func registerCells(){
        messagesTableView.registerCell(type: BotTextMessageCell.self)
        messagesTableView.registerCell(type: UserTextMessageCell.self)
        messagesTableView.registerCell(type: TypingCell.self)
    }
    
    func setupTableView(){
        messagesTableView.dataSource =  self
        messagesTableView.delegate =  self
        messagesTableView.estimatedRowHeight = UITableView.automaticDimension;
        messagesTableView.rowHeight = 200
    }
    
    func bindViewModel(){
        viewModel.onReceiveData = {
            UIView.transition(with: self.messagesTableView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.messagesTableView.reloadData()
            }, completion: nil)
            
            
            
        }
        
        viewModel.onSendData = {
            UIView.transition(with: self.messagesTableView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.messagesTableView.reloadData()
            }, completion: nil)
            self.messagesTableView.scrollToRow(at: IndexPath(row:  self.viewModel.messages.count - 1, section: 0), at: .bottom, animated: true)
        }
        
        viewModel.createPost = {[self] results in
            delegete?.onResult(results: results)
        }
        
    }
    
    func addInterationDialog()
    {
        
        voiceTypeDialog.delegate = self
        //  voiceTypeDialog.popUp(on: self.view)
        switch UIScreen.current {
        case .iPhone5_8 ,.iPhone6_1 , .iPhone6_5:
            //tavleViewBottomConst.constant = 50
            messagesTableView.contentInset.bottom  = 120
        case .iPhone5_5 :
            //tavleViewBottomConst.constant = 90
            messagesTableView.contentInset.bottom = 140
        default:
            //   tavleViewBottomConst.constant = VoiceK
            messagesTableView.contentInset.bottom = 140
        }
        
        voiceTypeDialog.dismiss()
        
        messagesTableView.contentInset.bottom = messagesTableView.contentInset.bottom
        
        voiceTypeDialog.frame = CGRect(x: 0, y: view.frame.height - (VoiceAssistantView.HEIGHT + 20), width: view.frame.width, height: VoiceAssistantView.HEIGHT)
        
        self.view.addSubview(voiceTypeDialog)
        
        
        
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        viewModel.stopVoice()
        
    }
    
    
    deinit {
        viewModel.stopVoice()
    }
    
}


extension VoiceAssistantViewController : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = viewModel.messages[indexPath.row]
        if item.isTyping{
            let cell = tableView.dequeueCell(withType: TypingCell.self, for: indexPath)!
            
            return cell
        }
        
        if item.party == .bot {
            let cell = tableView.dequeueCell(withType: BotTextMessageCell.self, for: indexPath)!
            if let message = item.message{
                
                cell.isScalled = !(viewModel.messages.contains(where: {$0.party == .user}) || message.count > 150 )
                cell.setMessageData(data: message)
                
            }
            return cell
        }
        
        let cell = tableView.dequeueCell(withType: UserTextMessageCell.self, for: indexPath)!
        if let message = item.message {
            
            cell.setMessageData(data: message)
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) ->CGFloat {
        
        return tableView.estimatedRowHeight
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 10))
        
        let dragable = UIView(frame: CGRect(x: header.frame.midX - 25, y: header.frame.midY, width: 50, height: 5))
        dragable.backgroundColor = .gray
        
        header.addSubview(dragable)
        return header
    }
    
    
    
    
}


extension VoiceAssistantViewController : VoiceRecognitionProtocol{
    func didStartSpeechToText() {
        viewModel.stopVoice()
    }
    
    func finishRecognitionWithText(text: String) {
        viewModel.sendMessage(message: text)
    }
    
    func didRecognizeText(text: String) {
    }
    
    func didStopRecording() {
    }
    
    func changeFromVoiceToKeyboardType() {
        
    }
    
    
}
