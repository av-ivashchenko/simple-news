//
//  SNNetworkAPI.swift
//  simple-news
//
//  Created by Aleksandr Ivashchenko on 4/22/16.
//  Copyright © 2016 Aleksandr Ivashchenko. All rights reserved.
//

import Foundation
import UIKit
import CoreData

let SNAppleNewsRssURL = "https://developer.apple.com/news/rss/news.rss"

///Delegate for notifiying app about results of web-service(Apple News RSS) requests
protocol SNDataManagerDelegate: class {
    /**
     Called on successful data download from web-service
     */
    func dataDidEndDownload()
    /**
     Called on failed data download from web-service.
     
     - Parameter error: Localised description of error.
     */
    func dataDownloadDidFailedWithError(error: String)
}

///Class for data handling(performing requests and saving new data in local database)
class SNDataManager: NSObject {
    
    ///Data task for performing and cancelling requests
    private var dataTask: NSURLSessionDataTask? = nil
    
    ///The parser for data
    private let parser = SNXMLParser()
    
    ///Delegate for notifiying about results of requests
    weak var delegate: SNDataManagerDelegate?
    
    ///Manager for saving new data in local database
    var localDatabaseManager = SNLocalDatabaseManager()
    
    ///Context for defining local database's context
    var managedObjectContext: NSManagedObjectContext! {
        didSet {
            localDatabaseManager.managedObjectContext = managedObjectContext
        }
    }
    
    ///Perform request for getting new data from web-service
    func getData() {
        performAPIRequest()
    }
    
    ///Perform Apple News RSS request
    private func performAPIRequest() {
        dataTask?.cancel()
        
        let url = NSURL(string: SNAppleNewsRssURL)!
        parser.delegate = self
        
        if Reachability.isConnectedToNetwork() {
            parser.parseDataFromURL(url)
        } else {
            self.delegate!.dataDownloadDidFailedWithError("Network Error. Your Internet connection failed during the download. Please try again.")
        }
    }
}

///Implementing delegate methods

///Parser Delegate extension for Data Manager class
extension SNDataManager: SNXMLParserDelegate {
    
    func parsingDidEndWithData(data: [Dictionary<String, String>]) {
        localDatabaseManager.saveData(data) { errorString in
            if let errorString = errorString {
                self.delegate!.dataDownloadDidFailedWithError(errorString)
            } else {
                self.delegate!.dataDidEndDownload()
            }
        }
    }
    
    func parsingDidEndWithError(error: String) {
        delegate!.dataDownloadDidFailedWithError("Error while parsing data.")
    }
}

    