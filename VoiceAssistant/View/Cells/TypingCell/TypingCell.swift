//
//  TypingCell.swift
//  Voice Assistant
//
//  Created by Osama Hasan on 23/01/2024.
//

import UIKit

class TypingCell: UITableViewCell {
    
    var loadingIndicator: NVActivityIndicatorView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        loadingIndicator = NVActivityIndicatorView(frame: CGRect.zero)
        loadingIndicator.type = NVActivityIndicatorType.ballPulse
        loadingIndicator.color = AssistantConfig.loaderTheme.color
        loadingIndicator.backgroundColor = .clear
        loadingIndicator.padding = 3.0

//        loadingIndicator.layer.shadowColor = UIColor.black.cgColor
//        loadingIndicator.layer.shadowOffset = CGSize(width: 0, height: 1)
//        loadingIndicator.layer.shadowRadius = 1.0
//        loadingIndicator.layer.shadowOpacity = 0.2
//        loadingIndicator.layer.cornerRadius = 10
//        loadingIndicator.layer.masksToBounds = false

        let totalMargin =  ipadMargin
        let px = LbLanguage.isArabic ? screenWidth - (50 + 5  + 5  ) : 5  + 5 + totalMargin
      //  px = Labiba._botAvatar == nil ? 5 : px
        let ipadAddition = ipadFactor*10
        loadingIndicator.frame = CGRect(x: px, y: 10, width: 70 + ipadAddition, height: 45 + ipadAddition)
        loadingIndicator.alpha = 0

        UIView.animate(withDuration: 0.3)
        {
            self.loadingIndicator.alpha = 1
        }

        loadingIndicator.startAnimating()
        self.addSubview(loadingIndicator)

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
        
        
    }
    
    
    func setBackgroundColor() {
//        if let grad = Labiba._botBubbleBackgroundGradient {
//
//            let gview = GradientView(frame: loadingIndicator.bounds)
//            gview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//            gview.setGradient(grad)
//
//            loadingIndicator.insertSubview(gview, at: 0)
//
//        } else if let bgColor = Labiba._botBubbleBackgroundColor {
//
//            loadingIndicator.backgroundColor = bgColor
//        }
        
//        switch Labiba.BotChatBubble.background {
//        case .solid(color: let color):
//            loadingIndicator.backgroundColor = color
//        case .gradient(gradientSpecs: let grad):
//            let gview = GradientView(frame: loadingIndicator.bounds)
//            gview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//            gview.setGradient(grad)
//            loadingIndicator.insertSubview(gview, at: 0)
//        case .image(image: _):break
//        }
    }
    
    
}
