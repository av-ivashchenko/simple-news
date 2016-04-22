//
//  SNNewsItemCell.swift
//  simple-news
//
//  Created by Aleksandr Ivashchenko on 4/22/16.
//  Copyright © 2016 Aleksandr Ivashchenko. All rights reserved.
//

import UIKit

class SNNewsItemCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
 
    func configureForNewsItem(newsItem: SNNewsItem) {
        nameLabel.text = newsItem.title
        detailLabel.text = newsItem.itemDescription
        
        let formatter = NSDateFormatter()
        formatter.timeStyle = .LongStyle
        formatter.dateStyle = .LongStyle
        
        dateLabel.text = formatter.stringFromDate(newsItem.pubDate)
    }
}
