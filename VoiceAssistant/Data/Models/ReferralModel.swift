//
//  ReferralModel.swift
//  Voice Assistant
//
//  Created by Osama Hasan on 15/01/2024.
//

import Foundation

import Foundation
class ReferralModel:Codable {
    var ref:String
    var source:String
    var type:String
    
    init(ref:String ,source:String = "mobile" ,type:String = "") {
        self.ref = ref
        self.source = source
        self.type = type
    }
    
    func modelAsDic() -> [String:Any] {
        let jsonEncoder = JSONEncoder()
        do{
            let encodedData = try jsonEncoder.encode(self)
            let jsonDecoder = JSONDecoder()
            do{
                let model = try jsonDecoder.decode([String:String].self, from: encodedData)
                return model
               
            }catch{
                
            }
        }catch{
            print("Error in .\(#function) while dncoding")
        }
        return [:]
    }
    
   
    
}

class RefModel:Codable{
    private(set) var source:String = "mobile"
    var access_token:String?
    var clientfirstname:String?
    var clientlastname:String?
    var clientprofilepic:String?
    var clientgender:String?
    var client_location:String?
    var client_country:String?
    var client_username:String?
    var client_email:String?
    var token:String?
    var customParameters:[String:String]?
    
    init(access_token:String? = nil , clientfirstname:String? = nil , clientlastname:String? = nil , clientprofilepic:String? = nil , clientgender:String? = nil , client_location:String? = nil, client_country:String? = nil , client_username:String? = nil , client_email:String? = nil , token:String? = nil , customParameters:[String:String]? = nil) {
        self.access_token = access_token
        self.clientfirstname = clientfirstname
        self.clientlastname = clientlastname
        self.clientprofilepic = clientprofilepic
        self.clientgender = clientgender
        self.client_location = client_location
        self.client_country = client_country
        self.client_username = client_username
        self.client_email = client_email
        self.token = token
        self.customParameters = customParameters
    }
    
    func arrayJsonString() -> String {
        let jsonEncoder = JSONEncoder()
        do{
            var dic = [] as [[String:String]] // [[:]] not correct because the array count will be 1 since it has on empty dic element
            let mirrored_object = Mirror(reflecting: self)
            for (_, attr) in mirrored_object.children.enumerated(){
                if let property_name = attr.label , let attr_value = attr.value as? String{
                    dic.append([property_name:attr_value])
                }else if  let attr_value = attr.value as? [String:String]{
                    attr_value.forEach { (element) in
                        dic.append([element.key:element.value])
                    }
                   
                }
            }
            let encodedData = try jsonEncoder.encode(dic)
            return String(data: encodedData, encoding: .utf8)!
        }catch{
            print("Error in .\(#function) while encoding")
        }
        return ""
    }
    
    func customRefModel(object:[String:Any]?) -> String {
        /*
         this function to handel createPost refferals when customer finish the task and return referrals in completion handler
         it also return the basic referral which {"source":"mobile"} in case passing param is nil
         */
        var dic = [] as [[String:Any]]
        dic.append(["source" : source])
        for item in object ?? [:]{
            dic.append([item.key : item.value])
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: dic, options: .fragmentsAllowed)
            return String(data: data, encoding: .utf8) ?? ""
        } catch  {
            print("Error in .\(#function) while encoding" , error.localizedDescription)
        }
        return ""
    }
    
    
   
    
}
