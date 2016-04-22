//
//  SNXMLParser.swift
//  simple-news
//
//  Created by Aleksandr Ivashchenko on 4/22/16.
//  Copyright © 2016 Aleksandr Ivashchenko. All rights reserved.
//

import Foundation
import UIKit

protocol SNXMLParserDelegate: class {
    func parsingDidEndWithData(data: [Dictionary<String, String>])
    func parsingDidEndWithError(error: String)
    
}

class SNXMLParser: NSObject, NSXMLParserDelegate {
    
    var parsedData = [Dictionary<String, String>]()
    var currentDataDictionary = [ String: String ]()
    var currentElement = ""
    var foundCharacters = ""
    var itemFound = false
    weak var delegate: SNXMLParserDelegate?
    
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
    
    func parserDidStartDocument(parser: NSXMLParser) {
        
    }
    
    func parser(parser: NSXMLParser,
                didStartElement elementName: String,
                                namespaceURI: String?,
                                qualifiedName qName: String?,
                                              attributes attributeDict: [String : String]) {
        
        if itemFound {
            currentElement = elementName
        }
        
        if elementName == "item" {
            itemFound = true
            currentDataDictionary = [ String: String ]()
        }
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        if itemFound && string != "\n" {
            switch currentElement {
            case "title", "link", "pubDate", "description":
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
            case "title", "link", "pubDate", "description":
                currentDataDictionary[currentElement] = foundCharacters
                foundCharacters = ""
                
            default:
                break
                
            }
            if elementName == "item" {
                parsedData.append(currentDataDictionary)
                itemFound = false
            }
        }
        
    }
    
    func parserDidEndDocument(parser: NSXMLParser) {
        delegate?.parsingDidEndWithData(parsedData)
    }

}