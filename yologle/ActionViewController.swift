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

    let ACTION_ORDER :[MFActionType] = [.phone,.map,.email,.upc,.qr,.meishi,.food]
    enum ACTIONS {
        static let SECTION_COUNT = 7
        static let PHONE_SECTION = 0
        static let MAP_SECTION = 1
        static let EMAIL_SECTION = 2
        static let UPC_SECTION = 3
        static let QR_SECTION = 4
        static let CARD_SECTION = 5
        static let FOOD_SECTION = 6
    }

    @IBOutlet weak var dialAction: UILabel!
    @IBOutlet weak var mapAction: UILabel!
    @IBOutlet weak var emailAction: UILabel!
    @IBOutlet weak var upcAction: UILabel!
    @IBOutlet weak var qrAction: UILabel!
    @IBOutlet weak var cardAction: UILabel!
    @IBOutlet weak var foodAction: UILabel!
    
    var selectedSection = -1
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let actions = UserManager.sharedInstance.getUserDefaultActions()
        
        dialAction.text = actions[.phone]?.actionTitle()
        mapAction.text = actions[.map]?.actionTitle()
        emailAction.text = actions[.email]?.actionTitle()
        upcAction.text = actions[.upc]?.actionTitle()
        qrAction.text = actions[.qr]?.actionTitle()
        cardAction.text = actions[.meishi]?.actionTitle()
        foodAction.text = actions[.food]?.actionTitle()

    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return ACTIONS.SECTION_COUNT
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Save section selection for segue
        selectedSection = indexPath.section
    
        self.performSegue(withIdentifier: "setActionSegue", sender: self)
        
        /*
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

        if indexPath.section == ACTIONS.MAP_SECTION {
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
        */
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        if segue.identifier == "setActionSegue" {
            guard let nc = segue.destination as? UINavigationController,
                let vc = nc.viewControllers[0] as? SetActionViewController else { return }
            
            vc.selectedAction = ACTION_ORDER[selectedSection]
            
        }

    }

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

