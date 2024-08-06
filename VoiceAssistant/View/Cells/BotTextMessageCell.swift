//
//  BotTextMessageCell.swift
//  Voice Assistant
//
//  Created by Osama Hasan on 17/01/2024.
//

import UIKit

class BotTextMessageCell: UITableViewCell {

    @IBOutlet weak var messageLabel: UITextView!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let font = AssistantConfig.botViewheme.scallTextStyle.font
        messageLabel.textColor =  AssistantConfig.botViewheme.scallTextStyle.color
        messageLabel.font = font
        messageLabel.delegate = self
        messageLabel.isEditable = false
        messageLabel.isSelectable = true
        messageLabel.dataDetectorTypes = .link

//        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setMessageData(data:String){
       
        messageLabel.text = data
    }
    
}

extension BotTextMessageCell : UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith asm: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(asm)

        return false
    }
}
