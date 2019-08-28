//
//  FirstViewController.swift
//  Twarp
//
//  Created by David Shaw on 16/5/17.
//  Copyright © 2017 David Shaw. All rights reserved.
//

import UIKit
import AwesomeEnum

class TwarpViewController: UIViewController, UIPickerViewDataSource, UpdateTimeAndDay {
    
    func UpdateUI(fromDate: Date) {
        updateTime(fromDate: fromDate)
        setTime()
    }

    // handles to input fields
    @IBOutlet weak var hashTag: UITextField!
    @IBOutlet weak var dayPicker: UIPickerView!
    @IBOutlet weak var timeDisplay: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    
    // overall stack view
    @IBOutlet weak var layoutStack: UIStackView!
    
    // toolbar buttons
    @IBOutlet weak var favouritesButton: UIBarButtonItem!
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    
    // outlets for setting icons
    @IBOutlet weak var btnFavourite: UIButton!
    
    // day picker array
    var arrDays: [String] = []
    
    // favourite popup
    var addPrompt: UIAlertController = UIAlertController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set datasource for day picker
        dayPicker.dataSource = self
        dayPicker.delegate = self
        
        // create add favourite popup
        addPrompt.title = "Add favourite?"
        addPrompt.addAction(UIAlertAction(title: "Add", style: .default, handler: saveFavourite))
        addPrompt.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        addPrompt.message = "Are you sure you want to add this to your favourites?"
        
