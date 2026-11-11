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
        setupMessageLabel()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    private func setupMessageLabel() {
        let font = AssistantConfig.botViewheme.scallTextStyle.font
        messageLabel.textColor = AssistantConfig.botViewheme.scallTextStyle.color
        messageLabel.font = font
        messageLabel.delegate = self
        messageLabel.isEditable = false
        messageLabel.isSelectable = true
        messageLabel.dataDetectorTypes = .link
        messageLabel.linkTextAttributes = [
            .foregroundColor: AssistantConfig.botViewheme.linkColor,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
    }

    func setMessageData(data: String) {
        let regularFont = AssistantConfig.botViewheme.scallTextStyle.font ?? messageLabel.font ?? UIFont.systemFont(ofSize: 14)
        let boldFont = AssistantConfig.botViewheme.defualtTextStyle.font ?? UIFont.boldSystemFont(ofSize: regularFont.pointSize)
        let textColor = AssistantConfig.botViewheme.scallTextStyle.color
        let linkColor = AssistantConfig.botViewheme.linkColor

        if data.containsAnchorTags || data.containsHTML {
            let attributed = data.htmlAttributedString(
                regularFont: regularFont,
                boldFont: boldFont,
                color: textColor,
                linkColor: linkColor
            )
            if attributed.length > 0 {
                messageLabel.attributedText = attributed
                return
            }
        }

        messageLabel.font = regularFont
        messageLabel.textColor = textColor
        messageLabel.text = data
    }
}

extension BotTextMessageCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith asm: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        openURL(asm)
        return false
    }

    @available(iOS 17.0, *)
    func textView(_ textView: UITextView, primaryActionFor textItem: UITextItem, defaultAction: UIAction) -> UIAction? {
        if case .link(let url) = textItem.content {
            return UIAction { [weak self] _ in
                self?.openURL(url)
            }
        }
        return defaultAction
    }

    private func openURL(_ url: URL) {
        var targetURL = url
        let absolute = url.absoluteString.trimmingCharacters(in: .whitespacesAndNewlines)
        if targetURL.scheme == nil || targetURL.scheme?.isEmpty == true {
            if let fixed = URL(string: "https://\(absolute)") {
                targetURL = fixed
            }
        }
        UIApplication.shared.open(targetURL, options: [:], completionHandler: nil)
    }
}
