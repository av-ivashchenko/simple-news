//
//  SNNewsDetailViewController.swift
//  simple-news
//
//  Created by Aleksandr Ivashchenko on 4/22/16.
//  Copyright © 2016 Aleksandr Ivashchenko. All rights reserved.
//

import UIKit

///Class for showing detail information of news item
class SNNewsDetailViewController: UIViewController {

    ///Label with news item name
    @IBOutlet weak var nameLabel: UILabel!
    
    ///Label with publication date of news item
    @IBOutlet weak var dateLabel: UILabel!
    
    ///Text view for showing full description of news item
    @IBOutlet weak var itemDescription: UITextView!
    
    ///Image view with placeholder image
    @IBOutlet weak var newsImageView: UIImageView!
    
    ///News item object
    var newsItem: SNNewsItem?
    
    // MARK: - View life cycle
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.text = newsItem!.title
        itemDescription.text = newsItem!.itemDescription + "\n" + newsItem!.link
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = .LongStyle
        formatter.timeStyle = .LongStyle
        
        dateLabel.text = formatter.stringFromDate(newsItem!.pubDate)
    }
}

///Extension for implementing methods of Text View Delegate

extension SNNewsDetailViewController: UITextViewDelegate {
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        return true
    }
}
