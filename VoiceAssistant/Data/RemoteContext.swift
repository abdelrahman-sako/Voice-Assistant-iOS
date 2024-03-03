//
//  RemoteContext.swift
//  Wasel
//
//  Created by Abdul Rahman on 6/14/19.
//  Copyright © 2019 Abdul Rahman. All rights reserved.
//

import Foundation

enum ContentType: String{
    case json = "application/json"
    case urlEncoded = "application/x-www-form-urlencoded"
}
protocol AnyCancelable{
    func cancelRequest()
}
extension DataRequest:AnyCancelable {
    func cancelRequest() {
        super.cancel()
    }
    
   
}
extension URLSessionDownloadTask:AnyCancelable {
    func cancelRequest() {
        super.cancel()
    }
}

final class RemoteContext {
    
    
    //MARK: - Properties
    
    
    private var sessionManager: SessionManager!
    
    //////////////////////////////////
    
    
    //MARK: - Initializers
    /// Initialize session manager and Alamofire configurations
    init(){
        sessionManagerConfiguration()
    }
    
    func sessionManagerConfiguration(token:String = SharedPreference.shared.jwt )  {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = AssistantConfig.config.timeoutInterval
        configuration.httpAdditionalHeaders?.updateValue("application/json", forKey: "Accept")
        
//        if UpdateTokenModel.isTokenRequeird(){
//            configuration.httpAdditionalHeaders = ["Authorization":"Bearer \(token)"]
//        }
        var serverTrustPolicies: [String: ServerTrustPolicy] = [:]
        if AssistantConfig.config.bypassSSLCertificateValidation, let url = URL(string: AssistantConfig.config.baseURL) {
            serverTrustPolicies[url.host ?? ""] = .disableEvaluation
        }
        let servertrustManager = ServerTrustPolicyManager(policies: serverTrustPolicies)
        
        sessionManager = SessionManager(configuration: configuration,serverTrustPolicyManager: servertrustManager)
    }
    
    /// check  token  and update it if it's required, then continue with the normal request flow
    ///
    /// - Parameters:
    ///   - endPoint: Endpoint
    ///   - parameters: [String: Any], Optional
    ///   - completion: A callback function invoked when the operation is completed.
    
    func withTokenRequest(endPoint: EndPointProtocol, parameters:Parameters?, completion: @escaping Handler<Data>) {
        // this should be changed since we can make alamofire wait untill certain request response return
//        checkToken { result in
//            switch result {
//            case .success(_):
                request(endPoint: endPoint, parameters: parameters, completion: completion)
//            case .failure(let error):
//                completion(.failure(error))
//            }
       // }
    }
    
