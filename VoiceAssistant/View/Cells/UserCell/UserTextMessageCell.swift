//
//  UserTextMessageCell.swift
//  Voice Assistant
//
//  Created by Osama Hasan on 21/01/2024.
//

import UIKit

class UserTextMessageCell: UITableViewCell {

    @IBOutlet weak var messageLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let font = AssistantConfig.userViewTheme.textStyle.font
        messageLabel.font = font

        messageLabel.textColor =  AssistantConfig.userViewTheme.textStyle.color
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setMessageData(data:String){
        let font = AssistantConfig.userViewTheme.textStyle.font ?? messageLabel.font ?? UIFont.systemFont(ofSize: 14)
        let textColor = AssistantConfig.userViewTheme.textStyle.color

        if data.containsAnchorTags || data.containsHTML {
            let boldFont = UIFont.boldSystemFont(ofSize: font.pointSize)
            let attributed = data.htmlAttributedString(regularFont: font, boldFont: boldFont, color: textColor)
            if attributed.length > 0 {
                messageLabel.attributedText = attributed
                return
            }
        }
        messageLabel.font = font
        messageLabel.textColor = textColor
        messageLabel.text = data
    }
}
