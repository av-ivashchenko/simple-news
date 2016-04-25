//
//  SNNewsItem+CoreDataProperties.swift
//  simple-news
//
//  Created by Aleksandr Ivashchenko on 4/22/16.
//  Copyright © 2016 Aleksandr Ivashchenko. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension SNNewsItem {
    
    ///Title of news item
    @NSManaged var title: String
    
    ///Link to the website with full information
    @NSManaged var link: String
    
    ///Publication date of the news item
    @NSManaged var pubDate: NSDate
    
    ///Full description of news item
    @NSManaged var itemDescription: String

}