        // initialise interface
        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // hide navbar at topmost screen
        navigationController?.navigationBar.isHidden = true
        tabBarController?.tabBar.isHidden = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // hide keyboard
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }

    func initUI() {
        // day picker - today and last seven days
        arrDays = ["Today"]
        let cal = Calendar.current
        let now = Date()
        var date = cal.startOfDay(for: now)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        for _ in 1 ... 7 {
            date = cal.date(byAdding: .day, value: -1, to: date)!
            arrDays.append(dateFormatter.string(from: date))
        }

        // set time slider to current time
        let minutes = cal.component(.hour, from: now) * 60 + cal.component(.minute, from: now)
        timeSlider.value = Float(minutes)
        setTime()

        // save to favourites button - heart icon
//        btnFavourite.titleLabel?.font = UIFont.fontAwesome(ofSize: 30)
        let heartIcon = Awesome.Solid.heart.asImage(size: 30)
        btnFavourite.setImage(heartIcon, for: .normal) // .setTitle("F", for: .normal) // String.fontAwesomeIcon(name: .heartO), for: .normal)
        
        // favourites menu button - star icon
//        let attributes = [NSAttributedStringKey.font: UIFont.fontAwesome(ofSize: 18)]
//        favouritesButton.setTitleTextAttributes(attributes, for: .normal)
        favouritesButton.title = "Favourites" // \(String.fontAwesomeIcon(name: .star)) Favourites"
        
        // settings menu button - gear icon
//        settingsButton.setTitleTextAttributes(attributes, for: .normal)
        settingsButton.title = "Settings" // \(String.fontAwesomeIcon(name: .cog)) Settings"
        
        
    }
    
    func saveFavourite(alert: UIAlertAction!) {
        if let hashtag = hashTag.text {
            Favourites.shared.add(Favourite(hashTag: hashtag, startTime: getDate()))
            navigationController?.view.showToast("Added to favourites")
        }
    }
    
    @IBAction func btnAddFav(_ sender: Any) {
        present(addPrompt, animated: true, completion: nil)
    }
    
    @IBAction func timeSliderChanged(sender: UISlider) {
        // slider changed, update time displayed
        var value = Int(sender.value)
        let now = Date()
        if dayPicker.selectedRow(inComponent: 0) == 0 {
            // today, so limit time to current time
            let cal = Calendar.current
            let minutes = cal.component(.hour, from: now) * 60 + cal.component(.minute, from: now)
            if value > minutes {
                value = minutes
                sender.value = Float(minutes)
            }
        }
        setTime()
    }
    
    @IBAction func finePlus(sender: UIButton) {
        // adjust time forward 1 minute
        var value = Int(timeSlider.value) + 1
        if value > 1439 { value = 1439 }
        let now = Date()
        if dayPicker.selectedRow(inComponent: 0) == 0 {
            // today, so limit time to current time
            let cal = Calendar.current
            let minutes = cal.component(.hour, from: now) * 60 + cal.component(.minute, from: now)
            if value > minutes {
                value = minutes
            }
        }
        timeSlider.value = Float(value)
        setTime()
    }
    
    @IBAction func fineMinus(sender: UIButton) {
        // adjust time back 1 minute
        var time = Int(timeSlider.value) - 1
        if time < 0 { time = 0 }
        timeSlider.value = Float(time)
        setTime()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        let date = getDate()
        
        switch segue.identifier! {
            case "twarpSegue" :
                // pass paramters and open twitter feed
                let dest = segue.destination as! TwitterViewController
                dest.startDate = date
                dest.hashTag = hashTag.text!
                dest.delegate = self
                break
//            case "addFavouriteSegue" :
//                // pass feed parameters to add favourites controller
//                let dest = segue.destination as! AddFavouriteViewController
//                dest.time = date
//                dest.hashTag = hashTag.text!
//                break
            default :
                break
        }
    }
    
    @IBAction func cancelSegue(segue: UIStoryboardSegue) {
    }
    
    @IBAction func saveSettingsSegue(segue: UIStoryboardSegue) {
        // in case 24 hour time was changed
        setTime()
    }
    
    @IBAction func openFavourite(segue: UIStoryboardSegue) {
        let source = segue.source as! FavouritesViewController
        if let index = source.selectedIndex?.row {
            // set input fields from favourite
            let fav = Favourites.shared.favourite(at: index)
            hashTag.text = fav.HashTag
            let date = fav.StartTime
            updateTime(fromDate: date)
            setTime()
            navigationController?.view.showToast("Opened favourite")
        }
    }
    
    func updateTime(fromDate: Date) {
        let date = fromDate > Date() ? Date() : fromDate
        let dayFormatter = DateFormatter()
        let weekdayFormatter = DateFormatter()
        dayFormatter.dateFormat = "dd"
        weekdayFormatter.dateFormat = "EEEE"
        let day: String
        if dayFormatter.string(from: date) == dayFormatter.string(from: Date()) {
            day = "Today"
        } else {
            day = weekdayFormatter.string(from: date)
        }
        let ind = arrDays.firstIndex(of: day)!
        dayPicker.selectRow(ind, inComponent: 0, animated: false)
        let cal = Calendar.current
        let minutes = cal.component(.hour, from: date) * 60 + cal.component(.minute, from: date)
        timeSlider.value = Float(minutes)
    }
    
    func setTime() {
        // set time label from slider value
        let value = Int(timeSlider.value)
        let ampm = !Settings.shared.time24hour
        var hour = value / 60
        if ampm {
            // set hour value for 12 hour time
            hour = hour % 12
            if hour == 0 { hour = 12 }
        }
        var strTime = String(format: "%d:%02d", hour, value % 60)
        if strTime.count == 4 {
            // pad string to preserve length
            strTime = (ampm ? " " : "0") + strTime
        }
        if ampm {
            // add am/pm in small font
            strTime += (value < 720) ? "am" : "pm"
            let attrString = NSMutableAttributedString(string: strTime)
            attrString.setAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)], range: NSRange(location: 5, length: 2))
            timeDisplay.attributedText = attrString
        } else {
            timeDisplay.text = strTime
        }
    }
    
    func getDate() -> Date {
        // generate date from inputs
        let cal = Calendar.current
        let date = cal.date(byAdding: .day, value: -1 * dayPicker.selectedRow(inComponent: 0), to: cal.startOfDay(for: Date()))!
        return cal.date(byAdding: .minute, value: Int(timeSlider.value), to: date)!
    }

}

extension TwarpViewController: UIPickerViewDelegate {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return arrDays.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return arrDays[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent: Int) {
        if row == 0 {
            // today selected, so make sure time is not later than current time
            var value = Int(timeSlider.value)
            let now = Date()
            let minutes = Calendar.current.component(.hour, from: now) * 60 + Calendar.current.component(.minute, from: now)
            if value > minutes {
                value = minutes
                timeSlider.value = Float(minutes)
            }
            setTime()
        }
    }
    
}
