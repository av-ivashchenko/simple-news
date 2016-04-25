//
//  SNXMLParser.swift
//  simple-news
//
//  Created by Aleksandr Ivashchenko on 4/22/16.
//  Copyright © 2016 Aleksandr Ivashchenko. All rights reserved.
//

import Foundation
import UIKit

///Delegate for notifiying about successful or failed parsing XML documents
protocol SNXMLParserDelegate: class {
    
    /**
     Called when XML document parsing completed with success
     
     - Parameter data: The array of news items of type Dictionary<String, String>
     with keys: "title", "link", "pubDate", "description"
     */
    func parsingDidEndWithData(data: [Dictionary<String, String>])
    
    /**
     Called when XML document parsing ended with error
     
     - Parameter error: Localised error string
     */
    func parsingDidEndWithError(error: String)
}

///Class for parsing functions
class SNXMLParser: NSObject, NSXMLParserDelegate {
    
    ///The array of parsed news item data
    private var parsedData = [Dictionary<String, String>]()
    
    ///Temporary array for current found characters in XML document element
    private var currentDataDictionary = [ String: String ]()
    
    ///Current inspected XML element
    private var currentElement = ""
    
    ///Found characters in current XML element
    private var foundCharacters = ""
    
    ///Bool value for processing news item in XML document
    private var itemFound = false
    
    ///Delegate for notifiyng about parsing processing
    weak var delegate: SNXMLParserDelegate?
    
    /**
     Parse data from url
     
     - Parameter url: URL for parsing
    */
    func parseDataFromURL(url: NSURL) {
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        dispatch_async(queue, {
            let parser = NSXMLParser(contentsOfURL: url)
            if let parser = parser {
                parser.delegate = self
                parser.parse()
            }
        })
    }
    
    // MARK: - XMLParser delegate

    ///Implementing XML Parser delegate methods
    
    func parser(parser: NSXMLParser,
                didStartElement elementName: String,
                                namespaceURI: String?,
                                qualifiedName qName: String?,
                                              attributes attributeDict: [String : String]) {
        
        if itemFound {
            currentElement = elementName
        }
        
        if elementName == kItem {
            itemFound = true
            currentDataDictionary = [ String: String ]()
        }
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        if itemFound && string != "\n" {
            switch currentElement {
            case kTitle, kLink, kPubDate, kDescription:
                foundCharacters += string
            default:
                break
            }
        }
    }
    
    func parser(parser: NSXMLParser,
                didEndElement elementName: String,
                              namespaceURI: String?,
                              qualifiedName qName: String?) {
        if itemFound {
            switch currentElement {
            case kTitle, kLink, kPubDate, kDescription:
                currentDataDictionary[currentElement] = foundCharacters
                foundCharacters = ""
                
            default:
                break
                
            }
            if elementName == kItem {
                parsedData.append(currentDataDictionary)
                itemFound = false
            }
        }
        
    }
    
    func parserDidEndDocument(parser: NSXMLParser) {
        delegate?.parsingDidEndWithData(parsedData)
    }

}