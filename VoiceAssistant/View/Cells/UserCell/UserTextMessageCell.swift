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
        messageLabel.text = data
    }
}
