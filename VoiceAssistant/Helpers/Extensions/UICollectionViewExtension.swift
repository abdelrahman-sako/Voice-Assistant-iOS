//
//  UICollectionViewExtension.swift
//  VoiceAssistant
//
//  Created by Osama Hasan on 17/03/2024.
//

import Foundation
import UIKit

extension UICollectionView {
    
    func register<Cell: UICollectionViewCell>(cellClass: Cell.Type) {
        self.register(UINib(nibName: String(describing: Cell.self), bundle: bundle), forCellWithReuseIdentifier: String(describing: Cell.self))
    }
    
    func dequeueReusableCell<Cell: UICollectionViewCell>(withClass name: Cell.Type, for indexPath: IndexPath) -> Cell {
        let identifier = String(describing: name)
        guard let cell = dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? Cell else {
            fatalError("Couldn't find UICollectionViewCell for \(identifier), make sure the cell is registered with UICollectionView")
        }
        
        return cell
    }
    
}

