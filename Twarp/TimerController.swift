//
//  TimerController.swift
//  Twarp
//
//  Created by David Shaw on 16/5/17.
//  Copyright © 2017 David Shaw. All rights reserved.
//

import Foundation

protocol TimerDelegate {
    
    // run each update cycle
    func timerUpdate()

}

class TimerController {
    
    // delegate for timer updates
    var delegate: TimerDelegate?
    
    var timer = Timer()

    enum Skip {
        case short
        case long
    }
    
    enum Direction {
        case back
        case forward
    }
    
    // tracking dates:
    var dateCreated: Date
    var origin: Date
    
    // skip/pause offset time
    var offset: Int = 0
    
    // pause functionality
    var paused = false
    var timePaused: Date? = nil
    
    init(time: Date) {
        dateCreated = Date()
        origin = time
        
        // start clock timer
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(0.2), repeats: true) { [weak self] _ in
            // update delegate
            self?.delegate?.timerUpdate()
        }
    }
    
    func getTime() -> Date {
        // calculate feed time, adjusted for offset
        var comps = DateComponents()
        if paused {
            let diff = timePaused?.timeIntervalSince(dateCreated)
            comps.second = Int(diff!)
        } else {
            comps.second = Int(dateCreated.timeIntervalSinceNow * -1)
        }
        comps.second = comps.second! + Int(offset)
        return Calendar.current.date(byAdding: comps, to: origin)!
    }
    
    func skip(_ skip: Skip, dir: Direction) {
        // adjust time for skip type
        var amt: Int
        let settings = Settings.shared
        switch skip {
            case Skip.short:
                amt = settings.shortSkip
            case Skip.long:
                amt = settings.longSkip
        }
        if dir == Direction.forward {
            offset += amt
            let time = getTime()
            if time > Date() {
                offset -= Int(time.timeIntervalSinceNow)
            }
        } else {
            offset -= amt
        }
    }
    
    func stop() {
        // stop timer
        timer.invalidate()
    }
    
    func togglePause() -> Bool {
        // pause timer
        paused = !paused
        if (paused) {
            // stop timer
            timer.invalidate()
            timePaused = Date()
        } else {
            // adjust time for length paused
            let diff = (timePaused?.timeIntervalSinceNow)! * -1
            offset -= Int(diff)
            // start new timer
            timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(0.2), repeats: true) { [weak self] _ in
                // update delegate
                self?.delegate?.timerUpdate()
            }
        }
        return paused
    }
    
}
