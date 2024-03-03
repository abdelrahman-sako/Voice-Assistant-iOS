//
//  CommonGlobals.swift
//  LabibaBotFramwork
//
//  Created by Abdulrahman on 9/22/19.
//  Copyright © 2019 Abdul Rahman. All rights reserved.
//

import Foundation
import UIKit

public var ipadFactor:CGFloat = 0
public var ipadMargin:CGFloat {
    return ipadFactor*80
}



func applyBotFont(textLang:LabibaLanguages? = nil  ,bold:Bool = false,size:CGFloat = 17)->UIFont{
    let langCode = textLang ?? SharedPreference.shared.botLangCode
    let ipadIncrease = ipadFactor * 9
    var font:UIFont?
    
    switch langCode {
    case .ar:
        if bold {font =  UIFont(name: AssistantConfig.config.font?.boldAR ?? "" , size:size + ipadIncrease )}else{
            font =  UIFont(name: AssistantConfig.config.font?.regAR ?? "", size:size + ipadIncrease )}
    case .en:
        if bold {font =  UIFont(name:  AssistantConfig.config.font?.boldEN ?? "", size:size + 1 + ipadIncrease)}else{
            font =  UIFont(name: AssistantConfig.config.font?.regEN ?? "", size:size + 1 + ipadIncrease)}
    case .de :
        break
    case .ru:
        break
    case .zh :
        break
    }
    
    return font ?? UIFont.systemFont(ofSize: size  + ipadIncrease)
}

func showToast(message : String , inView view :UIView)
{
    let size = message.size(maxWidth: screenWidth - 50 , font: applyBotFont(size: 15))
    let width = size.width + 30
    let toastLabel = UILabel(frame: CGRect(x: screenWidth/2 - width/2, y: screenHeight - 100 , width: width, height: size.height + 10))
    toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.3)
    toastLabel.textColor = UIColor.white
    toastLabel.numberOfLines = 5
    // toastLabel.textAlignment = .center;
    toastLabel.font = applyBotFont(size: 15)
    toastLabel.text = message
    toastLabel.alpha = 1.0
    toastLabel.layer.cornerRadius = 10;
    toastLabel.clipsToBounds  =  true
    view.addSubview(toastLabel)
    UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
        toastLabel.alpha = 0.0
    }, completion: {(isCompleted) in
        toastLabel.removeFromSuperview()
    })
}

func prettyPrintedResponse(url:String = "",statusCode:Int = 0,method:String = "",data:Data,name:String = "")  {
    print("\n***********************************  \(name) RESPONSE  ***********************************\n")
    print("URL:    \(url)")
    print("Method: \(method)")
    print("Code:   \(statusCode)")
    let successBlock:(_ jsonObject:Any) throws ->Void =  {jsonObject in
        let prettyModel = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
        print(String(data: prettyModel, encoding: .utf8)!)
    }
    let errorBlock:(_ error:String)->Void =  { error in
        print("error in \(#function) \n \(error)")
        print(String(data: data, encoding: .utf8))
    }
    do {
        
        if let jsonObjectModel = try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject] {
            try successBlock(jsonObjectModel)
        }else if let jsonObjectModel = try JSONSerialization.jsonObject(with: data, options: []) as? [[String:AnyObject]]{
            try successBlock(jsonObjectModel)
        }else{
            errorBlock("model can't be serialized")
        }
    } catch  {
        errorBlock(error.localizedDescription)
    }
    print("\n*********************************** END \(name) RESPONSE ***********************************\n")
}
