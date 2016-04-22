//
//  SNLocalDatabaseManager.swift
//  simple-news
//
//  Created by Aleksandr Ivashchenko on 4/22/16.
//  Copyright © 2016 Aleksandr Ivashchenko. All rights reserved.
//

import Foundation
import CoreData

typealias SaveComplete = (Bool) -> Void

class SNLocalDatabaseManager {
    
    var managedObjectContext: NSManagedObjectContext!
    
    func saveData(data: [Dictionary<String, String>], completion: SaveComplete) {
        for dict in data {
            let newsItem = NSEntityDescription.insertNewObjectForEntityForName("SNNewsItem", inManagedObjectContext: managedObjectContext) as! SNNewsItem
            
            if let photoID = dict["photoID"] {
                let f = NSNumberFormatter()
                f.numberStyle = .DecimalStyle;
                newsItem.photoID = f.numberFromString(photoID)
            } else {
                newsItem.photoID = nil
            }
            newsItem.title = dict["title"]!
            newsItem.itemDescription = dict["description"]!
            newsItem.link = dict["link"]!
            newsItem.pubDate = NSDate.dateFromString(dict["pubDate"]!)
            
            do {
                try managedObjectContext.save()
            } catch {
                fatalCoreDataError(error)
            }
        }
    }
}