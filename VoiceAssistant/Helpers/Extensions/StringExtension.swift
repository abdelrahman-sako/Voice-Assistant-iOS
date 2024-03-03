//
//  String.swift
//  Voice Assistant
//
//  Created by Osama Hasan on 15/01/2024.
//

import Foundation

extension String {
  
  func hexColorComponents() -> (red: CGFloat, green: CGFloat, blue: CGFloat) {
    
    var cString:String = trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if (cString.hasPrefix("#")) {
      cString.remove(at: cString.startIndex)
    }
    
    if ((cString.count) != 6) {
      return (red: 0, green: 0, blue: 0)
    }
    
    var rgbValue:UInt32 = 0
    Scanner(string: cString).scanHexInt32(&rgbValue)
    
    return (red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0)
  }
}

extension String {

//    func fromBase64() -> String? {
//
//        guard let data = Data(base64Encoded: self) else {
//            return self
//        }
//
//        return String(data: data, encoding: .utf8)
//    }

    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
    
    func toBase64Safe() -> String {
        let base64 = self.toBase64()
        // Replace characters that are not URL-safe
        let urlSafeBase64 = base64
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "+", with: "-")
            .trimmingCharacters(in: ["="]) // Remove padding
        return urlSafeBase64
    }
    
    func base64URLDecode() -> Data? {
        // Add padding if necessary
        let padding = String(repeating: "=", count: (4 - self.count % 4) % 4)
        let base64 = self.replacingOccurrences(of: "_", with: "/").replacingOccurrences(of: "-", with: "+") + padding
        return Data(base64Encoded: base64)
    }
    

}

extension String: ParameterEncoding {

     func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        request.httpBody = data(using: .utf8, allowLossyConversion: false)
        return request
    }

}
