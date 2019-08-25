//
//  AddFavouriteViewController.swift
//  Twarp
//
//  Created by David Shaw on 24/5/17.
//  Copyright © 2017 David Shaw. All rights reserved.
//

import UIKit

class AddFavouriteViewController: UIViewController {

    // input field handles
    @IBOutlet weak var favName: UITextField!
    @IBOutlet weak var favHashtag: UILabel!
    @IBOutlet weak var lblStartTime: UILabel!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    // parameters for segue
    var hashTag: String? = nil
    var time: Date? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // set field values from segue parameters
        let df = DateFormatter()
        df.amSymbol = "am"
        df.pmSymbol = "pm"
        var dfTime = "h:mma"
        if Settings.shared.time24hour {
            dfTime = "HH:MM"
        }
        df.dateFormat = "EEEE \(dfTime)"
        let date = df.string(from: time!)
        
        favName.text = "#\(hashTag!) \(date)"
        favHashtag.text = "#\(hashTag!)"
        
        lblStartTime.text = date
        
        // set toolbar button icons
        // save menu button - disk icon
        let attributes = [NSAttributedStringKey.font: UIFont.fontAwesome(ofSize: 18)]
        saveButton.setTitleTextAttributes(attributes, for: .normal)
        saveButton.title = "\(String.fontAwesomeIcon(name: .floppyO )) Save"
        
        // cancel menu button - cross icon
        cancelButton.setTitleTextAttributes(attributes, for: .normal)
        cancelButton.title = "\(String.fontAwesomeIcon(name: .timesCircle)) Cancel"
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // show navbar
        self.navigationController?.navigationBar.isHidden = false
    }

}
