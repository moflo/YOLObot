//
//  SwipeViewController.swift
//  yologle
//
//  Created by d. nye on 5/8/19.
//  Copyright © 2019 Mobile Flow LLC. All rights reserved.
//

import UIKit
import SwipeNavigationController


class SwipeViewController: SwipeNavigationController {
    
    func LoadViewController(StoryboardID: String) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let nc = storyboard.instantiateViewController(withIdentifier: StoryboardID) as! UINavigationController
        let vc = nc.viewControllers[0]
        
        if vc.responds(to: Selector(("setParent:"))) {
            vc.perform(Selector(("setParent:")), with: self)
        }
        return nc
    }
    
    required init?(coder aDecoder: NSCoder) {
        //        super.init(coder: aDecoder)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CENTER") as! ViewController
        super.init(centerViewController: vc)
        
        vc.parentVC = self
        delegate = vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        topViewController = LoadViewController(StoryboardID: "ACCOUNTVIEW")
//        bottomViewController = LoadViewController(StoryboardID: "FILM")
        leftViewController = LoadViewController(StoryboardID: "ACTIONSVIEW")
        rightViewController = LoadViewController(StoryboardID: "TRAININGVIEW")
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        DEBUG_LOG("OOM",details: "warning: \(#line) \(#function)")
    }
    
    
}

