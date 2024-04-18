//
//  SuggestionCell.swift
//  VoiceAssistant
//
//  Created by Osama Hasan on 21/03/2024.
//

import UIKit

class SuggestionCell: UICollectionViewCell {

    @IBOutlet weak var contanierView: UIView!
    @IBOutlet weak var suggestionLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let radius = AssistantConfig.suggestionsViewTheme.viewStyle.radius
        
        contanierView.layer.cornerRadius = radius
        
        
        let borderColor = AssistantConfig.suggestionsViewTheme.viewStyle.borderColor
        let borderWidth = AssistantConfig.suggestionsViewTheme.viewStyle.borderWidth
        
        contanierView.layer.borderColor = borderColor.cgColor
        contanierView.layer.borderWidth = borderWidth
        contanierView.backgroundColor = AssistantConfig.suggestionsViewTheme.viewStyle.backgroundColor
        suggestionLabel.textColor = AssistantConfig.suggestionsViewTheme.textStyle.color
        suggestionLabel.font = AssistantConfig.suggestionsViewTheme.textStyle.font
        
    }
    
    
    
    func setData(data:String){
        suggestionLabel.text = data
    }

}
