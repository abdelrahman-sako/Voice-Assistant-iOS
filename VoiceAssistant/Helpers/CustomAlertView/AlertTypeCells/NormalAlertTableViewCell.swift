//
//  NormalAlertTableViewCell.swift
//  VoiceAssistant
//
//  Created by Yazan Kareem on 27/01/2026.
//

import UIKit

class NormalAlertTableViewCell: UITableViewCell {

    @IBOutlet weak var alertTitle: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var alertIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupView()
    }

    private func setupView() {
        containerView.layer.cornerRadius = 15
        containerView.layer.shadowColor = UIColor.white.cgColor
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 6
        alertTitle.textAlignment = LbLanguage.isArabic ? .right : .left
        alertTitle.text = Constants.LocaizationConstants.report_title.rawValue.localized
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
