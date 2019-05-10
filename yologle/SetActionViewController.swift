//
//  SetActionViewController.swift
//  yologle
//
//  Created by d. nye on 5/9/19.
//  Copyright © 2019 Mobile Flow LLC. All rights reserved.
//

import UIKit

class SetActionViewController: UITableViewController {

    var selectedAction :MFActionType? = nil

    @IBAction func doDoneButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBOutlet weak var actionTitle: UILabel!
    @IBOutlet weak var defaultAction: UILabel!
    @IBAction func doActionSwitch(_ sender: Any) {
    }
    @IBOutlet weak var defaultActionSwitch: UISwitch!
    @IBOutlet weak var scriptTitle: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        guard let action = selectedAction else { return }
        
        actionTitle.text = action.title()
        defaultAction.text = action.defaultAction()

        let actions = UserManager.sharedInstance.getUserDefaultActions()
        if let userDefault = actions[action] as MFActionItem? {

            scriptTitle.text = userDefault.scriptName != nil
                ? "Run '\(userDefault.scriptName!)'"
                : "Run Shortcut"
            
            defaultActionSwitch.isOn = userDefault.useDefault
            
        }
    }
    
    func saveNewScriptName(_ scriptName:String) {
        DispatchQueue.main.async(execute: {
            self.scriptTitle.text = "Run '\(scriptName)'"
            self.defaultActionSwitch.isOn = false
            
            // TODO: Need to update the user values

        })
    }
    
    func promptScriptChange() {
        let alert = UIAlertController(title: "Run Shortcut", message: "Which shortcut to run?", preferredStyle: .alert)
        alert.addTextField(configurationHandler: {(textField: UITextField) in
            textField.placeholder = "Shortcut name..."
            textField.isSecureTextEntry = false
            textField.addTarget(self, action: #selector(self.shortcutTextChanged), for: .editingChanged)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alertAction :UIAlertAction) -> Void in
            // Ready to score...
            print("Cancel")
        }))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: {
            (alertAction :UIAlertAction) -> Void in
            let name_field = alert.textFields![0]
            self.saveNewScriptName(name_field.text!)
            
        }))
        
        (alert.actions[1] ).isEnabled = false // Assume text is invalid (empty)
        self.present(alert, animated: true, completion: { () -> Void in

        })
    }


    @objc func shortcutTextChanged(sender :AnyObject) {
        // Check for valid opponent name
        let textField = sender as! UITextField
        var resp : UIResponder = textField
        while !(resp is UIAlertController) { resp = resp.next! }
        let alert = resp as! UIAlertController
        (alert.actions[1] ).isEnabled = (textField.text != "")
        
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

         if indexPath.section == 0 && indexPath.row == 1 {
            promptScriptChange()
         }
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
