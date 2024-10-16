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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTableView()
        registerCells(tableView: messagesTableView)
       
        actionSheetSetup(animatedView: messagesTableView,withViews: [voiceTypeDialog])
        bindViewModel(tableView: messagesTableView)

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        addInterationDialog(tableView: messagesTableView)

    }
    
    override func showGifImage(urlString:String){
        showGifImage(tableView: messagesTableView,urlString: urlString)
    }
    
    func setupUI(){
        
        
        messagesTableView.layer.cornerRadius = AssistantConfig.sheetViewTheme.viewStyle.radius
        
        messagesTableView.layer.maskedCorners = AssistantConfig.sheetViewTheme.viewStyle.corners
        
        
        voiceTypeDialog.onSuggestionClicked = { suggestion in
            self.viewModel.sendMessage(message: suggestion,addToMessages: false)
        }
        
        
        messagesTableView.backgroundColor = AssistantConfig.sheetViewTheme.viewStyle.backgroundColor
        
    }
    
    func setupTableView(){
        messagesTableView.dataSource =  self
        messagesTableView.delegate =  self
        messagesTableView.estimatedRowHeight = UITableView.automaticDimension;
        messagesTableView.rowHeight = 200
    }
}

extension VoiceAssistantViewController {
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 10))
        
        let dragable = UIView(frame: CGRect(x: header.frame.midX - 25, y: header.frame.midY, width: 50, height: 5))
        dragable.backgroundColor = .gray
        
        header.addSubview(dragable)
        return header
    }
}
