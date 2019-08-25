//
//  SettingsViewController.swift
//  Twarp
//
//  Created by David Shaw on 24/5/17.
//  Copyright © 2017 David Shaw. All rights reserved.
//

import UIKit
// import AwesomeEnum

class SettingsViewController: UIViewController {

    // input field handles
    @IBOutlet weak var lblShortSkip: UILabel!
    @IBOutlet weak var slShortSkip: UISlider!
    @IBOutlet weak var lblLongSkip: UILabel!
    @IBOutlet weak var slLongSkip: UISlider!
    
    @IBOutlet weak var swAutoRefresh: UISwitch!
    @IBOutlet weak var slAutoRefresh: UISlider!
    @IBOutlet weak var lblAutoRefresh: UILabel!
    @IBOutlet weak var lblAutoRefreshValue: UILabel!
    @IBOutlet weak var sw24hour: UISwitch!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadSettings()
        
        // set toolbar button icons
        // save menu button - disk icon
//        let attributes = [NSAttributedString.Key.font: UIFont.fontAwesome(ofSize: 18)]
        saveButton.title = "Save" // \(Awesome.Regular.save.asAttributedText(fontSize: 18)) Save"

        // cancel menu button - cross icon
//        cancelButton.setTitleTextAttributes(attributes, for: .normal)
        cancelButton.title = "Cancel" // \(Awesome.Regular.timesCircle.asAttributedText(fontSize: 18)) Cancel"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = false
        // self.tabBarController?.tabBar.isHidden = false
    }

    func loadSettings() {
        // set fields to values from UserSettings
        let settings = Settings.shared
        slShortSkip.value = Float(settings.shortSkip)
        lblShortSkip.text = "\(settings.shortSkip)"
        slLongSkip.value = Float(settings.longSkip)
        lblLongSkip.text = "\(settings.longSkip)"
        swAutoRefresh.setOn(settings.autoRefresh > 0, animated: false)
        enableDelay(enable: settings.autoRefresh > 0)
        lblAutoRefreshValue.text = settings.autoRefresh > 0 ? "\(settings.autoRefresh)" : "30"
        slAutoRefresh.value = settings.autoRefresh > 0 ? Float(settings.autoRefresh) : 30
        sw24hour.setOn(settings.time24hour, animated: false)
    }
    
    func saveSettings() {
        // save to UserDefaults
        let settings = Settings.shared
        settings.shortSkip = Int(slShortSkip.value)
        settings.longSkip = Int(slLongSkip.value)
        if swAutoRefresh.isOn {
            settings.autoRefresh = Int(slAutoRefresh.value)
        } else {
            settings.autoRefresh = 0
        }
        settings.time24hour = sw24hour.isOn
        settings.save()
    }
    
    func enableDelay(enable: Bool) {
        // enable/disable setting delay time
        swAutoRefresh.setOn(enable, animated: false)
        slAutoRefresh.isEnabled = enable
        lblAutoRefresh.textColor = enable ? UIColor.black : UIColor.gray
        lblAutoRefreshValue.textColor = enable ? UIColor.black : UIColor.gray
    }
    
    @IBAction func SwitchAutoRefresh(sender: UISwitch) {
        // toggle delay fields
        enableDelay(enable: sender.isOn)
    }
    
    @IBAction func SliderChanged(sender: UISlider) {
        // update delay value
        let value = Int(sender.value)
        if let id = sender.restorationIdentifier {
            switch id {
                case "ShortSkip":
                    lblShortSkip.text = "\(value)"
                    if value > Int(slLongSkip.value) - 30 {
                        slLongSkip.value = Float(value + 30)
                        lblLongSkip.text = "\(value + 30)"
                    }
                case "LongSkip":
                    lblLongSkip.text = "\(value)"
                    if value < Int(slShortSkip.value) + 30 {
                        slShortSkip.value = Float(value - 30)
                        lblShortSkip.text = "\(value - 30)"
                    }
                case "AutoRefresh":
                    lblAutoRefreshValue.text = "\(value)"
                default: break
            }
        }
    }

    
    @IBAction func Save(sender: UIBarButtonItem) {
        // save settings and return
        saveSettings()
        self.performSegue(withIdentifier: "unwindSegue", sender: self)
    }
}
