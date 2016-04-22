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

    @NSManaged var title: String
    @NSManaged var link: String
    @NSManaged var pubDate: NSDate
    @NSManaged var itemDescription: String
    @NSManaged var photoID: NSNumber?

}
