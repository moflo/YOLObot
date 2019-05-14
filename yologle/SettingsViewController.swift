//
//  SettingsViewController.swift
//  yologle
//
//  Created by d. nye on 5/6/19.
//  Copyright © 2019 Mobile Flow LLC. All rights reserved.
//

import UIKit
import MessageUI
//import Intercom
//import Sherpa
import SwipeNavigationController

class SettingsViewController: UITableViewController, MFMailComposeViewControllerDelegate {

    var parentVC :SwipeNavigationController? = nil
    
    @IBAction func doDoneButton(_ sender: Any) {
//        self.dismiss(animated: true, completion: nil)
        parentVC?.showEmbeddedView(position: .center)
    }

    enum SETTINGS {
        static let SECTION_COUNT = 4
        static let DISMISS_SECTION = -1
        static let ACCOUNT_SECTION = 0
        static let SETTINGS_SECTION = 1
        static let HELP_SECTION = 2
        static let INFO_SECTION = 3
    }
    
    @IBOutlet weak var accountUser: UILabel!
    
    @IBOutlet weak var showFPSSwitch: UISwitch!
    @IBAction func doShowFPSSwitch(_ sender: AnyObject) {
        let show_fps = self.showFPSSwitch.isOn
        UserManager.sharedInstance.setShowFPS(show_fps)
        
    }
    
    
    @IBOutlet weak var feedbackText: UITextView!
    
    @IBOutlet weak var feedbackSwitch: UISegmentedControl!
    
    @IBOutlet weak var sendButton: UIButton!
    @IBAction func doSendButton(_ sender: UIButton) {
        self.doSendEmail()
    }
    
    @IBAction func doHelpFAQButton(_ sender: AnyObject) {
        //        let options = ["enableContactUs":"NEVER"]
        //        HelpshiftSupport.showFAQs(self, withOptions: options)
        //        Intercom.presentHelpCenter()
        
//        let guideURL = Bundle.main.url(forResource: "faq_en", withExtension: "json")!
//        let viewController = SherpaViewController(fileAtURL: guideURL)
//        self.present(viewController, animated: true, completion: nil)
        
    }
    
    @IBAction func doHelpConversationButton(_ sender: AnyObject) {
        // Adding options to require email
//        Intercom.presentMessenger()
    }
    
    func doLogoutAccount() {
        
//        UserManager.sharedInstance.doResetAccount()
//        UserManager.sharedInstance.setSelectedTeam("")
//        UserManager.sharedInstance.refreshUserData { (error) in
//            if let window :UIWindow = UIApplication.shared.keyWindow {
//                let tabBarControl = window.rootViewController as! UITabBarController
//                tabBarControl.selectedIndex = 1
//            }
//        }
        
    }
    @IBOutlet weak var aboutText: UITextView!
    
    var buildVersion :String! = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        self.title = "Settings"
        setupHomeButton()
        
        // Load About text
        let bundle = Bundle.main
        let path = bundle.path(forResource: "About", ofType: "txt")
        let aboutText :String! = try! String(contentsOfFile: path!, encoding: String.Encoding.utf8)
        
        let appVersionString = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let appBuildString :String = bundle.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        let systemVersion = UIDevice.current.systemVersion
        
        self.buildVersion = String(format:"Release %@ (%@) on iOS\(systemVersion)", appVersionString,appBuildString)
        let about_text :String! = "\(aboutText!)\n\n\(buildVersion!)"
        
        self.aboutText.text = about_text
        
        // Set initial send text
//        self.sendButton.isEnabled = true
        
        self.showFPSSwitch.isOn = UserManager.sharedInstance.getShowFPS()
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return SETTINGS.SECTION_COUNT
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (indexPath as NSIndexPath).section == SETTINGS.DISMISS_SECTION {
            self.dismiss(animated: true, completion: nil);
        }
        
