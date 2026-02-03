//
//  BundleExtension.swift
//  VoiceAssistant
//
//  Created by Yazan Kareem on 28/01/2026.
//

import Foundation
import UIKit

extension Bundle {

    static func frameworkBundle(for language: String) -> Bundle {

        let frameworkBundle = Bundle(for: FrameworkBundleToken.self)

        if let path = frameworkBundle.path(forResource: language, ofType: "lproj"),
           let localizedBundle = Bundle(path: path) {
            return localizedBundle
        }

        // fallback (safe)
        return frameworkBundle
    }
}
