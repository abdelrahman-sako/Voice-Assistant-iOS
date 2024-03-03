//
//  UploadDataModel.swift
//  LabibaBotFramwork
//
//  Created by Abdulrahman Qasem on 30/11/2022.
//  Copyright © 2022 Abdul Rahman. All rights reserved.
//

import Foundation
class UploadDataModel {
    var data:Data
    var fileName:String
    var mimeType:String
    
    init(data:Data,fileName:String,mimeType:String) {
        self.data = data
        self.fileName = fileName
        self.mimeType = mimeType
    }
}
