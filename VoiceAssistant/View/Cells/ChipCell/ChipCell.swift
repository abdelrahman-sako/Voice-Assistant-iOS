//
//  ChipCell.swift
//  VoiceAssistant
//
//  Created by Osama Hasan on 17/03/2024.
//

import UIKit

class ChipCell: UICollectionViewCell {

    @IBOutlet weak var contanierView: UIView!
    @IBOutlet weak var itemLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let radius = AssistantConfig.chipViewTheme.viewStyle.radius
        contanierView.backgroundColor = AssistantConfig.chipViewTheme.viewStyle.backgroundColor
        
        contanierView.layer.cornerRadius = radius
        
        
        let borderColor = AssistantConfig.chipViewTheme.viewStyle.borderColor
        let borderWidth = AssistantConfig.chipViewTheme.viewStyle.borderWidth
        
        contanierView.layer.borderColor = borderColor.cgColor
        contanierView.layer.borderWidth = borderWidth
        
        itemLabel.textColor = AssistantConfig.chipViewTheme.textStyle.color
        itemLabel.font = AssistantConfig.chipViewTheme.textStyle.font
        
    }

    
    func setData(data:String){
        itemLabel.text = data
    }
}
