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

protocol SNDataManagerDelegate: class {
    func dataDidEndDownload()
    func dataDownloadDidFailedWithError(error: NSString)
}

class SNDataManager: NSObject {
    
    enum State {
        case NotPerformedYet
        case Loading
        case NoResults
        case Results([SNNewsItem])
    }
    
    private(set) var state: State = .NotPerformedYet
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
        
        state = .Loading
        
        let url = NSURL(string: "https://developer.apple.com/news/rss/news.rss")!
        parser.delegate = self
        parser.parseDataFromURL(url)
    }
}

extension SNDataManager: SNXMLParserDelegate {
    
    func parsingDidEndWithData(data: [Dictionary<String, String>]) {
        localDatabaseManager.saveData(data) { success in
            if success {
                self.delegate!.dataDidEndDownload()
            } else {
                self.delegate!.dataDownloadDidFailedWithError("Error while saving data")
            }
        }
    }
    
    func parsingDidEndWithError(error: String) {
        print("*** Parsing Error: \(error).")
    }
}

    