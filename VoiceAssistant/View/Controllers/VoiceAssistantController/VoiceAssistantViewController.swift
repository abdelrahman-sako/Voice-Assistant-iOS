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
        
        return createHeerderView(tableView)
    }
}

extension VoiceAssistantViewController {
    
    private func createHeerderView(_ tableView: UITableView) -> UIView {
        let headerHeight: CGFloat = 24

        let header = UIView(frame: CGRect(
            x: 0,
            y: 0,
            width: tableView.frame.width,
            height: headerHeight
        ))
        
        // Drag indicator (centered)
        let dragableWidth: CGFloat = 50
        let dragableHeight: CGFloat = 5

        let dragable = UIView(frame: CGRect(
            x: (header.bounds.width - dragableWidth) / 2,
            y: (header.bounds.height - dragableHeight) / 2,
            width: dragableWidth,
            height: dragableHeight
        ))

        dragable.backgroundColor = .gray
        dragable.layer.cornerRadius = dragableHeight / 2
        header.addSubview(dragable)

        // 3-dot button (vertically centered)
        let iconSize: CGFloat = 25

        let moreIcon = UIImageView(frame: CGRect(
            x: header.frame.width - iconSize - 12,
            y: (headerHeight - iconSize) / 2,
            width: iconSize,
            height: iconSize
        ))

        moreIcon.isUserInteractionEnabled = true
        moreIcon.isHidden = !AssistantConfig.sheetViewTheme.showReportButton
        if #available(iOS 13.0, *) {
            moreIcon.image = UIImage(systemName: "exclamationmark.bubble")?.withRenderingMode(.alwaysTemplate)
        } else {
            // Fallback on earlier versions
        }

        moreIcon.tintColor = .gray
        moreIcon.contentMode = .scaleAspectFit

        header.addSubview(moreIcon)

        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(moreTapped))
        moreIcon.addGestureRecognizer(tapGesture)
        
        header.addSubview(moreIcon)
        
        dragable.translatesAutoresizingMaskIntoConstraints = false
        moreIcon.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            dragable.centerXAnchor.constraint(equalTo: header.centerXAnchor),
            dragable.centerYAnchor.constraint(equalTo: header.centerYAnchor),
            dragable.widthAnchor.constraint(equalToConstant: dragableWidth),
            dragable.heightAnchor.constraint(equalToConstant: dragableHeight),

            moreIcon.centerYAnchor.constraint(equalTo: header.centerYAnchor),
            moreIcon.widthAnchor.constraint(equalToConstant: iconSize),
            moreIcon.heightAnchor.constraint(equalToConstant: iconSize),
            moreIcon.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -25)
        ])
        
        return header
        
    }
    
    @objc private func moreTapped() {
        
        let viewController = CustomAlertViewController(nibName: "CustomAlertViewController", bundle: bundle)
        viewController.presentAnimated(over: self, viewAlpha: 0.10)
        viewController.didSelectCell = { [weak self] type in
            switch type {
            case .reportForm:
                self?.goToReportSheet()
            }
        }
    }
}


extension VoiceAssistantViewController {
    func goToReportSheet() {
        let viewController = ReportsViewController(nibName: "ReportsViewController", bundle: bundle)
        viewController.targetMessage = self.lastestMessage
        viewController.modalPresentationStyle = .overFullScreen
        self.present(viewController, animated: true)
    }
}
