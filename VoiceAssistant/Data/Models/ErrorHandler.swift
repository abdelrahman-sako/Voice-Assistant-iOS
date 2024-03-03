//
//  ErrorHandler.swift
//  LabibaBotFramwork
//
//  Created by Abdulrahman Qasem on 14/03/2022.
//  Copyright © 2022 Abdul Rahman. All rights reserved.
//

import Foundation
//enum NetworkError: String, Error {
//    case badURL
//    case encodingError = "Encoding error"
//    case empty = "Empty"
//    case unAuthorized = "401"
//    case unknown = "Unknown"
//}
//extension NetworkError: LocalizedError {
//    public var errorDescription: String? {
//        switch self {
//        case .badURL:
//            return "invalid url"
//        case .encodingError:
//            return "Sorry, an unexpected error occurred. \nError code 102"
//        case .empty:
//            return "Sorry, an unexpected error occurred. \nError code 104"
//        case .unAuthorized:
//            return "Authorization denied, please try again later."
//        case .unknown:
//            return "Sorry, an unexpected error occurred. Error code 100"
//        }
//    }
//
//}
extension Int{
    // MARK:  Labiba Custom Errors
    static let EncodingError:Int = 1111110
    static let EmptyResponse:Int = 1111111
    static let UnAuthorized:Int =  1111112
    static let Unknown:Int =       1111113
}

class LabibaError:NSError{
    
    private enum NetworkError:Int {
        case unAuthorized = 401
        
        var labibaError:Int {
            switch self {
            case .unAuthorized:
                return .UnAuthorized
            }
        }
    }
    
    private var stausCode:Int
    private var headers:[AnyHashable : Any]?
    var response:String
    // MARK:  Intializers
    //Failable Initializers for network errors: 401,403 .......
    init?(statusCode:Int,headers:[AnyHashable : Any]?,response:String = ""){
        if let networkError = NetworkError(rawValue: statusCode) {
            self.stausCode = networkError.rawValue
            self.headers = headers
            self.response = response
            super.init(domain: "", code: networkError.labibaError)
        }else{
            return nil
        }
    }
   
    //Labiaba Errors intialaizer: EncodingError,EmptyResponse ....
    init(code:Int, statusCode:Int,headers:[AnyHashable : Any]? = nil,response:String = "") {
        self.stausCode = statusCode
        self.headers = headers
        self.response = response
        super.init(domain: "", code: code)

    }
    
