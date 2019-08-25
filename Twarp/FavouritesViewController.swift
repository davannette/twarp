//
//  FavouritesViewController.swift
//  Twarp
//
//  Created by David Shaw on 25/5/17.
//  Copyright © 2017 David Shaw. All rights reserved.
//

import UIKit
// import Toast_Swift

class FavouritesViewController: UITableViewController {
    
    @IBOutlet weak var btnLaunch: UIBarButtonItem!
    @IBOutlet weak var btnDelete: UIBarButtonItem!
    
    var favourites = Favourites.shared
    var selectedIndex: IndexPath? = nil
    var delPrompt: UIAlertController = UIAlertController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create delete prompt popup
        delPrompt.title = "Delete favourite?"
        delPrompt.addAction(UIAlertAction(title: "Delete", style: .default, handler: deleteSelection))
        delPrompt.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        delPrompt.message = "Are you sure you want to delete your favourite?"
        
        // set tab bar button icons:
//        let attributes = [NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue): UIFont.fontAwesome(ofSize: 18)] as [NSAttributedStringKey: Any]?
//        btnLaunch.setTitleTextAttributes(attributes, for: .normal)
        btnLaunch.title = "Open" // \(String.fontAwesomeIcon(name: .shareSquareO)) Open"
        
//        btnDelete.setTitleTextAttributes(attributes, for: .normal)
        btnDelete.title = "Delete" // \(String.fontAwesomeIcon(name: .trashO)) Delete"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // show navbar
        self.navigationController?.navigationBar.isHidden = false
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if favourites.count > 0
        {
            tableView.separatorStyle = .singleLine
            tableView.backgroundView = nil
        }
        else
        {
            // display message when favourites list is empty
            let emptyLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            emptyLabel.text = "No favourites saved"
            emptyLabel.textColor = UIColor.black
            emptyLabel.textAlignment = .center
            tableView.backgroundView = emptyLabel
            tableView.separatorStyle = .none
        }
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favourites.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "FavouritesTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? FavouritesTableViewCell else {
            fatalError("The dequeued cell is not an instance of FavouritesTableViewCell")
        }
        
        // Configure the cell
        // cell.favouriteLabel.text = favourites.name(at: indexPath.row)
        let favourite = favourites.favourite(at: indexPath.row)
        cell.hashtag.text = "#\(favourite.HashTag)"
        cell.day.text = favourite.Day
        cell.time.text = favourite.Time
        
        return cell

    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderTableViewCell") as? CustomHeaderCell else {
            fatalError("Cannot dequeue header cell")
        }
        return cell
    }
    
    @IBAction func deleteFavourite() {
        if selectedIndex != nil {
            // prompt to confirm delete
            self.present(delPrompt, animated: true, completion: nil)
        } else {
            // nothing selected
            self.navigationController?.view.showToast("Make a selection first!")
        }
    }
    
    @IBAction func openFavourite() {
        if selectedIndex != nil {
            // open favourite
            self.performSegue(withIdentifier: "unwindOpenFavouriteSegue", sender: self)
        } else {
            // nothing selected
            self.navigationController?.view.showToast("Make a selection first!")
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath
    }
    
    func deleteSelection(alert: UIAlertAction!) {
        // delete confirmed, remove favourite
        favourites.remove(at: selectedIndex!.row)
        self.tableView.deleteRows(at: [selectedIndex!], with: .automatic)
        selectedIndex = nil
        self.navigationController?.view.showToast("Favourite removed")
    }

}
