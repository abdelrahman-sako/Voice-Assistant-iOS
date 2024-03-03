//
//  WaselApiEndPoints.swift
//  TiaIOS
//
//  Created by Abdul Rahman on 1/27/19.
//  Copyright © 2019 NSIT. All rights reserved.
//
import Dispatch

//MARK: - ApiEndPoints
public enum ApiEndPoints: String{

    static let baseUrl = "https://botbuilder.labiba.ai"
    static let RatingQuestions = "\(baseUrl)/api/MobileAPI/FetchQuestions"
 
    case getRatingQuestions = "/api/MobileAPI/FetchQuestions"
    case submitRating = "/api/ratingform/submit"
    
}

//MARK: - Endpoint
protocol EndPointProtocol {
    var url: String { get set }
    var httpMethod: HTTPMethod { get set }
    var headers: [String:String]? { get set }
}

struct EndPoint: EndPointProtocol {
    
    
    //MARK: - Properties
    var url: String
    var httpMethod: HTTPMethod
    var headers: [String:String]?
    let group = DispatchGroup() // initialize

    //MARK: - Initializers
    
    /// Initializes an Endpoint object.
    ///
    /// - Parameters:
    ///   - address: TIAApiEndPoints Enum
    ///   - httpMethod: HTTPMethod
    ///   - headers: [[String: String]], Optional with nil as default value.
    init(url: String, httpMethod: HTTPMethod, headers: [String:String]? = nil) {
        self.url = url
        self.httpMethod = httpMethod
        self.headers = headers
//        self.headers = getHeaders(headers: headers)
    }
//    func getSecurityHeaders()->[[String:String]] {
//        if let tokens = KeyChainManager.load(key: "labibaTokens"){
//            return tokens.to(type: [[String: String]].self)
//        }else{
//            return []
//        }
//    }
    func getHeaders(headers:[String:String]? = nil)->[String:String]{
        var finalHeaders = headers
      //  let securityHeaders = getSecurityHeaders()
//        for tokenDict in securityHeaders{
//            finalHeaders = tokenDict
//        }
        return finalHeaders ?? headers!
    }
}
