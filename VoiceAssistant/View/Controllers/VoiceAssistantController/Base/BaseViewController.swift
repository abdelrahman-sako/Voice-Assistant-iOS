//
//  BaseViewController.swift
//  VoiceAssistant
//
//  Created by Osama Hasan on 15/10/2024.
//

import UIKit

public class BaseViewController: UIViewController {

    lazy var voiceTypeDialog = VoiceAssistantView.create()
    let viewModel = VoiceAssistantViewModel()
    var delegete:VoiceAssistantCommunicationDelegate?

    var injecableImageView :UIImageView? = nil

    public override func viewDidLoad() {
        super.viewDidLoad()
        
       
        viewModel.startConversation()

        
    }
 

    public override func viewWillDisappear(_ animated: Bool) {
        viewModel.stopVoice()
        
    }
    
    
    deinit {
        viewModel.stopVoice()
    }
    
    func registerCells(tableView:UITableView){
        tableView.registerCell(type: BotTextMessageCell.self)
        tableView.registerCell(type: UserTextMessageCell.self)
        tableView.registerCell(type: ChoicesCell.self)
        tableView.registerCell(type: ImageCell.self)
        tableView.registerCell(type: TypingCell.self)
        AssistantConfig.config.registeredCells.forEach({tableView.registerCell(type: $0,customeBundle: AssistantConfig.config.bundle)})
        
    }

    func showGifImage(tableView:UITableView,urlString:String){
        if injecableImageView != nil {
            return
        }
        if let url = URL(string: urlString) {
            let loader = UIActivityIndicatorView(style: .white)
            injecableImageView = UIImageView(frame: tableView.frame)
            injecableImageView!.setGifFromURL(url, loopCount: 1, customLoader: loader)
            injecableImageView!.delegate = self

           // view.bringSubviewToFront(injecableImageView)

            //injecableImageView.isHidden = false
            
            view.addSubview(injecableImageView!)
        }
    }
    
    func readCustomMessages(messages:[String]){
        viewModel.readCustomMessages(messages: messages)
    }
    
    func showGifImage(urlString:String){
    }
    
    
    func addInterationDialog(tableView:UITableView)
    {
        
        voiceTypeDialog.delegate = self
        //  voiceTypeDialog.popUp(on: self.view)
        switch UIScreen.current {
        case .iPhone5_8 ,.iPhone6_1 , .iPhone6_5:
            //tavleViewBottomConst.constant = 50
            tableView.contentInset.bottom  = 210
        case .iPhone5_5 :
            //tavleViewBottomConst.constant = 90
            tableView.contentInset.bottom = 250
        default:
            //   tavleViewBottomConst.constant = VoiceK
            tableView.contentInset.bottom = 260
        }
        
        voiceTypeDialog.dismiss()
        
        tableView.contentInset.bottom = tableView.contentInset.bottom
        
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
    
  
    
    func bindViewModel(tableView:UITableView){
        viewModel.onReceiveData = {
            UIView.transition(with: tableView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                tableView.insertRows(at: [IndexPath(row: self.viewModel.messages.count - 1,section: 0)], with: .automatic)
                //self.messagesTableView.reloadRows(at: [IndexPath(row: self.viewModel.messages.count - 1,section: 0)], with: .automatic)
                DispatchQueue.main.async {
                    let indexPath = IndexPath(row: self.viewModel.messages.count-1, section: 0)
                    tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                }

            }, completion: nil)

            // This will shufle the suggestion each time we recive a message
            self.voiceTypeDialog.suggestions.shuffle()
            self.voiceTypeDialog.suggestionCollectionView.reloadData()
        }
        
        viewModel.onReload = {
            UIView.transition(with: tableView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                tableView.reloadData()
                DispatchQueue.main.async {
                    if !self.viewModel.messages.isEmpty{
                        
//                        let indexPath = IndexPath(row: self.viewModel.messages.count-1, section: 0)
//                        self.messagesTableView.scrollToRow(at: indexPath, at: .top, animated: true)
                    }
                }

            }, completion: nil)

            // This will shufle the suggestion each time we recive a message
            self.voiceTypeDialog.suggestions.shuffle()
            self.voiceTypeDialog.suggestionCollectionView.reloadData()
        }
        
        viewModel.onSendData = {
            UIView.transition(with: tableView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                tableView.reloadData()
            }, completion: nil)
            tableView.scrollToRow(at: IndexPath(row:  self.viewModel.messages.count - 1, section: 0), at: .bottom, animated: true)
            self.delegete?.onMessageSent()
        }
        
        viewModel.startRecordVoice = {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                self.voiceTypeDialog.startRecordingAnimation()
                self.voiceTypeDialog.speechToTextManager.start()
            }
           
        }
        
    }

}

extension BaseViewController : VoiceRecognitionProtocol{
    func didStartSpeechToText() {
        viewModel.stopVoice()
    }
    
    func finishRecognitionWithText(text: String) {
        viewModel.sendMessage(message: text)
    }
    
    func didRecognizeText(text: String) {
        print("Did Recongnize Text : \(text)")
    }
    
    func didStopRecording() {
    }
    
    func changeFromVoiceToKeyboardType() {
        
    }
    
    
}

extension BaseViewController : UITableViewDelegate , UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.messages.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) ->CGFloat {
        
        return tableView.estimatedRowHeight
        
    }
    

    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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


extension BaseViewController : SwiftyGifDelegate {

    public func gifURLDidFinish(sender: UIImageView) {
        print("gifURLDidFinish")
    }

    func gifURLDidFail(sender: UIImageView) {
        print("gifURLDidFail")
    }

    public func gifDidStart(sender: UIImageView) {
        print("gifDidStart")
    }
    
    public func gifDidLoop(sender: UIImageView) {
        print("gifDidLoop")
    }
    
    public func gifDidStop(sender: UIImageView) {
        sender.removeFromSuperview()
        injecableImageView = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.viewModel.getNextOnQueue()
        }
    }
}
