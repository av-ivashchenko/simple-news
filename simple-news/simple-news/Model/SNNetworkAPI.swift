//
//  SNNetworkAPI.swift
//  simple-news
//
//  Created by Aleksandr Ivashchenko on 4/22/16.
//  Copyright © 2016 Aleksandr Ivashchenko. All rights reserved.
//

import Foundation

typealias RequestComplete = (Bool) -> Void

class SNNetworkAPI: NSObject {
    
    enum State {
        case NotPerformedYet
        case Loading
        case NoResults
        case Results([SNNewsItem])
    }
    
    private(set) var state: State = .NotPerformedYet
    private var dataTask: NSURLSessionDataTask? = nil
    
    func performAPIRequest(completion: RequestComplete) {
        
    }
    
}