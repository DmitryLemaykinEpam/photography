//
//  GPXReader.swift
//  PhotographyStartup
//
//  Created by Dmitry Lemaykin on 1/21/19.
//  Copyright © 2019 Dmitry Lemaykin. All rights reserved.
//

import Foundation
import MapKit

class GPXParser: NSObject, XMLParserDelegate
{
    let dateFormatter: DateFormatter
    
    override init()
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        self.dateFormatter = dateFormatter
        
        super.init()
    }
    
    public var points = [GPXPoint]()
    
    //Create a polygon for each string there is in fileNames
    func parse(fileName: String) -> Bool
    {
        guard let fileURL = Bundle.main.url(forResource: fileName, withExtension: "gpx") else {
            return false
        }
        
        points = [GPXPoint]()

        //Setup the parser and initialize it with the filepath's data
        let data: Data
        do {
            data = try Data(contentsOf: fileURL)
        } catch {
            print("error")
            return false
        }
        
        let parser = XMLParser(data: data)
        parser.delegate = self
        
        let success = parser.parse()
        
        if !success {
            print ("ERROR: Failed to parse the following file: \(fileURL).gpx")
        }
        
        return success
    }
    
    var gpxPoint = GPXPoint()
    var currentElement: CurrentElement = .wpt
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String])
    {
        if elementName == "trkpt" || elementName == "wpt"
        {
            currentElement = .wpt
            self.gpxPoint = GPXPoint()
            
            let lat = CLLocationDegrees(attributeDict["lat"]!)!
            let lon = CLLocationDegrees(attributeDict["lon"]!)!
            
            self.gpxPoint.lat = lat
            self.gpxPoint.lon = lon
            
            points.append(self.gpxPoint)
        } else if elementName == "ele"
        {
            currentElement = .ele
        } else if elementName == "time" {
            currentElement = .time
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String)
    {
        let trimmedString = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        guard trimmedString.count > 0 else {
            return
        }
        
        switch currentElement {
        case .wpt:
            //
            break
        case .ele:
            guard let ele = Double(string) else {
                return
            }
            gpxPoint.ele = ele
        case .time:
            guard let date = dateFormatter.date(from: string) else {
                return
            }
            gpxPoint.time = date
        }
    }
}

enum CurrentElement: String
{
    case wpt = "wpt"
    case ele = "ele"
    case time = "time"
}

class GPXPoint
{
    var lat: CLLocationDegrees!
    var lon: CLLocationDegrees!
    var ele: Double!
    var time: Date!
    
    init() {
        
    }
}
