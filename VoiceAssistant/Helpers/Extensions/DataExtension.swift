//
//  DataExtension.swift
//  Voice Assistant
//
//  Created by Osama Hasan on 15/01/2024.
//

import Foundation
import MobileCoreServices



import UniformTypeIdentifiers

extension URL {
    var mimeType: String {
        if let type = UTType(filenameExtension: self.pathExtension),
           let mimeType = type.preferredMIMEType {
            return mimeType
        }

        return "application/octet-stream"
    }
}