    func withTokenRequest(endPoint: EndPointProtocol, parameters:String?, completion: @escaping Handler<Data>) {
        // this should be changed since we can make alamofire wait untill certain request response return
        let parameters = "\"\(parameters!)\"".trimmingCharacters(in: .whitespacesAndNewlines)
       
       // checkToken { result in
//            switch result {
//            case .success(_):
                request(endPoint: endPoint, parameters: parameters,completion: completion)
//            case .failure(let error):
//                completion(.failure(error))
//            }
      //  }
    }
    /// Creates an HTTP request to a given endpoint address
    ///
    /// - Parameters:
    ///   - endPoint: Endpoint
    ///   - parameters: [String: Any], Optional
    ///   - completion: A callback function invoked when the operation is completed.
    func request(endPoint: EndPointProtocol, parameters:Parameters?, completion: @escaping Handler<Data>){
        let urlRequest = buildURlRequest(endPoint: endPoint, params: parameters)
       
        sendRequest(reqestUrl: urlRequest) { (result) in
            switch result{
            case .success(let response):
                guard let wsResponse = response as? DataResponse<Data> else{
                    let error = LabibaError(code: .Unknown, statusCode: 0)
                    completion(.failure(error))
                    return
                }
                if let wsData = wsResponse.data {
                    completion(.success(wsData))
                }else {
                    let headers =  wsResponse.response?.allHeaderFields
                    let error =  LabibaError(statusCode: wsResponse.response?.statusCode ?? 0, headers:headers) ?? LabibaError(code: .Unknown, statusCode: wsResponse.response?.statusCode ?? 0,headers: headers)
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }//End sendRequest
    }
    
    func request(endPoint: EndPointProtocol, parameters:String?, completion: @escaping Handler<Data>){
        
        
        sendRequest(reqestUrl: URL(string: endPoint.url)!,encoding: parameters ?? "") { (result) in
            switch result{
            case .success(let response):
                guard let wsResponse = response as? DataResponse<Data> else{
                    let error = LabibaError(code: .Unknown, statusCode: 0)
                    completion(.failure(error))
                    return
                }
                if let wsData = wsResponse.data {
                    completion(.success(wsData))
                }else {
                    let headers =  wsResponse.response?.allHeaderFields
                    let error =  LabibaError(statusCode: wsResponse.response?.statusCode ?? 0, headers:headers) ?? LabibaError(code: .Unknown, statusCode: wsResponse.response?.statusCode ?? 0,headers: headers)
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }//End sendRequest
    }
    
    /// Creates an HTTP request to a given endpoint address
    ///
    /// - Parameters:
    ///   - endPoint: Endpoint
    ///   - parameters: [Any], Optional array of objects
    ///   - completion: A callback function invoked when the operation is completed.
    func request(endPoint: EndPointProtocol, paramsAny:[Any]?, completion: @escaping Handler<Any>){
        let params = paramsAny?.asParameters()
        let urlRequest = buildURlRequestArray(endPoint: endPoint, params: params)
        sendRequest(reqestUrl: urlRequest) { (result) in
            switch result{
                
            case .success(let response):
                guard let wsResponse = response as? DataResponse<Data> else{
                    completion(.success(Data()))
                    return
                }
                if let wsData = wsResponse.data {
                    completion(.success(wsData))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
    }
    
    func downLoad(url: URL,completion: @escaping Handler<URL>)->AnyCancelable{
        var downloadTask:URLSessionDownloadTask
        downloadTask = sessionManager.session.downloadTask(with: url  , completionHandler: {(url, response, err) in
            if let error = err {
                let labibaError = LabibaError(error: error, statusCode: 0)
                completion(.failure(labibaError))
                return
            }
            
            if let url = url {
                completion(.success(url))
                
            }else{
                let labibaError = LabibaError(code: .Unknown, statusCode: 0)
                completion(.failure(labibaError))
            }
        })
        
        downloadTask.resume()
        return downloadTask
    }
    
//    func download(url:String,completion: @escaping Handler<URL>){
//
//        URLSession.shared.downloadTask(with: URL(string: url)!) { (location, _, error) in
//            guard let location = location, error == nil else {
//                let labibaError = LabibaError(error: error!, statusCode: 0)
//                completion(.failure(labibaError))
//                return
//            }
//            
//            // Move the downloaded file to the documents directory or another appropriate location
//            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//            let destinationURL = documentsURL.appendingPathComponent("downloadedPass.pkpass")
//            try FileManager.default.moveItem(at: location, to: destinationURL)
//        }
//    }
   
    func multipartRequest(endPoint: EndPointProtocol, params:Parameters?, multipartName: String?, uploadFiles: [Data]?,encoding:String.Encoding? = nil,mimeType:String,fileName:String, completion: @escaping Handler<Data>){
        let urlRequest = buildURlRequestArray(endPoint: endPoint, params: params)
        sessionManager.upload(multipartFormData: { (multipartFormData) in
            if let params = params{
                for (key,value) in params {
                    multipartFormData.append((value as! String).data(using: .utf8)!, withName: key)
                }
            }
            if let files = uploadFiles, let name = multipartName{
                for file in files{
                    multipartFormData.append(file, withName: "Filedata", fileName: fileName, mimeType: mimeType)
                }
            }
        }, with: urlRequest) { (result) in
            
            switch result {
            case .success(let upload, _, _):
                
                upload.validate().responseData(completionHandler: { [weak self] (dataResponse) in
                    switch dataResponse.result {
                    case .success:
                        if let wsData = dataResponse.data {
                            completion(.success(wsData))
                        }else{
                            
                            let error = LabibaError(code: .EmptyResponse,
                                                    statusCode: dataResponse.response?.statusCode ?? 0,
                                                    headers: dataResponse.response?.allHeaderFields,response: "")
                            completion(.failure(error))
                        }
                    case .failure(let responseError as NSError):
                        let error = self?.buildError(response: dataResponse, responseError: responseError)
                        completion(.failure(error!))
                    }
                })
            case .failure(let responseError as NSError):
                let error = LabibaError(error: responseError, statusCode: responseError.code)
                completion(.failure(error))
            }
        }
    }
    
    
    
    /// Helper method to send an Http request to a given Endpoint.
    ///
    /// - Parameters:
    ///   - endPoint: Endpoint object
    ///   - parameters: Http request parameter as [String: Any], optional.
    ///   - completion: A callback function
    private func sendRequest (reqestUrl: URLRequestConvertible, completion: @escaping Handler<Any> ) {
        sessionManager.request(reqestUrl).validate().responseData { (response) in
            self.printResponse(reqestUrl: reqestUrl, responseData: response)
            switch response.result {
            case .success:
                completion(.success(response))
            case .failure(let responseError as NSError):
                let error = self.buildError(response: response, responseError: responseError)
                completion(.failure(error))
            }
        }//End sessionManager.request
        
    }
    
    private func sendRequest (reqestUrl: URL, encoding: ParameterEncoding = URLEncoding.default,
                              completion: @escaping Handler<Any> ) {
        sessionManager.request(reqestUrl,method: .post,encoding: encoding,headers: ["Content-Type":"application/json"]).validate().responseData { (response) in
            //self.printResponse(reqestUrl: reqestUrl, responseData: response)
            switch response.result {
            case .success:
                completion(.success(response))
            case .failure(let responseError as NSError):
                let error = self.buildError(response: response, responseError: responseError)
                completion(.failure(error))
            }
        }//End sessionManager.request
        
    }
    
    
    /// Helper method to build an HTTP request.
    ///
    /// - Parameters:
    ///   - endPoint: Endpoint object.
    ///   - params: Http request parameter as [String: Any], optional.
    /// - Returns: An Http request object of type URLRequestConvertible.
    private func buildURlRequest(endPoint: EndPointProtocol, params: Parameters?) -> URLRequestConvertible{
        let relativePath =  endPoint.url
        let url = URL(string: relativePath)!
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endPoint.httpMethod.rawValue
        
        var encoding: ParameterEncoding!
        
        
        
        if var headers = endPoint.headers {
            headers.keys.forEach({ (key) in
                urlRequest.setValue(headers[key]!, forHTTPHeaderField: key )
            })
            
            if let contentType = headers["Content-Type"] {
                switch contentType {
                case ContentType.json.rawValue:
                    encoding = JSONEncoding.default
                case ContentType.urlEncoded.rawValue:
                    encoding = URLEncoding.default
                default:
                    encoding = JSONEncoding.default
                }
            }else{
                encoding = JSONEncoding.default
            }
        }else if endPoint.httpMethod == .post {
            encoding = URLEncoding(destination: .httpBody)
        }
      
        if endPoint.httpMethod == .get || endPoint.httpMethod == .delete  {
            encoding = URLEncoding.default // this == URLEncoding(destination: .queryString) (not sure) from moyad
        }
        
        return try! encoding.encode(urlRequest, with: params)
    }
    
    
    /// Helper method to build an HTTP request.
    ///
    /// - Parameters:
    ///   - endPoint: Endpoint object.
    ///   - params: Http request parameter as [Any], optional.
    /// - Returns: An Http request object of type URLRequestConvertible.
    private func buildURlRequestArray(endPoint: EndPointProtocol, params: Parameters?) -> URLRequestConvertible{
        let relativePath =  endPoint.url
        let url = URL(string: relativePath)!
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endPoint.httpMethod.rawValue
        urlRequest.timeoutInterval = AssistantConfig.config.timeoutInterval
        if let headers = endPoint.headers {
            headers.keys.forEach({ (key) in
                urlRequest.setValue(headers[key]!, forHTTPHeaderField: key )
            })
        }
        
        
        let encoding = ArrayEncoding()
        
        return try! encoding.encode(urlRequest, with: params)
    }
    
    func buildError(response:  DataResponse<Data>, responseError: NSError?) -> LabibaError{
       
        let defaultCodeError = LabibaError(code: .Unknown, statusCode:  response.response?.statusCode ?? 0)
        let defaultError = LabibaError(statusCode: response.response?.statusCode ?? 0, headers: response.response?.allHeaderFields) ?? defaultCodeError
        guard let data = response.data else {
            return defaultError
        }
        let dataString = String(data: data, encoding: .utf8) ?? ""
        if let responseError = responseError {
            return LabibaError(error: responseError, statusCode: response.response?.statusCode ?? 0,headers: response.response?.allHeaderFields,response: dataString)
        }else{
            return defaultError
        }
    }
    
    private func printResponse(reqestUrl: URLRequestConvertible,responseData:DataResponse<Data>)  {
        if let url = reqestUrl.urlRequest?.url {
            prettyPrintedResponse(url: url.absoluteString,
                                  statusCode: responseData.response?.statusCode ?? 0 ,
                                  method: reqestUrl.urlRequest?.httpMethod ?? "",
                                  data: responseData.data ?? Data(),
                                  name:  url.lastPathComponent)
        }
    }
    
    //MARK: - Update Token
//    private func checkToken(handler: @escaping Handler<Bool>){
//        if UpdateTokenModel.isTokenRequeird() && !UpdateTokenModel.isTokenValid()  {
//            updateToken { result  in
//                switch result {
//                case .success(let model):
//                    UpdateTokenModel.saveToken(token: model.token)
//                    self.sessionManagerConfiguration(token: model.token ?? "")
//                    print("token updated")
//                    handler(.success(true))
//                case .failure(let error):
//                    handler(.failure(error))
//                }
//            }
//        }else {
//            handler(.success(true))
//        }
//    }
//    
//    private func updateToken(handler: @escaping Handler<UpdateTokenModel>) {
//        let url =   Labiba._updateTokenUrl
//        let endPoint = EndPoint(url: url, httpMethod: .post,headers: ["Content-Type": "application/json"])
//        let params:[String:Any] = [
//            "Username":Labiba.jwtAuthParamerters.username,
//            "Password":Labiba.jwtAuthParamerters.password
//        ]
//        request(endPoint: endPoint, parameters: params) { result in
//            switch  result {
//            case .success(let data):
//                let decoder =  JSONDecoder()
//                do {
//                    let model = try decoder.decode(UpdateTokenModel.self, from: data)
//                    handler(.success(model))
//                } catch {
//                    let dataString = String(data: data, encoding: .utf8) ?? ""
//                   let error =  LabibaError(code: .EncodingError, statusCode: 200,response: dataString)
//                    handler(.failure(error))
//                }
//            case .failure(let error):
//                handler(.failure(error))
//            }
//        }
//    }
    
    func close()  {
        sessionManager?.session.getAllTasks(completionHandler: {$0.forEach({$0.cancel()})})
    }
   
}


private let arrayParametersKey = "arrayParametersKey"

/// Extenstion that allows an array be sent as a request parameters
extension Array {
    /// Convert the receiver array to a `Parameters` object.
    func asParameters() -> Parameters {
        return [arrayParametersKey: self]
    }
}


/// Convert the parameters into a json array, and it is added as the request body.
/// The array must be sent as parameters using its `asParameters` method.
 struct ArrayEncoding: ParameterEncoding {
    
    /// The options for writing the parameters as JSON data.
     let options: JSONSerialization.WritingOptions
    
    
    /// Creates a new instance of the encoding using the given options
    ///
    /// - parameter options: The options used to encode the json. Default is `[]`
    ///
    /// - returns: The new instance
     init(options: JSONSerialization.WritingOptions = []) {
        self.options = options
    }
    
     func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var urlRequest = try urlRequest.asURLRequest()
        
        guard let parameters = parameters,
            let array = parameters[arrayParametersKey] else {
                return urlRequest
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: array, options: options)
            
            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
            
            urlRequest.httpBody = data
            
        } catch {
            throw AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
        }
        
        return urlRequest
    }
}

class ErrorModel:Codable,Error {
    var message:String = ""//localized(forKey: .unKnownError)
    var error:String?
    var ErrorCode:String?
    init(message:String  ) {
        self.message = message
    }
    
    static func generalError()-> ErrorModel {
        ErrorModel(message: "error-msg".localForChosnLangCodeBB)
    }
   
}

class ResponseModel<T:Decodable>:Decodable {
    var success:Bool?
    var ErrorMessage:String?
    var data:T?
    var Link:String?
}
