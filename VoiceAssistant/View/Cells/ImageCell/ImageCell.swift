//
//  ImageCell.swift
//  VoiceAssistant
//
//  Created by Osama Hasan on 17/03/2024.
//

import UIKit

class ImageCell: UITableViewCell {

    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var contentImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        contentImageView.layer.cornerRadius = AssistantConfig.imageViewTheme.viewStyle.radius
        
        itemLabel.textColor = AssistantConfig.imageViewTheme.textStyle.color
        itemLabel.font = AssistantConfig.imageViewTheme.textStyle.font
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func setData(data:ConversationDialog){
        contentImageView.image = nil

        if let urlString = data.media?.url, let url = URL(string: urlString) {
            contentImageView.load(url: url)

        }
        
        itemLabel.isHidden = !data.hasMessage
        
        itemLabel.text = data.message
    }
    override func prepareForReuse() {
        contentImageView.image = nil
    }
}
