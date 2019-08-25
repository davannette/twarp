//
//  Favourites.swift
//  Twarp
//
//  Created by David Shaw on 27/5/17.
//  Copyright © 2017 David Shaw. All rights reserved.
//

import Foundation

class Favourites {
    
    // create singleton
    static let shared = Favourites()
    
    // favourites array
    private var favourites: [Favourite] = [Favourite]()
    
    // number saved
    var count: Int {
        get {
            return self.favourites.count
        }
    }
    
    // private init to prevent instantiation outside class
    private init() {
        loadFromDefaults()
    }
    
    private func loadFromDefaults() {
        // load from UserDefaults
        let defaults = UserDefaults.standard
        if let favourites = defaults.object(forKey: "Favourites") as? [[String: Any]] {
            for fav in favourites {
                self.favourites.append(Favourite(dict: fav))
            }
        }
    }
    
    private func save() {
        // save to UserDefaults
        UserDefaults.standard.set(favourites.map {fav in fav.favDict}, forKey: "Favourites")
    }

    func favourite(at index: Int) -> Favourite {
        // get favourite at index
        return self.favourites[index]
    }
    
    func remove(at index: Int) {
        // remove favourite at index
        self.favourites.remove(at: index)
        save()
    }
    
    func add(_ fav: Favourite) {
        // add a new favourite
        self.favourites.append(fav)
        save()
    }
}

class Favourite {
    
    // properties
    var HashTag: String
    var StartTime: Date
    var Day: String {
        get {
            let days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
            let calendar = Calendar.current
            let components = calendar.dateComponents([.weekday], from: StartTime)
            if let day = components.weekday {
                return days[day]
            }
            return ""
        }
    }
    var Time: String {
        get {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour, .minute], from: StartTime)
            if let hour = components.hour,
            let minute = components.minute {
                return String(format: "%d:%02d", hour, minute)
            }
            return ""
        }
    }
    
    init(hashTag: String, startTime: Date) {
        // create from components
        HashTag = hashTag
        StartTime = startTime
    }
    
    init(dict: [String: Any]) {
        // create from dictionary
        HashTag = dict["HashTag"] as! String
        StartTime = dict["StartTime"] as! Date
    }
    
    var favDict: [String: Any] {
        // generate dictionary for saving to UserDefaults
        get {
            return [
                "HashTag": HashTag,
                "StartTime": StartTime
            ]
        }
    }
    
}
