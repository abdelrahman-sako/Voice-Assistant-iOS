//
//  UILabelExtension.swift
//  VoiceAssistant
//
//  Created by Osama Hasan on 21/03/2024.
//

import Foundation
import UIKit
extension UILabel{
    func calculateWidth() -> CGFloat {
        // Implement your logic to calculate the width based on the content of the cell
        // For example, you can use NSString's size(withAttributes:) method
        let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font ??  UIFont.systemFont(ofSize: 14.0)]
        let size = (text! as NSString).size(withAttributes: attributes)
        
        // Add some padding or margins if needed
        let padding: CGFloat = 10
        
        return size.width + padding
    }
    
    func calculateWidth(for text :String) -> CGFloat {
        // Implement your logic to calculate the width based on the content of the cell
        // For example, you can use NSString's size(withAttributes:) method
        let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font ??  UIFont.systemFont(ofSize: 16.0)]
        let size = (text as NSString).size(withAttributes: attributes)
        
        // Add some padding or margins if needed
        let padding: CGFloat = 26
        sizeToFit()
        return size.width + padding
    }
}
