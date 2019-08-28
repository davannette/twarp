//
//  TwitterInterface.swift
//  Twarp
//
//  Created by David Shaw on 16/5/17.
//  Copyright © 2017 David Shaw. All rights reserved.
//

import Foundation
import TwitterKit

protocol TwitterFeedDelegate {
    
    // update the feed in the delegate view
    func updateFeed(_ id: Int64)
    
}

struct Tweet: Codable {
    let createdAt: Date
    let id: Int64
}

struct Statuses: Codable {
    let statuses: [Tweet]
}

class TwitterInterface {
    
    // delegate for feed updates
    var delegate: TwitterFeedDelegate?
    
    // vars for calculating tweet rate
    var upperBound: Int64 = 0
    var upperBoundDate: Date? = nil
    var lowerBound: Int64 = 0
    var lowerBoundDate: Date? = nil
    
    // tweet id rate per second
    var tweetRate: Int64 = 0
    
    // start of twitter feed
    var startDateTime : Date
    var startID : Int64 = 0
    
    // weak var viewContext: TwitterViewController! = nil
    
    init(start: Date) {
        startDateTime = start
        findBoundaryIDs(start)
    }
    
    func findBoundaryIDs(_ start: Date) {
        // calculate boundary dates - today and yesterday (UTC)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        let upper = dateFormatter.string(from: start)
        callAPI(upper, upper: true)
        
        var components = DateComponents()
        components.day = -1
        let lower = dateFormatter.string(from: Calendar.current.date(byAdding: components, to: start)!)
        callAPI(lower, upper: false)
    }
    
    func callAPI(_ datestr: String, upper: Bool) {
        let client = TWTRAPIClient()
        // search API endpoint
        let statusesShowEndpoint = "https://api.twitter.com/1.1/search/tweets.json"
        // search for character 'a' to capture closest tweet to date time
        let params1 = ["q": "a until:\(datestr)", "count": "1"]
        var clientError : NSError?
        let request1 = client.urlRequest(withMethod: "GET", urlString: statusesShowEndpoint, parameters: params1, error: &clientError)
        client.sendTwitterRequest(request1) { [weak self] (response, data, connectionError) -> Void in
            if (connectionError == nil) {
                var jsonError : NSError?
                let parsedObject : Statuses?
                do {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "EEE MMM dd HH:mm:ss ZZZ yyyy"
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    decoder.dateDecodingStrategy = .formatted(formatter)
                    parsedObject = try decoder.decode(Statuses.self, from: data!) // try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                } catch let error as NSError {
                    jsonError = error
                    parsedObject = nil
                } catch {
                    fatalError()
                }
                // parse returned json object to extract tweet id and date
                if let tweet = parsedObject?.statuses[0] {
                    if upper {
                        self?.upperBound = tweet.id
                        self?.upperBoundDate = tweet.createdAt
                    } else {
                        self?.lowerBound = tweet.id
                        self?.lowerBoundDate = tweet.createdAt
                    }
                    self?.checkDone()
                } else if jsonError != nil {
                    print("Error: \(jsonError?.localizedDescription ?? "unknown")")
                }
            }
            else {
                print("Error: \(connectionError?.localizedDescription ?? "unknown")")
            }
        }
    }
    
    func refreshFeed(_ time: Date) {
        // use tweet rate and offset to predict closest tweet id
        let diff = time.timeIntervalSince(startDateTime)
        let id = startID + tweetRate * Int64(diff)
        // update delegate view
        delegate?.updateFeed(id)
    }
    
    func checkDone() {
        // run by both async tasks
        if lowerBound == 0 || upperBound == 0 {
            // first one finished, wait for second call
            return
        }
        else
        {
            // both tasks finished, continue
            let timeDiff = upperBoundDate?.timeIntervalSince(lowerBoundDate!)
            let tweetDiff = upperBound - lowerBound
            
            // calculate rate per second from start to end of day
            tweetRate = tweetDiff / Int64(timeDiff!)
            
            // calculate seconds into UTC day
            let dayPos = startDateTime.timeIntervalSince(lowerBoundDate!)
            
            // add to id value based on tweet rate and elapsed seconds
            startID = lowerBound + tweetRate * Int64(dayPos)
            
            // debug values
            print("Lower: \(lowerBound)")
            print("Start: \(startID)")
            print("Upper: \(upperBound)")
            
            // set starting position in delegate
            delegate?.updateFeed(startID)
        }
    }
    
}
