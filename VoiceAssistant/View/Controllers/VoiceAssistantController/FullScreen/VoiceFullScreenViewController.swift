//
//  VoiceFullScreenViewController.swift
//  VoiceAssistant
//
//  Created by Osama Hasan on 15/10/2024.
//

import UIKit

class VoiceFullScreenViewController: BaseViewController {

    @IBOutlet weak var messagesTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTableView()
        registerCells(tableView: messagesTableView)
        addInterationDialog(tableView: messagesTableView)
        
        bindViewModel(tableView: messagesTableView)
        setupNavigationBar()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
       
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
    
    func setupUI(){
        
        voiceTypeDialog.onSuggestionClicked = { suggestion in
            self.viewModel.sendMessage(message: suggestion,addToMessages: false)
        }
        
        view.backgroundColor = AssistantConfig.sheetViewTheme.viewStyle.backgroundColor
        
    }
    
    
    
    override func showGifImage(urlString:String){
        showGifImage(tableView: messagesTableView,urlString: urlString)
    }
    
    func setupTableView(){
        messagesTableView.dataSource =  self
        messagesTableView.delegate =  self
        messagesTableView.estimatedRowHeight = UITableView.automaticDimension
        messagesTableView.rowHeight = 200
    }
    
    
    func setupNavigationBar(){

            
        guard let backImage = AssistantConfig.navigationBarViewTheme.backImage else  {
            return
        }
        


       // backButtonImage.
        let backButton = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(backAction))
        backButton.tintColor = AssistantConfig.navigationBarViewTheme.backButtonStyle.tintColor // Change UIColor.red to your desired tint color

        //backButton.image.
        // Set the custom back button as the left bar button item
        self.navigationItem.leftBarButtonItem = backButton
        
       
    }

    @objc func backAction(){
        self.dismiss(animated: true)
        
    }
}







