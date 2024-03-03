//
//  UITableViewExtension.swift
//  JATC
//
//  Created by Osama Hasan on 18/01/2023.
//

import Foundation
import UIKit


public extension UITableView {
    
    /**
     Register nibs faster by passing the type - if for some reason the `identifier` is different then it can be passed
     - Parameter type: UITableViewCell.Type
     - Parameter identifier: String?
     */
    func registerCell(type: UITableViewCell.Type, identifier: String? = nil) {
        let cellId = String(describing: type)
        register(UINib(nibName: cellId, bundle: bundle), forCellReuseIdentifier: identifier ?? cellId)
    }
    
    /**
     DequeueCell by passing the type of UITableViewCell
     - Parameter type: UITableViewCell.Type
     */
    func dequeueCell<T: UITableViewCell>(withType type: UITableViewCell.Type) -> T? {
        return dequeueReusableCell(withIdentifier: type.identifier) as? T
    }
    
    /**
     DequeueCell by passing the type of UITableViewCell and IndexPath
     - Parameter type: UITableViewCell.Type
     - Parameter indexPath: IndexPath
     */
    func dequeueCell<T: UITableViewCell>(withType type: T.Type, for indexPath: IndexPath) -> T? {
        return dequeueReusableCell(withIdentifier: type.identifier, for: indexPath) as? T
    }
    
    func reloadRowsInSection(section: Int, oldCount:Int, newCount: Int){

        let maxCount = max(oldCount, newCount)
        let minCount = min(oldCount, newCount)

        var changed = [IndexPath]()

        for i in minCount..<maxCount {
            let indexPath = IndexPath(row: i, section: section)
            changed.append(indexPath)
        }

        var reload = [IndexPath]()
        for i in 0..<minCount{
            let indexPath = IndexPath(row: i, section: section)
            reload.append(indexPath)
        }

        beginUpdates()
        if(newCount > oldCount){
            insertRows(at: changed, with: .fade)
        }else if(oldCount > newCount){
            deleteRows(at: changed, with: .fade)
        }
        if(newCount > oldCount || newCount == oldCount){
            reloadRows(at: reload, with: .none)
        }
        endUpdates()

    }

    
    
}


//extension UITableView {
//    func setEmptyView(title: String, message: String,image:UIImage?) {
//        let emptyView = Bundle.main.loadNibNamed("EmptyView", owner: self)?.first as! EmptyView
//        emptyView.titleLbl.text = title
//        emptyView.descriptionLbl.text = message
//        emptyView.iconImageView.image = image
//        self.backgroundView = emptyView
//    }
//    func restore() {
//        self.backgroundView = nil
//    }
//}

public extension UITableViewCell {
    
    static var identifier: String {
        return String(describing: self)
    }
}

//extension UICollectionView {
//    func setEmptyView(title: String, message: String,image:UIImage?) {
//        let emptyView = Bundle.main.loadNibNamed("EmptyView", owner: self)?.first as! EmptyView
//        emptyView.titleLbl.text = title
//        emptyView.descriptionLbl.text = message
//        emptyView.iconImageView.image = image
//        self.backgroundView = emptyView
//    }
//    func restore() {
//        self.backgroundView = nil
//    }
//}