    //NSError native error intialaizer: NSURLErrorCancelled,NSURLErrorTimedOut ..
    init(error:Error,statusCode:Int,headers:[AnyHashable : Any]?  = nil,response:String = "") {
        self.stausCode = statusCode
        self.headers = headers
        self.response = response
        let err = error as NSError
        super.init(domain: err.domain, code: err.code)
       
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    
    override var localizedDescription: String { // user popup
        // return "" to ban popup
        switch code {
            // custom errors
        case .EncodingError:
            return "\(localString("mappingErr")) \n\(rayID)"
        case .EmptyResponse:
            return localString("emptyResponseErr")
        case .UnAuthorized:
            return localString("authDenied")
        case .Unknown:
            return localString("unknownErr")
            
            // NSError errors
        case  NSURLErrorTimedOut:
            return localString(localString("timeoutErr"))
        case NSURLErrorSecureConnectionFailed ,NSURLErrorServerCertificateHasBadDate,NSURLErrorServerCertificateUntrusted,NSURLErrorServerCertificateHasUnknownRoot,NSURLErrorServerCertificateNotYetValid,NSURLErrorClientCertificateRejected,NSURLErrorClientCertificateRequired,NSURLErrorCannotLoadFromNetwork,NSURLErrorAppTransportSecurityRequiresSecureConnection :
            return localString("sslErr")
        case NSURLErrorCancelledReasonUserForceQuitApplication,NSURLErrorUserCancelledAuthentication,NSURLErrorCancelledReasonBackgroundUpdatesDisabled,NSURLErrorCancelledReasonInsufficientSystemResources,NSURLErrorCancelled:
            return "" // no popup
        case NSURLErrorNetworkConnectionLost,NSURLErrorInternationalRoamingOff, NSURLErrorNotConnectedToInternet,NSURLErrorDataNotAllowed:
            return localString("checkConnectionErr")
            
            
        case NSURLErrorUnknown:
            return localString("unknownErr")
        
        case NSURLErrorBadURL,NSURLErrorUnsupportedURL,NSURLErrorDNSLookupFailed:
            return localString("urlErr")
        
        case NSURLErrorCannotFindHost,NSURLErrorCannotConnectToHost,NSURLErrorNetworkConnectionLost,NSURLErrorResourceUnavailable,NSURLErrorRedirectToNonExistentLocation,NSURLErrorBadServerResponse:
            return localString("serverNotReachableErr")
        case NSURLErrorHTTPTooManyRedirects:
            return localString("tooManyRedirects")
        case NSURLErrorCannotDecodeRawData,NSURLErrorCannotDecodeContentData,NSURLErrorCannotParseResponse,NSURLErrorDataLengthExceedsMaximum,NSURLErrorFileOutsideSafeArea:
            return localString("dataErr")
        
        case NSURLErrorFileDoesNotExist,NSURLErrorFileIsDirectory,NSURLErrorNoPermissionsToReadFile,NSURLErrorCannotCreateFile,NSURLErrorCannotOpenFile,NSURLErrorCannotCloseFile,NSURLErrorCannotWriteToFile,NSURLErrorCannotRemoveFile,NSURLErrorCannotMoveFile,NSURLErrorDownloadDecodingFailedMidStream,NSURLErrorDownloadDecodingFailedToComplete:
            return localString("fileErr")
        
        case NSURLErrorCallIsActive:
            return localString("callActiveErr")
//        case NSURLErrorRequestBodyStreamExhausted:
//            return localString("")
        case NSURLErrorBackgroundSessionRequiresSharedContainer,NSURLErrorBackgroundSessionInUseByAnotherProcess,NSURLErrorBackgroundSessionWasDisconnected:
            return localString("bgSessionError")
        default:
            return localString("unknownErr")
        }
    }
    
    
    var logDescription:String {
        var discription:String = ""
        switch code {
            // custom errors
        case .EncodingError:
            discription = "Mapping Error\n Ray ID = \(rayID)"
        case .EmptyResponse:
            discription = "Empty Respose"
        case .UnAuthorized:
            discription = "Authorization denied"
        case .Unknown:
            discription = "Unknown error"
            
        case  NSURLErrorTimedOut:
            discription = "Time out"
        case NSURLErrorSecureConnectionFailed ,NSURLErrorServerCertificateHasBadDate,NSURLErrorServerCertificateUntrusted,NSURLErrorServerCertificateHasUnknownRoot,NSURLErrorServerCertificateNotYetValid,NSURLErrorClientCertificateRejected,NSURLErrorClientCertificateRequired,NSURLErrorCannotLoadFromNetwork,NSURLErrorAppTransportSecurityRequiresSecureConnection :
            discription = "SSL Error"
        case NSURLErrorCancelledReasonUserForceQuitApplication,NSURLErrorUserCancelledAuthentication,NSURLErrorCancelledReasonBackgroundUpdatesDisabled,NSURLErrorCancelledReasonInsufficientSystemResources,NSURLErrorCancelled:
            discription = "Request cancelled"
        case NSURLErrorNetworkConnectionLost,NSURLErrorInternationalRoamingOff, NSURLErrorNotConnectedToInternet,NSURLErrorDataNotAllowed:
            discription = "No internet connection"
            
            
        case NSURLErrorUnknown:
            discription = "Unknown Error"
        
        case NSURLErrorBadURL,NSURLErrorUnsupportedURL,NSURLErrorDNSLookupFailed:
            discription = "URL Error"
        
        case NSURLErrorCannotFindHost,NSURLErrorCannotConnectToHost,NSURLErrorNetworkConnectionLost,NSURLErrorResourceUnavailable,NSURLErrorRedirectToNonExistentLocation,NSURLErrorBadServerResponse:
            discription = "Server Not Reachable"
        case NSURLErrorHTTPTooManyRedirects:
            discription = "Too Many Redirects"
        case NSURLErrorCannotDecodeRawData,NSURLErrorCannotDecodeContentData,NSURLErrorCannotParseResponse,NSURLErrorDataLengthExceedsMaximum,NSURLErrorFileOutsideSafeArea:
            discription = "Data Error"
        
        case NSURLErrorFileDoesNotExist,NSURLErrorFileIsDirectory,NSURLErrorNoPermissionsToReadFile,NSURLErrorCannotCreateFile,NSURLErrorCannotOpenFile,NSURLErrorCannotCloseFile,NSURLErrorCannotWriteToFile,NSURLErrorCannotRemoveFile,NSURLErrorCannotMoveFile,NSURLErrorDownloadDecodingFailedMidStream,NSURLErrorDownloadDecodingFailedToComplete:
            discription = "File Error"
        
        case NSURLErrorCallIsActive:
            discription = "Call Active Error"
//        case NSURLErrorRequestBodyStreamExhausted:
//            return localString("")
        case NSURLErrorBackgroundSessionRequiresSharedContainer,NSURLErrorBackgroundSessionInUseByAnotherProcess,NSURLErrorBackgroundSessionWasDisconnected:
            discription = "Background Session Error"
        default:
            break
        }
        
        return discription + "\n" + localizedDescription + "\n" + super.localizedDescription + "\n status code = \(stausCode)"
    }
    
    
    var rayID:String{
        if let rayID = headers?["cf-ray"] as? String {
            return "\(rayID) "
        }
        return ""
    }
    
    static func generalError()-> LabibaError {
        LabibaError(code: .Unknown, statusCode: 0)
    }
}
