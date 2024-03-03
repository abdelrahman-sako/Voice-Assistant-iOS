//
//  ContentSizedTableView.swift
//  Voice Assistant
//
//  Created by Osama Hasan on 21/01/2024.
//

import Foundation
import UIKit
final class ContentSizedTableView: UITableView {
    override var contentSize: CGSize {
        didSet {
            animateContentSizeChange()
        }
    }

    private func animateContentSizeChange() {
        UIView.animate(withDuration: 0.3) {
            self.invalidateIntrinsicContentSize()
            self.superview?.layoutIfNeeded()
        }
    }

    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        let height = contentSize.height + contentInset.bottom + contentInset.top + 20
        if height < 420{
            return CGSize(width: UIView.noIntrinsicMetric, height: 420)
        }
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height + contentInset.bottom + contentInset.top + 20)
    }
    

}
