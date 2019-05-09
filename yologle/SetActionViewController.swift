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
        
        actionTitle.text = action.defaultAction()
        defaultAction.text = action.defaultAction()
        scriptTitle.text = "Run Script"
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
