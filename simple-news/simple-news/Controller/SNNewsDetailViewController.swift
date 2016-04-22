//
//  SNNewsDetailViewController.swift
//  simple-news
//
//  Created by Aleksandr Ivashchenko on 4/22/16.
//  Copyright © 2016 Aleksandr Ivashchenko. All rights reserved.
//

import UIKit

class SNNewsDetailViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var itemDescription: UITextView!
    @IBOutlet weak var newsImageView: UIImageView!
    
    var newsItem: SNNewsItem? {
        didSet {
            
        }
    }
    
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

extension SNNewsDetailViewController: UITextViewDelegate {
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        return true
    }
}
