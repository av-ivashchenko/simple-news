//
//  NSDate+DateFromString.swift
//  simple-news
//
//  Created by Aleksandr Ivashchenko on 4/22/16.
//  Copyright © 2016 Aleksandr Ivashchenko. All rights reserved.
//

import Foundation

///Extension for handling specific date format that comes from Apple News RSS
extension NSDate {
    
    /**
     Class function for getting date object from date string with specific format
     
     - Parameter string: Date string in format "EEE,dd MMM yyyy HH:mm:ss zzz"
     
     - Returns: Date object
     
     */
    class func dateFromString(string: String) -> NSDate {
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.dateFormat = "EEE,dd MMM yyyy HH:mm:ss zzz"
        return formatter.dateFromString(string)!
    }
}