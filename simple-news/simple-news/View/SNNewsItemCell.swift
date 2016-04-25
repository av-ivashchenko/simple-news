//
//  SNNewsItemCell.swift
//  simple-news
//
//  Created by Aleksandr Ivashchenko on 4/22/16.
//  Copyright © 2016 Aleksandr Ivashchenko. All rights reserved.
//

import UIKit

class SNNewsItemCell: UITableViewCell {

    ///Label with name of news item
    @IBOutlet weak var nameLabel: UILabel!
    
    ///Label with description of news item
    @IBOutlet weak var detailLabel: UILabel!
    
    ///Label with date of news item
    @IBOutlet weak var dateLabel: UILabel!
 
    /**
     Configure cell with certain news item
     
     - Parameter newsItem: News item object
     
     */
    func configureForNewsItem(newsItem: SNNewsItem) {
        nameLabel.text = newsItem.title
        detailLabel.text = newsItem.itemDescription
        
        let formatter = NSDateFormatter()
        formatter.timeStyle = .LongStyle
        formatter.dateStyle = .LongStyle
        
        dateLabel.text = formatter.stringFromDate(newsItem.pubDate)
    }
}
