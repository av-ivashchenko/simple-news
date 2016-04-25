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

protocol SNDataManagerDelegate: class {
    func dataDidEndDownload()
    func dataDownloadDidFailedWithError(error: String)
}

class SNDataManager: NSObject {
    private var dataTask: NSURLSessionDataTask? = nil
    private let parser = SNXMLParser()
    
    weak var delegate: SNDataManagerDelegate?
    
    var managedObjectContext: NSManagedObjectContext! {
        didSet {
            localDatabaseManager.managedObjectContext = managedObjectContext
        }
    }
    var localDatabaseManager = SNLocalDatabaseManager()
    
    func getData() {
        performAPIRequest()
    }
    
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

    