//
//  ContentSizedCollectionView.swift
//  VoiceAssistant
//
//  Created by Osama Hasan on 17/03/2024.
//

import Foundation
import UIKit


class ContentSizedCollectionView: UICollectionView {
    override var contentSize:CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: collectionViewLayout.collectionViewContentSize.height)
    }
}
