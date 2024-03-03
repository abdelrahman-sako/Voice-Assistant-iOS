//
//  DataExtension.swift
//  Voice Assistant
//
//  Created by Osama Hasan on 15/01/2024.
//

import Foundation
import MobileCoreServices



extension URL {
    
    var mimeType:String {
        
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, self.pathExtension as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        
        return "application/octet-stream"
    }
}
