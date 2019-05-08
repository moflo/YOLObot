//
//  ActionViewController.swift
//  yologle
//
//  Created by d. nye on 5/6/19.
//  Copyright © 2019 Mobile Flow LLC. All rights reserved.
//

import UIKit
import SafariServices
import SwipeNavigationController

class ActionViewController: UITableViewController {

    var parentVC :SwipeNavigationController? = nil

    @IBAction func doDoneButton(_ sender: Any) {
//        self.dismiss(animated: true, completion: nil)
        parentVC?.showEmbeddedView(position: .center)

    }

    enum ACTIONS {
        static let SECTION_COUNT = 4
        static let PHONE_SECTION = 0
        static let SETTINGS_SECTION = 1
        static let HELP_SECTION = 2
        static let INFO_SECTION = 3
    }

//    override func viewDidLoad() {
//        super.viewDidLoad()
//    }

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

extension ActionViewController : SwipeNavigationControllerDelegate {
    
    @objc public func setParent(_ parentVC:SwipeNavigationController?) {
        self.parentVC = parentVC
    }
    
    /// Callback when embedded view started moving to new position
    func swipeNavigationController(_ controller: SwipeNavigationController, willShowEmbeddedViewForPosition position: Position) {
        parentVC = controller
    }
    
    /// Callback when embedded view had moved to new position
    func swipeNavigationController(_ controller: SwipeNavigationController, didShowEmbeddedViewForPosition position: Position) {
        parentVC = controller
    }
    
    @IBAction func doHomeButton(_ sender: Any) {
        parentVC?.showEmbeddedView(position: .center)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        //        view.backgroundColor = MFTableBackground()
        //
        //        self.navigationController?.navigationBar.barTintColor = MFNavBackground()
        //        self.navigationController?.navigationBar.tintColor = MFNavTint()
        //        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: MFNavText()]
        
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "nav_home"), for: .normal)
        button.addTarget(self, action: #selector(self.doHomeButton(_:)), for: .touchUpInside)
        //set frame
        button.frame = CGRect(x:0, y:0, width:30, height:30)
        
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.leftBarButtonItem = barButton
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        DEBUG_LOG("OOM",details: "warning: \(#line) \(#function)")
    }
    
}

