//
//  PolyCatViewController.swift
//  feedthebot
//
//  Created by d. nye on 4/18/19.
//  Copyright © 2019 Mobile Flow LLC. All rights reserved.
//

import UIKit
import SDWebImage

class PolyCatViewController: UIViewController, UIScrollViewDelegate {
    @IBAction func doSettingsButton(_ sender: Any) {
        doTrainAddButton(sender)
    }
    @IBAction func doDoneButton(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    @IBAction func doSkipButton(_ sender: Any) {
        doSaveTrainingEvent("")
    }
    
    @IBAction func doTrainAddButton(_ sender: Any) {
        
//        let alert = MFAlertTrainView(title: "Bounding Category",
//                                     icon: "",
//                                     info: "Tap on the image to add the first point in a rectangle. Tap a second location to draw a box. You can change the box size by dragging the anchor points around.",
//                                     prompt: "Add some boxes") { (category, buttonIndex) in
//
//
//        }
//        alert.show()
        
    }
    @IBAction func doTrainRemoveButton(_ sender: Any) {
        imageView.reset()
    }
    @IBAction func doTrainDoneButton(_ sender: Any) {
        let polyArray = imageView.resetAndGetPolyArray()
        if polyArray.count > 0 {
            print("PolyArray ", polyArray)
            doSaveTrainingEvent("")
        }

        doSaveTrainingEvent("")
        
        UIView.animate(withDuration: 0.33, delay: 0.1, options: .curveEaseOut, animations: { () -> Void in
            
            self.trainDoneButton.isEnabled = false
            self.trainingButtonView.reset()
            
        }, completion: { (done) -> Void in
            // Set underLine width
            
        })
        
    }
    
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: BoundingBoxView!
    
    @IBOutlet weak var trainingButtonView: MFTrainingButtonView!
    @IBOutlet weak var trainDoneButton: UIButton!
    
    var dataSetObj :MFDataSet? = nil
    var trainingCount :Int = 0
    var gameTimer : Timer? = nil
    var gameTimeSeconds : Int = 0
    
    var responseStrings: [String]? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
        scrollView.backgroundColor = MFBlue()

        trainDoneButton.isEnabled = false
        
        // Load the latest Dataset
//        DataSetManager.sharedInstance.loadPage(type: .imageBBoxCategory, page: 1) { (datasets, error) in
//            if error == nil && datasets != nil && datasets!.count > 0 {
//                self.dataSetObj = datasets!.first
//            }
//            else {
//                self.dataSetObj = DataSetManager.sharedInstance.demoDataSet(.imageBBoxCategory)
//            }
//
//            DispatchQueue.main.async {
//                self.doPreloadDataSet()
//                self.doLoadDataSet()
//            }
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        doPreloadDataSet()
        
//        setupStatButtons()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        doLoadDataSet()
        
        // Adjust menu
        trainingButtonView.reset()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
//        gameTimer?.invalidate()
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    // MARK: ScrollView methods
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        return imageView
    }
    
    // MARK: Dataset methods
    
    func doPreloadDataSet() {
    
        self.imageView.image = self.dataSetObj?.currentImage

        setupStatButtons()
    }
    
    func doLoadDataSet() {
        
//        let alert = MFAlertTrainView(title: "Image Classification",
//                                     icon: "",
//                                     info: data.instruction,
//                                     prompt: prompt) { (category, buttonIndex) in
//
//                                        self.startGameTimer()
//
//        }
//        alert.show()
        
    }
    
    func doSaveTrainingEvent(_ text:String) {
        guard let data = dataSetObj else { return }
    
        
    }
    
    func doEndGame() {
        
    }
    
    // MARK: Category button methods
    func showSelectedCateogory(_ identifier: String) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.33, delay: 0.1, options: .curveEaseOut, animations: { () -> Void in
                
                self.trainDoneButton.isEnabled = true
                
                
            }, completion: { (done) -> Void in
                // Set underLine width
                
            })
        }
    }
    
    func setupStatButtons() {
        
        var buttons = [MFTrainButton]()

        if let categoryArray = self.dataSetObj?.categoryArray {
            var catType = BoundingBoxShotType.mark
            
            for category in categoryArray {
                let buttonShot = MFTrainButton(title: category.uppercased(), icon: "icon_text", category: catType)
                buttonShot.completionHandler = { (sender) in
                    self.showSelectedCateogory(category)
                }
                buttons.append(buttonShot)
                
                catType = catType.next()
            }
        }
        else {
            let buttonCorner = MFTrainButton(title: "OPTION1", icon: "icon_text", category: .mark)
            buttonCorner.completionHandler = { (sender) in
                self.showSelectedCateogory("OPTION1")
            }
            buttons.append(buttonCorner)
        }

        trainingButtonView.menuType = .DarkBlue
        trainingButtonView.menuButtons = buttons
        
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
