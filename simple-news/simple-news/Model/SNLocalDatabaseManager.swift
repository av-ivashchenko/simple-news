//
//  SNLocalDatabaseManager.swift
//  simple-news
//
//  Created by Aleksandr Ivashchenko on 4/22/16.
//  Copyright © 2016 Aleksandr Ivashchenko. All rights reserved.
//

import Foundation
import CoreData

typealias SaveComplete = (String?) -> Void

///Class for processing data in local database
class SNLocalDatabaseManager {
    
    ///Context for saving data
    var managedObjectContext: NSManagedObjectContext!
    
    /**
     Save data in local database
     
     - Parameters: 
        - data: Array of news items of type Dictionary<String, String>
        - completion: Block for notifiyng about successful or failed saving in local database
     */
    func saveData(data: [Dictionary<String, String>], completion: SaveComplete) {
        
        let currNewsItem = retrieveItemWithMaxPubDate()
        
        for dict in data {
            let itemDate = NSDate.dateFromString(dict[kPubDate]!)
            
            if let currNewsItem = currNewsItem where itemDate.compare(currNewsItem.pubDate) == .OrderedDescending {
                
                ///Just got fresh news item
                saveNewsItemDict(dict, pubDate: itemDate, completion: completion)
            } else if currNewsItem == nil {
                
                ///Empty local database
                saveNewsItemDict(dict, pubDate: itemDate, completion: completion)
            } else {
                
                ///News in local database are up-to-date
                completion("Your news are up-to-date.")
                break
            }
        }
        completion(nil)
    }
    
    /**
     Save news item to the local database
     
     - Parameters: 
        - dict: News item info
        - pubDate: News item's publication date
        - completion: Block for notifiying about results of saving data
     */
     private func saveNewsItemDict(dict: Dictionary<String, String>, pubDate: NSDate, completion: SaveComplete) {
        
        ///Insert new item to local database
        let newsItem = NSEntityDescription.insertNewObjectForEntityForName(kNewsItemEntity, inManagedObjectContext: managedObjectContext) as! SNNewsItem

        ///Initialiase all properties
        newsItem.title = dict[kTitle]!
        newsItem.itemDescription = dict[kDescription]!
        newsItem.link = dict[kLink]!
        newsItem.pubDate = pubDate
        
        do {
            try managedObjectContext.save()
        } catch {
            fatalCoreDataError(error)
            completion("Error while saving data in local database.")
            return
        }
    }
    
    /**
     Fetch fresh news item from local database
     
     - Returns: Fresh news item
     */
    private func retrieveItemWithMaxPubDate() -> SNNewsItem? {
        let fetchRequest = NSFetchRequest()
        
        let entity = NSEntityDescription.entityForName(kNewsItemEntity, inManagedObjectContext: self.managedObjectContext)
        fetchRequest.entity = entity
        fetchRequest.fetchLimit = 1
        let sortDescriptor = NSSortDescriptor(key: kPubDate, ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let newsItem = try managedObjectContext.executeFetchRequest(fetchRequest).first as? SNNewsItem
            return newsItem
        } catch {
            fatalCoreDataError(error)
            return nil
        }
    }
}