//
//  TwitterViewController.swift
//  Twarp
//
//  Created by David Shaw on 16/5/17.
//  Copyright © 2017 David Shaw. All rights reserved.
//

import Foundation
import UIKit
import TwitterKit
import AwesomeEnum

protocol UpdateTimeAndDay {
    func UpdateUI(fromDate: Date)
}

class TwitterViewController: TWTRTimelineViewController {
    
    var twInterface: TwitterInterface?
    var twTimer: TimerController?
    
    var startDate = Date()
    var lastRefresh: Date
    
    var hashTag = ""

    var delegate: UpdateTimeAndDay?
    
    // pvr icons
    let iconLeft = Awesome.Solid.caretLeft.asImage(size: 50)
    let iconRight = Awesome.Solid.caretRight.asImage(size: 50)
    let iconPlay = Awesome.Solid.play.asImage(size: 30)
    let iconPause = Awesome.Solid.pause.asImage(size: 30)
    let iconSkipBack = Awesome.Solid.backward.asImage(size: 30)
    let iconSkipForward = Awesome.Solid.forward.asImage(size: 30)
    
    required init?(coder aDecoder: NSCoder) {
        
        lastRefresh = startDate

        super.init(coder: aDecoder)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create new twitter and timer handlers
        twInterface = TwitterInterface(start: startDate)
        twTimer = TimerController(time: startDate)
        
        // set delegates
        twInterface?.delegate = self
        twTimer?.delegate = self
        
        // set monospace font for title to keep clock updates smooth
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.monospacedDigitSystemFont(ofSize: 18, weight: UIFont.Weight.bold)]
        
        // set clock content:
        timerUpdate()
        
        // setup 'PVR' toolbar buttons
        var items = Array<UIBarButtonItem>()
        let buttonContent = [iconSkipBack, iconLeft, iconPause, iconRight, iconSkipForward]
        
        items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
        for icon in buttonContent {
            let button = UIBarButtonItem(image: icon, style:.plain, target: self, action: #selector(doTimerAction(_:)))
            button.width = 50.0
            items.append(button)
        }
        items.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil))
        toolbarItems = items
        
        // enable pull refresh
        refreshControl?.addTarget(self, action: #selector(doRefresh(_:)), for: UIControl.Event.valueChanged)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isMovingFromParent {
            // moving back to home screen, stop timer updates
            twTimer?.stop()
            if let date = twTimer?.getTime() {
                delegate?.UpdateUI(fromDate: date)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // show navbar
        navigationController?.navigationBar.isHidden = false
    }
    
    func refreshFeed() {
        // get current feed time and refresh the feed
        if let time = twTimer?.getTime() {
            twInterface?.refreshFeed(time)
            lastRefresh = time
        }
    }
    
    @objc func doTimerAction(_ sender: UIBarButtonItem) -> () {
        switch sender.image! {
            // handle PVR buttons
            case iconSkipBack:
                twTimer?.skip(.long, dir: .back)
            case iconLeft:
                twTimer?.skip(.short, dir: .back)
            case iconRight:
                twTimer?.skip(.short, dir: .forward)
            case iconSkipForward:
                twTimer?.skip(.long, dir: .forward)
            case iconPlay, iconPause:
                if (twTimer?.togglePause() == true) {
                    sender.image = iconPlay
                } else {
                    sender.image = iconPause
                }
            default:
                break
        }
    }
    
    @objc func doRefresh(_ refreshControl: UIRefreshControl) {
        // activated by pull refresh
        refreshFeed()
    }
}

extension TwitterViewController: TwitterFeedDelegate {
    
    func updateFeed(_ tweetID: Int64) {
        // update timeline from passed id
        let client = TWTRAPIClient()
        let query = "#\(hashTag)&max_id:\(tweetID)"
        print(query)
        dataSource = TWTRSearchTimelineDataSource(searchQuery: query, apiClient: client)
    }
}

extension TwitterViewController: TimerDelegate {
    
    func timerUpdate() {
        // update feed time label
        let formatter = DateFormatter()
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
        formatter.dateFormat = Settings.shared.time24hour ? "EEE dd HH:mm:ss" : "EEE dd hh:mm:ssa"
        if let date = twTimer?.getTime() {
            title = formatter.string(from: date)
            // check for auto refresh
            let autoRefresh = Settings.shared.autoRefresh
            if autoRefresh > 0 {
                if abs(Int((date.timeIntervalSince(lastRefresh)))) > autoRefresh {
                    refreshFeed()
                }
            }
        }
    }
}
