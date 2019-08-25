//
//  Settings.swift
//  Twarp
//
//  Created by David Shaw on 27/5/17.
//  Copyright © 2017 David Shaw. All rights reserved.
//

import Foundation

class Settings {
    
    // create singleton
    static let shared = Settings()
    
    // defaults if settings not set
    private let defShortSkip: Int = 30
    private let defLongSkip: Int = 300
    
    // user settings
    var shortSkip: Int
    var longSkip: Int
    var autoRefresh: Int
    var time24hour: Bool
    
    private init() {
        // read from UserDefaults
        let defaults = UserDefaults.standard
        shortSkip = defaults.integer(forKey: "shortSkip")
        if shortSkip == 0 {
            shortSkip = self.defShortSkip
        }
        longSkip = defaults.integer(forKey: "longSkip")
        if longSkip == 0 {
            longSkip = self.defLongSkip
        }
        autoRefresh = defaults.integer(forKey: "autoRefresh")
        time24hour = defaults.bool(forKey: "time24hour")
    }
    
    func save() {
        // save to UserDefaults
        let defaults = UserDefaults.standard
        defaults.set(shortSkip, forKey: "shortSkip")
        defaults.set(longSkip, forKey: "longSkip")
        defaults.set(autoRefresh, forKey: "autoRefresh")
        defaults.set(time24hour, forKey: "time24hour")
    }

}
