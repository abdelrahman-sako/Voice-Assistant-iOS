//
//  Common.swift
//  SwiftScanner
//
//  Created by Jason on 2018/11/29.
//  Copyright © 2018 Jason. All rights reserved.
//

import Foundation
import UIKit
let bundle = Bundle(for: VoiceAssistantViewController.self)

let screenWidth = UIScreen.main.bounds.width

let screenHeight = UIScreen.main.bounds.height

let statusHeight = (UIApplication.shared.connectedScenes
    .compactMap { $0 as? UIWindowScene }
    .first { $0.activationState == .foregroundActive }?
    .statusBarManager?
    .statusBarFrame.height) ?? 0


public func imageNamed(_ name:String)-> UIImage{
    
    guard let image = UIImage(named: name, in: bundle, compatibleWith: nil) else{
        return UIImage()
    }
    
    return image
    
}
