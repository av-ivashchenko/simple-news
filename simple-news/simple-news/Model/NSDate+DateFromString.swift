//
//  NSDate+DateFromString.swift
//  simple-news
//
//  Created by Aleksandr Ivashchenko on 4/22/16.
//  Copyright © 2016 Aleksandr Ivashchenko. All rights reserved.
//

import Foundation

extension NSDate {
    class func dateFromString(string: String) -> NSDate {
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.dateFormat = "EEE,dd MMM yyyy HH:mm:ss zzz"
        return formatter.dateFromString(string)!
    }
}