//
//  WaselDataSource.swift
//  TiaIOS
//
//  Created by Abdul Rahman on 1/27/19.
//  Copyright © 2019 NSIT. All rights reserved.
//

import Foundation
final class DataSource: DataSourceProtocol{

    
   
    
   
    
   
  
    
   
    //MARK: Shared Instance
    static var shared: DataSourceProtocol = DataSource()
    
    //MARK: - Properties
    lazy var remoteDataSource:RemoteDataSourceProtocol = RemoteDataSource()
    lazy var localDataSource:LocalDataSourceProtocol = LocalDataSource()
    
    //MARK: - Initializers
    /// Can't init
    private init() {
    }
  
    
    //MARK: - Remote Database
    func messageHandler(model: [String : Any], handler: @escaping Handler<[LabibaModel]>) {
        remoteDataSource.messageHandler(model: model, handler: handler)
    }
    
    
//    func submitRating(ratingModel: SubmitRatingModel, handler: @escaping Handler<SubmitRatingResponseModel>) {
//        remoteDataSource.submitRating(ratingModel: ratingModel, handler: handler)
//    }
//    
//    func getRatingQuestions(handler: @escaping Handler<[GetRatingFormQuestionsModel]>) {
//        remoteDataSource.getRatingQuestions(handler: handler)
//    }
//    
//    func getHelpPageData(handler: @escaping Handler<HelpPageModel>) {
//        remoteDataSource.getHelpPageData(handler: handler)
//    }
//    
//    func getPrechatForm(handler: @escaping Handler<[PrechatFormModel]>) {
//        remoteDataSource.getPrechatForm(handler: handler)
//    }
    
    func textToSpeech(model: TextToSpeechModel, handler: @escaping Handler<TextToSpeachResponseModel>) {
        remoteDataSource.textToSpeech(model: model, handler: handler)
    }
    
    func closeConversation(handler: @escaping Handler<[String]>) {
        remoteDataSource.closeConversation(handler: handler)
    }
    
//    func updateToken(handler: @escaping Handler<UpdateTokenModel>) {
//        remoteDataSource.updateToken(handler: handler)
//    }
    
    //MARK: - Local Database
    func getRecentOriginCities(handler: @escaping Handler<[LabibaModel]>) {
        localDataSource.getRecentOriginCities(handler: handler)
    }
    func getLastBotResponse(handler: @escaping Handler<LastBotResponseModel>) {
        remoteDataSource.getLastBotResponse(handler: handler)
    }
    func uploadData(model: UploadDataModel, handler: @escaping Handler<UploadDataResponseModel>) {
        remoteDataSource.uploadData(model: model, handler: handler)
    }
//    func sendLog(model: LoggingModel, handler: @escaping Handler<Bool>) {
//        remoteDataSource.sendLog(model: model, handler: handler)
//    }
    
    func downloadFile(fileURL: URL, handler: @escaping Handler<URL>) -> AnyCancelable {
        return remoteDataSource.downloadFile(fileURL: fileURL, handler: handler)
    }
    
  
    
//    func sendData(_ data: Data, handler: @escaping Handler<UploadDataResponseModel>) {
//        remoteDataSource.sendData(data, handler: handler)
//    }
//    func sendPhoto(_ data: Data, handler: @escaping Handler<UploadDataResponseModel>) {
//        remoteDataSource.sendPhoto(data, handler: handler)
//    }
    
    
    
    func close() {
        remoteDataSource.close()
    }
//    func sendPhoto(_ photo: UIImage, handler: @escaping Handler<String>) {
//        remoteDataSource.sendPhoto(photo, handler: handler)
//    }
//    func sendFile(_ url: URL, handler: @escaping Handler<String>) {
//        remoteDataSource.sendFile(url, handler: handler)
//    }
}



