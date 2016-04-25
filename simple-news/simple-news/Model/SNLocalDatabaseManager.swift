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

class SNLocalDatabaseManager {
    
    var managedObjectContext: NSManagedObjectContext!
    
    func saveData(data: [Dictionary<String, String>], completion: SaveComplete) {
        
        let currNewsItem = retrieveItemWithMaxPubDate()
        
        for dict in data {
            let itemDate = NSDate.dateFromString(dict[kPubDate]!)
            
            if let currNewsItem = currNewsItem where itemDate.compare(currNewsItem.pubDate) == .OrderedDescending {
                print("*** Just got fresh news item!")
                saveNewsItemDict(dict, pubDate: itemDate, completion: completion)
            } else if currNewsItem == nil {
                print("*** Empty local database")
                saveNewsItemDict(dict, pubDate: itemDate, completion: completion)
            } else {
                completion("Your news are up-to-date.")
                break
            }
        }
        completion(nil)
    }
    
    func saveNewsItemDict(dict: Dictionary<String, String>, pubDate: NSDate, completion: SaveComplete) {
        let newsItem = NSEntityDescription.insertNewObjectForEntityForName(kNewsItemEntity, inManagedObjectContext: managedObjectContext) as! SNNewsItem

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
    
    func retrieveItemWithMaxPubDate() -> SNNewsItem? {
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
            print("*** Error: \(error).")
            return nil
        }
    }
}