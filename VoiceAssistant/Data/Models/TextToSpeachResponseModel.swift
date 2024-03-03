//
//  TextToSpeachResponseModel.swift
//  LabibaBotFramwork
//
//  Created by Abdulrahman Qasem on 20/11/2022.
//  Copyright © 2022 Abdul Rahman. All rights reserved.
//

import Foundation
class TextToSpeachResponseModel:Codable {
    var file:String?
    var status:String?
    var audioContent: String?
}
