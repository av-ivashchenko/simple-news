//
//  SNNewsViewController.swift
//  simple-news
//
//  Created by Aleksandr Ivashchenko on 4/22/16.
//  Copyright © 2016 Aleksandr Ivashchenko. All rights reserved.
//

import UIKit
import CoreData

class SNNewsViewController: UITableViewController {

    let dataManager = SNDataManager()
    
    var managedObjectContext: NSManagedObjectContext!
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest()
        
        let entity = NSEntityDescription.entityForName("SNNewsItem", inManagedObjectContext: self.managedObjectContext)
        fetchRequest.entity = entity
        let sortDescriptor = NSSortDescriptor(key: "pubDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.fetchBatchSize = 20
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: self.managedObjectContext,
                                                                  sectionNameKeyPath: "pubDate",
                                                                  cacheName: "NewsItems")
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    deinit {
        fetchedResultsController.delegate = nil
    }
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataManager.delegate = self
        dataManager.managedObjectContext = managedObjectContext
        
        performFetch()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowItemDetail" {
            let itemDetailController = segue.destinationViewController as! SNNewsDetailViewController
            
            if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell) {
                let newsItem = fetchedResultsController.objectAtIndexPath(indexPath) as! SNNewsItem
                itemDetailController.newsItem = newsItem
            }
        }
    }
    
    // MARK: - Other
    
    func performFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalCoreDataError(error)
        }
    }
    
    @IBAction func refreshButtonTapped(sender: AnyObject) {
        performRequest()
    }
    
    // MARK: - Data handling
    
    func performRequest() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        dataManager.getData()
    }
    
    func showNetworkError() {
        let alert = UIAlertController(
            title: NSLocalizedString("Whoops...", comment: "Error alert: title"),
            message: NSLocalizedString("There was an error reading from the Apple RSS. Please try again.", comment: "Error alert: message"),
            preferredStyle: .Alert)
        
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        
        presentViewController(alert, animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NewsItemCell", forIndexPath: indexPath) as! SNNewsItemCell
        
        let newsItem = fetchedResultsController.objectAtIndexPath(indexPath) as! SNNewsItem
        
        cell.configureForNewsItem(newsItem)
        
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 146
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = fetchedResultsController.sections![section].name
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZ"
        let date = formatter.dateFromString(sectionInfo)
        
        formatter.timeStyle = .NoStyle
        formatter.dateStyle = .MediumStyle
        
        return formatter.stringFromDate(date!)
    }
}

extension SNNewsViewController: SNDataManagerDelegate {
    func dataDidEndDownload() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    func dataDownloadDidFailedWithError(error: NSString) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
}

extension SNNewsViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        print("*** Controller will change content")
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController,
                    didChangeObject anObject: AnyObject,
                                    atIndexPath indexPath: NSIndexPath?,
                                                forChangeType type: NSFetchedResultsChangeType,
                                                              newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            print("*** Insert object")
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        case .Delete:
            print("*** Delete object")
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        case .Update:
            print("*** Update object")
            if let cell = tableView.cellForRowAtIndexPath(indexPath!) as? SNNewsItemCell {
                let newsItem = fetchedResultsController.objectAtIndexPath(indexPath!) as! SNNewsItem
                cell.configureForNewsItem(newsItem)
            }
        case .Move:
            print("*** Move object")
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            print("*** Insert section")
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
        case .Delete:
            print("*** Delete section")
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
        case .Update:
            print("*** Update section")
        case .Move:
            print("*** Move section")
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        print("*** Did change content")
        tableView.endUpdates()
    }

}
