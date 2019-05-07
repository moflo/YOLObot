//
//  ActionViewController.swift
//  yologle
//
//  Created by d. nye on 5/6/19.
//  Copyright © 2019 Mobile Flow LLC. All rights reserved.
//

import UIKit
import SafariServices

class ActionViewController: UITableViewController {

    @IBAction func doDoneButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    enum ACTIONS {
        static let SECTION_COUNT = 4
        static let PHONE_SECTION = 0
        static let SETTINGS_SECTION = 1
        static let HELP_SECTION = 2
        static let INFO_SECTION = 3
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return ACTIONS.SECTION_COUNT
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == ACTIONS.PHONE_SECTION {
            let alert = UIAlertController(title: "Phone Number", message: "Run shortcut?", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Run", style: UIAlertAction.Style.default, handler: {
                (alert :UIAlertAction) -> Void in
                //                self.doLogoutAccount()
                let url = URL(string: "tel://1-408-555-1212")
                let options :[UIApplication.OpenExternalURLOptionsKey : Any] = [:]
                UIApplication.shared.open(url!,options:options,completionHandler: { done in
                    print("URL open :", done)
                })
                
                
            }))
            self.present(alert, animated: true, completion: nil)
            
        }

        if indexPath.section == ACTIONS.SETTINGS_SECTION {
            let alert = UIAlertController(title: "Coffee Cup", message: "Run shortcut?", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Run", style: UIAlertAction.Style.default, handler: {
                (alert :UIAlertAction) -> Void in
                
                let url = URL(string: "shortcuts://x-callback-url/run-shortcut?name=Shorten%20URL&id=89F0177B-A177-4040-9AA2-9A6C6597E9C2&source=homescreen")
                UIApplication.shared.open(url!,options:[:],completionHandler: { done in
                    print("URL open :", done)
                })

            }))
            self.present(alert, animated: true, completion: nil)

        }

    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
