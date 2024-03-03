//
//  WaselDataSourceProtocol.swift
//  TiaIOS
//
//  Created by Abdul Rahman on 1/27/19.
//  Copyright © 2019 NSIT. All rights reserved.
//

import Foundation

protocol RemoteDataSourceProtocol {
    func messageHandler(model:[String:Any],handler: @escaping Handler<[LabibaModel]>)
    //func getRatingQuestions(handler: @escaping Handler<[GetRatingFormQuestionsModel]>)
   // func submitRating(ratingModel:SubmitRatingModel,handler: @escaping Handler<SubmitRatingResponseModel>)
   // func getHelpPageData(handler: @escaping Handler<HelpPageModel>)
   // func getPrechatForm(handler: @escaping Handler<[PrechatFormModel]>)
    func textToSpeech(model:TextToSpeechModel,handler: @escaping Handler<TextToSpeachResponseModel>)
    func closeConversation(handler: @escaping Handler<[String]>)
    //func updateToken(handler: @escaping Handler<UpdateTokenModel>)
    func getLastBotResponse(handler: @escaping Handler<LastBotResponseModel>)
    func uploadData(model: UploadDataModel,handler: @escaping Handler<UploadDataResponseModel>)
  //  func sendLog(model: LoggingModel, handler: @escaping Handler<Bool>)
    

    func downloadFile(fileURL:URL, handler: @escaping Handler<URL>)-> AnyCancelable
    
    
    func close()

}

