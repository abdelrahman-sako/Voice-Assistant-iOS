//
//  DataSourceProtocol.swift
//  Royal Jordanian
//
//  Created by Abdulrahman Qasem on 18/07/2022.
//

import Foundation
//import KeychainSwift
typealias Handler<T> = (Swift.Result<T, LabibaError>) -> Void

protocol DataSourceProtocol:RemoteDataSourceProtocol,LocalDataSourceProtocol {
}

//enum KeychainKeys: String{
//    case accountType
//    case userFilter
//    case userToken
//}

//extension DataSourceProtocol{
//
//
//}
