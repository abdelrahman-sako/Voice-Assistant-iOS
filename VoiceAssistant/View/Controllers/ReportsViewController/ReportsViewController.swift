//
//  ReportsViewController.swift
//  VoiceAssistant
//
//  Created by Yazan Kareem on 26/01/2026.
//

import UIKit

class ReportsViewController: UIViewController {
    
    @IBOutlet weak var tabView: UIView!
    @IBOutlet weak var reasonTextView: UITextView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerMessage: UIView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var targetMessageLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!

    let placeholderLabel = UILabel()

    var targetMessage: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setData()
    }
    
    private func setupView() {
        tabView.layer.cornerRadius = tabView.frame.height / 2
        tabView.backgroundColor = .gray
        
        reasonTextView.delegate = self
        reasonTextView.isScrollEnabled = false
        reasonTextView.layer.borderWidth = 1
        reasonTextView.layer.borderColor = UIColor.black.cgColor.copy(alpha: 0.4)
        
        containerView.layer.cornerRadius = 16
        containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        containerView.layer.masksToBounds = true
        
        submitButton.setTitle(Constants.LocaizationConstants.submit_title.rawValue.localized, for: .normal)
        submitButton.tintColor = .black
        submitButton.layer.borderWidth = 1
        submitButton.layer.borderColor = UIColor.black.cgColor.copy(alpha: 0.4)
        
        self.enableTapToDismissAnimated()
        
        placeholderLabel.font = reasonTextView.font
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.numberOfLines = 0
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        reasonTextView.addSubview(placeholderLabel)
        NSLayoutConstraint.activate([
            placeholderLabel.leadingAnchor.constraint(equalTo: reasonTextView.frameLayoutGuide.leadingAnchor),
            placeholderLabel.trailingAnchor.constraint(equalTo: reasonTextView.frameLayoutGuide.trailingAnchor),
            placeholderLabel.topAnchor.constraint(equalTo: reasonTextView.topAnchor),
            placeholderLabel.bottomAnchor.constraint(equalTo: reasonTextView.bottomAnchor),
        ])
        
        titleLbl.text = Constants.LocaizationConstants.report_title.rawValue.localized
        descLbl.text = Constants.LocaizationConstants.inquiry_report_title.rawValue.localized
        placeholderLabel.text = " \(Constants.LocaizationConstants.reason_title.rawValue.localized)"
        
        descLbl.textAlignment = LbLanguage.isArabic ? .right : .left
        placeholderLabel.textAlignment = LbLanguage.isArabic ? .right : .left
        targetMessageLbl.textAlignment = LbLanguage.isArabic ? .right : .left
        reasonTextView.textAlignment = LbLanguage.isArabic ? .right : .left

    }
    
    private func setData() {
        targetMessageLbl.text = targetMessage
    }
    
    @IBAction func submitAction(_ sender: Any) {
        
    }
}

extension ReportsViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        let size = CGSize(
            width: textView.frame.width,
            height: .greatestFiniteMagnitude
        )
        
        var estimatedSize = textView.sizeThatFits(size)
        if estimatedSize.height < 100 {
            estimatedSize.height = 100
        }
        let maxHeight = view.safeAreaLayoutGuide.layoutFrame.height * 0.5
        textView.isScrollEnabled = estimatedSize.height >= maxHeight
        textViewHeightConstraint.constant = min(estimatedSize.height, maxHeight)
        view.layoutIfNeeded()
    }
}