        if indexPath.section == SETTINGS.ACCOUNT_SECTION {
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let vc = storyboard.instantiateViewController(withIdentifier: "MFACCOUNTVIEW") as! UINavigationController
//            self.present(vc, animated: true) {
//                //            print("Show login...")
//            }
            let alert = UIAlertController(title: "Switch Accounts", message: "Sign out and switch accounts", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Sign Out", style: UIAlertAction.Style.default, handler: {
                (alert :UIAlertAction) -> Void in
//                self.doLogoutAccount()
            }))
            self.present(alert, animated: true, completion: nil)

        }
        
        if (indexPath as NSIndexPath).section == SETTINGS.INFO_SECTION {
            // Hidden trigger to load demo date, Sort Jersey switch needs to be on & tap thrid section
            NSLog("Done")
            if self.showFPSSwitch.isOn {
                let alert = UIAlertController(title: "Add Demo Data", message: "Add demo league and team data for testing?", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "Add Data", style: UIAlertAction.Style.default, handler: {
                    (alert :UIAlertAction) -> Void in
                    // Create new dummy data...
//                    self.doSeedData()
                    self.dismiss(animated: true, completion: nil);
                }))
                self.present(alert, animated: true, completion: nil)
                
            }
        }
        
        if (indexPath as NSIndexPath).section == SETTINGS.HELP_SECTION {
            // Help and support
            if (indexPath as NSIndexPath).row == 0 {
                self.doHelpFAQButton(self)
            }
            if (indexPath as NSIndexPath).row == 1 {
//                self.doHelpConversationButton(self)
                self.doSendEmail()
            }
        }
    }
    
    
    // MARK - Delegate methods
    
    func URLEncodedString(_ string: String) -> String? {
        let customAllowedSet =  CharacterSet.urlQueryAllowed
        let escapedString = string.addingPercentEncoding(withAllowedCharacters: customAllowedSet)
        return escapedString
    }
    
    func doSendEmail() {
        let messageBody = buildVersion      // self.feedbackText.text
        
        if (messageBody?.count)!>0 {
            
//            var emailTitle = self.feedbackSwitch.selectedSegmentIndex == 0 ? "[Suggestion]" : "[Bug Report]"
            var emailTitle = "[Suggestion]"
            emailTitle += " YOLObot Feedback"
            let message_text :String! = "\(String(describing: messageBody))\n\n\(String(describing: self.buildVersion))"
            let email = "YOLObot@moflo.me"
            let toRecipents = [email]
            
            if let mc = MFMailComposeViewController() as MFMailComposeViewController? {
                mc.mailComposeDelegate = self
                mc.setSubject(emailTitle)
                
                mc.setMessageBody(message_text, isHTML: false)
                mc.setToRecipients(toRecipents)
                
                self.present(mc, animated: true, completion: nil)
            }
            else {
                // Use the Mail app
                let subject = URLEncodedString(emailTitle) ?? "Bug"
                let body = URLEncodedString(message_text) ?? "YOLObot"
                let email_url = "mailto:\(email)?subject=\(subject)&body=\(body)"
                if let url = URL(string: email_url) as URL? {
                    //                    UIApplication.shared.openURL(url)
                    UIApplication.shared.open(url, options: [:]) { (done) in
                    }
                }
                else {
                    let alert = UIAlertController(title: "Feedback Issue", message: "Sorry, there was a problem. Please send your feedback by email to: YOLObot@moflo.me", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                    
                }
            }
        }
        
    }
    
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result.rawValue {
        case MFMailComposeResult.cancelled.rawValue:
            print("Mail cancelled")
        case MFMailComposeResult.saved.rawValue:
            print("Mail saved")
        case MFMailComposeResult.sent.rawValue:
            print("Mail sent")
        case MFMailComposeResult.failed.rawValue:
            print("Mail sent failure: \(error!.localizedDescription)")
        default:
            break
        }
        self.dismiss(animated: false, completion: nil)
    }

}

extension SettingsViewController : SwipeNavigationControllerDelegate {
    
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
    
    func setupHomeButton() {
        
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
