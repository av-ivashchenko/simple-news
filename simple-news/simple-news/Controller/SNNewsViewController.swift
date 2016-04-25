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
    var managedObjectContext: NSManagedObjectContext!
    @IBOutlet weak var refreshBarButtonItem: UIBarButtonItem!
    
    private let dataManager = SNDataManager()
    private var isLoading = false
    
    private lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest()
        
        let entity = NSEntityDescription.entityForName(kNewsItemEntity, inManagedObjectContext: self.managedObjectContext)
        fetchRequest.entity = entity
        let sortDescriptor = NSSortDescriptor(key: kPubDate, ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.fetchBatchSize = 20
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: self.managedObjectContext,
                                                                  sectionNameKeyPath: kPubDate,
                                                                  cacheName: kNewsItemEntity)
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
        if segue.identifier == kShowItemDetail {
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
        isLoading = true
        updateUI()
        performRequest()
    }
    
    func updateUI() {
        dispatch_async(dispatch_get_main_queue(), {
            self.refreshBarButtonItem.enabled = self.isLoading ? false : true
            UIApplication.sharedApplication().networkActivityIndicatorVisible = self.isLoading ? true : false
        })
    }
    
    // MARK: - Data handling
    
    func performRequest() {
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
        
        let sectionsCount = fetchedResultsController.sections!.count
        
        if sectionsCount == 0 {
            let noDataLabel = UILabel(frame: tableView.bounds)
            noDataLabel.numberOfLines = 0
            noDataLabel.text = "No data available. Press the refresh button for retrieving apple developer news"
            noDataLabel.textColor = UIColor(red: 7/255.0, green: 193/255.0, blue: 212/255.0, alpha: 1.0)
            noDataLabel.textAlignment = NSTextAlignment.Center
            tableView.backgroundView = noDataLabel
        } else {
            tableView.backgroundView = nil
        }
        
        return sectionsCount
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kNewsItemCell, forIndexPath: indexPath) as! SNNewsItemCell
        
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
        isLoading = false
        updateUI()
    }
    
    func dataDownloadDidFailedWithError(error: String) {
        let alert = UIAlertController(title: "", message: error, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        
        dispatch_async(dispatch_get_main_queue(), {
            self.presentViewController(alert, animated: true, completion: nil)
            self.isLoading = false
            self.updateUI()
        })
    }
}

extension SNNewsViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController,
                    didChangeObject anObject: AnyObject,
                                    atIndexPath indexPath: NSIndexPath?,
                                                forChangeType type: NSFetchedResultsChangeType,
                                                              newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        case .Update:
            if let cell = tableView.cellForRowAtIndexPath(indexPath!) as? SNNewsItemCell {
                let newsItem = fetchedResultsController.objectAtIndexPath(indexPath!) as! SNNewsItem
                cell.configureForNewsItem(newsItem)
            }
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
        case .Delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
        case .Update:
            print("*** Update section")
        case .Move:
            print("*** Move section")
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }

}
