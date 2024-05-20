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
    
    var injecableImageView :UIImageView? = nil
    
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
        
        
        voiceTypeDialog.onSuggestionClicked = { suggestion in
            self.viewModel.sendMessage(message: suggestion,addToMessages: false)
        }
        
        
        messagesTableView.backgroundColor = AssistantConfig.sheetViewTheme.viewStyle.backgroundColor
        
    }
    
    func registerCells(){
        messagesTableView.registerCell(type: BotTextMessageCell.self)
        messagesTableView.registerCell(type: UserTextMessageCell.self)
        messagesTableView.registerCell(type: ChoicesCell.self)
        messagesTableView.registerCell(type: ImageCell.self)
        messagesTableView.registerCell(type: TypingCell.self)
        AssistantConfig.config.registeredCells.forEach({messagesTableView.registerCell(type: $0,customeBundle: AssistantConfig.config.bundle)})
        
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
                self.messagesTableView.insertRows(at: [IndexPath(row: self.viewModel.messages.count - 1,section: 0)], with: .automatic)
                //self.messagesTableView.reloadRows(at: [IndexPath(row: self.viewModel.messages.count - 1,section: 0)], with: .automatic)
                DispatchQueue.main.async {
                    let indexPath = IndexPath(row: self.viewModel.messages.count-1, section: 0)
                    self.messagesTableView.scrollToRow(at: indexPath, at: .top, animated: true)
                }

            }, completion: nil)

            // This will shufle the suggestion each time we recive a message
            self.voiceTypeDialog.suggestions.shuffle()
            self.voiceTypeDialog.suggestionCollectionView.reloadData()
        }
        
        viewModel.onReload = {
            UIView.transition(with: self.messagesTableView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.messagesTableView.reloadData()
                DispatchQueue.main.async {
                    if !self.viewModel.messages.isEmpty{
                        let indexPath = IndexPath(row: self.viewModel.messages.count-1, section: 0)
                        self.messagesTableView.scrollToRow(at: indexPath, at: .top, animated: true)
                    }
                }

            }, completion: nil)

            // This will shufle the suggestion each time we recive a message
            self.voiceTypeDialog.suggestions.shuffle()
            self.voiceTypeDialog.suggestionCollectionView.reloadData()
        }
        
        viewModel.onSendData = {
            UIView.transition(with: self.messagesTableView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.messagesTableView.reloadData()
            }, completion: nil)
            self.messagesTableView.scrollToRow(at: IndexPath(row:  self.viewModel.messages.count - 1, section: 0), at: .bottom, animated: true)
        }
        
    }
    
    

    func showGifImage(uslString:String){
        if injecableImageView != nil {
            return
        }
        if let url = URL(string: uslString) {
            let loader = UIActivityIndicatorView(style: .white)
            injecableImageView = UIImageView(frame: messagesTableView.frame)
            injecableImageView!.setGifFromURL(url, loopCount: 1, customLoader: loader)
            injecableImageView!.delegate = self

           // view.bringSubviewToFront(injecableImageView)

            //injecableImageView.isHidden = false
            
            view.addSubview(injecableImageView!)
        }
    }
    
    func addInterationDialog()
    {
        
        voiceTypeDialog.delegate = self
        //  voiceTypeDialog.popUp(on: self.view)
        switch UIScreen.current {
        case .iPhone5_8 ,.iPhone6_1 , .iPhone6_5:
            //tavleViewBottomConst.constant = 50
            messagesTableView.contentInset.bottom  = 210
        case .iPhone5_5 :
            //tavleViewBottomConst.constant = 90
            messagesTableView.contentInset.bottom = 250
        default:
            //   tavleViewBottomConst.constant = VoiceK
            messagesTableView.contentInset.bottom = 260
        }
        
        voiceTypeDialog.dismiss()
        
        messagesTableView.contentInset.bottom = messagesTableView.contentInset.bottom
        
       // voiceTypeDialog.frame = CGRect(x: 0, y: view.frame.height - (VoiceAssistantView.HEIGHT + 20), width: view.frame.width, height: VoiceAssistantView.HEIGHT)
        
        self.view.addSubview(voiceTypeDialog)
        
        voiceTypeDialog.translatesAutoresizingMaskIntoConstraints = false
        

        NSLayoutConstraint.activate([
            voiceTypeDialog.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            //voiceTypeDialog.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            voiceTypeDialog.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            voiceTypeDialog.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            voiceTypeDialog.heightAnchor.constraint(equalToConstant: VoiceAssistantView.HEIGHT)
        ])

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
            
            cell.selectionStyle = .none
            return cell
        }

        
        if let items =  item.cards?.items,items.contains(where: {$0.buttons.contains(where: {$0.type == .createPost})}){
            guard let payload = items.first?.buttons.first?.payload,let dictionary = viewModel.stringJSONToDictionary(jsonString: payload) else{
                let cell = UITableViewCell()
                cell.backgroundColor = .clear
                return cell
            }
            if let delegete = delegete,let cell = delegete.onResult(tableView: tableView, results: dictionary){
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1){
//                    self.viewModel.getNextOnQueue()
//                }
                cell.selectionStyle = .none
                return cell
            }
        }
        
        if item.party == .bot {
            
            if item.choices != nil{
                let cell = tableView.dequeueCell(withType: ChoicesCell.self, for: indexPath)!
                cell.setData(data: item)
                cell.selectItemAt = {  dialog in
                    self.viewModel.sendMessage(message: dialog.title,addToMessages: false)
                }
                cell.selectionStyle = .none
                cell.collectionView.reloadData()
                cell.layoutIfNeeded()
                return cell
            }
            
            if let media = item.media {
                if media.type == .Photo {
                    let cell = tableView.dequeueCell(withType: ImageCell.self, for: indexPath)!
                    cell.setData(data: item)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5){
                        self.viewModel.getNextOnQueue()
                    }
                    cell.selectionStyle = .none

                    return cell
                }
            }
            
            let cell = tableView.dequeueCell(withType: BotTextMessageCell.self, for: indexPath)!
            if let message = item.message{
                cell.isScalled = !(viewModel.messages.contains(where: {$0.party == .user}) || message.count > 150 )
                cell.setMessageData(data: message)
                
            }else{
                cell.messageLabel.text = nil
            }
            cell.selectionStyle = .none

            return cell
        }
        
        let cell = tableView.dequeueCell(withType: UserTextMessageCell.self, for: indexPath)!
        if let message = item.message {
            
            cell.setMessageData(data: message)
            
        }
        cell.selectionStyle = .none
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = viewModel.messages[indexPath.row]
        
        if item.party == .bot {
            
            if let media = item.media {
                if media.type == .Photo {
                    let viewController = ImageViewController(nibName: "ImageViewController", bundle: bundle)
                    let nav = UINavigationController(rootViewController: viewController)
                    nav.modalPresentationStyle = .overFullScreen
                    viewController.imageUrl = item.media?.url
                    self.present(nav, animated: true)
                }
            }
            
        }
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


extension VoiceAssistantViewController : SwiftyGifDelegate {

    func gifURLDidFinish(sender: UIImageView) {
        print("gifURLDidFinish")
    }

    func gifURLDidFail(sender: UIImageView) {
        print("gifURLDidFail")
    }

    func gifDidStart(sender: UIImageView) {
        print("gifDidStart")
    }
    
    func gifDidLoop(sender: UIImageView) {
        print("gifDidLoop")
    }
    
    func gifDidStop(sender: UIImageView) {
        sender.removeFromSuperview()
        injecableImageView = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.viewModel.getNextOnQueue()
        }
    }
}
