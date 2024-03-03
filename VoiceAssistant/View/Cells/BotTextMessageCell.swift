//
//  BotTextMessageCell.swift
//  Voice Assistant
//
//  Created by Osama Hasan on 17/01/2024.
//

import UIKit

class BotTextMessageCell: UITableViewCell {

    @IBOutlet weak var messageLabel: UILabel!
    var isScalled:Bool = false {
        didSet{
            if(isScalled){
                let font = AssistantConfig.botViewheme.scallTextStyle.font
                messageLabel.textColor =  AssistantConfig.botViewheme.scallTextStyle.color
                messageLabel.font = font
              
            }else{
                let font = AssistantConfig.botViewheme.defualtTextStyle.font
                messageLabel.textColor =  AssistantConfig.botViewheme.defualtTextStyle.color

                messageLabel.font = font
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

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
