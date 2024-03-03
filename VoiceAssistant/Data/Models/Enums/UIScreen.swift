//
//  UIScreen.swift
//  Voice Assistant
//
//  Created by Osama Hasan on 17/01/2024.
//

import Foundation
import UIKit
extension UIScreen {
    /// Gets the iPhone / iPad screen type for the currently running device
    @objc public static var current: ScreenType {
        let screenLongestSide: CGFloat = max(main.bounds.width, main.bounds.height)
        switch screenLongestSide {
        case 480:
            return .iPhone3_5
        case 568:
            return .iPhone4_0
        case 667:
            return .iPhone4_7
        case 736:
            return .iPhone5_5
        case 812:
            return .iPhone5_8
        case 896:
            return main.scale == 3 ? .iPhone6_5 : .iPhone6_1
        case 1024:
            return .iPad9_7
        case 1112:
            return .iPad10_5
        case 1366:
            return .iPad12_9
        case  1000... :
            return .ipad
        default:
            return .unknown
        }
    }
}
@objc public enum ScreenType: Int {
    /// 3.5 inch iPhone (4, 4S)
    case iPhone3_5
    
    /// 4.0 inch iPhone (5, 5S, 5C, SE)
    case iPhone4_0
    
    /// 4.7 inch iPhone (6, 7, 8)
    case iPhone4_7
    
    /// 5.5 inch iPhone (6+, 7+, 8+)
    case iPhone5_5
    
    /// 5.8 inch iPhone (X, XS)
    case iPhone5_8
    
    /// 6.1 inch iPhone (XR)
    case iPhone6_1
    
    /// 6.5 inch iPhone (XS Max)
    case iPhone6_5
    
    /// 9.7 inch iPad
    case iPad9_7
    
    /// 10.5 inch iPad
    case iPad10_5
    
    /// 12.9 inch iPad
    case iPad12_9
    /// mine
    case ipad
    //
    /// Couldn't determine device
    case unknown
}

extension ScreenType: Comparable {
    public static func < (lhs: ScreenType, rhs: ScreenType) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}
