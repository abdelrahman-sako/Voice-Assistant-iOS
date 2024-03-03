//
//  LocalDataSourceProtocol.swift
//  Royal Jordanian
//
//  Created by Abdulrahman Qasem on 18/07/2022.
//

import Foundation
protocol LocalDataSourceProtocol {
    
    func getRecentOriginCities(handler:@escaping Handler<[LabibaModel]>)
  

}
