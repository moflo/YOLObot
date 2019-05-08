//
//  ViewController.swift
//  yologle
//
//  Created by d. nye on 5/6/19.
//  Copyright © 2019 Mobile Flow LLC. All rights reserved.
//

import UIKit
import AVFoundation
import Vision
import SwipeNavigationController

class ViewController: CameraViewController {

    var parentVC :SwipeNavigationController? = nil
    

    @IBAction func doHelpButton(_ sender: Any) {
        // let storyboard = UIStoryboard(name: "Main", bundle: nil)
        // let vc = storyboard.instantiateViewController(withIdentifier: "ACCOUNTVIEW") as! UINavigationController
        // self.present(vc, animated: true)
        parentVC?.showEmbeddedView(position: .top)
    }
    @IBAction func doSettingsButton(_ sender: Any) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "ACTIONSVIEW") as! UINavigationController
//        self.present(vc, animated: true)
        parentVC?.showEmbeddedView(position: .left)
    }
    
    func doInjectCurrentImage() {
        guard let nc = parentVC?.rightViewController as? UINavigationController,
            let tc = nc.viewControllers[0] as? PolyCatViewController else { return }
        
        let dataSet = MFDataSet(
            categoryArray:["Signage","Telephone","URL","UPC","Menu","Other"]
        )
        
        if let pixelBuffer = previousPixelBuffer {
            let exifOrientation = exifOrientationFromDeviceOrientation()
            
            let ciImage = CIImage(cvImageBuffer: pixelBuffer)
            ciImage.oriented(exifOrientation)
            let uiImage = UIImage(ciImage: ciImage)
            dataSet.currentImage = uiImage
        }
        
        tc.dataSetObj = dataSet

    }
    
    @IBAction func doTrainButton(_ sender: Any) {
        doInjectCurrentImage()
        //        self.present(vc, animated: true)
        parentVC?.showEmbeddedView(position: .right)

    }
    @IBAction func doSkipButton(_ sender: Any) {
        self.startCaptureSession()
    }
    @IBAction func doActionButton(_ sender: Any) {
        let url = URL(string: "tel://1-408-555-1212")
        let options :[UIApplication.OpenExternalURLOptionsKey : Any] = [:]
        UIApplication.shared.open(url!,options:options,completionHandler: { done in
            print("URL open :", done)
        })
    }

    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var trainButton: UIButton!


    private var detectionViewOpen :Bool = false
    private var detectionOverlay: CALayer! = nil
    
    // Vision parts
    private var requests = [VNRequest]()

    // Stability check
    private let sequenceRequestHandler = VNSequenceRequestHandler()
    private let maximumHistoryLength = 15
    private var transpositionHistoryPoints: [CGPoint] = [ ]
    private var previousPixelBuffer: CVPixelBuffer?
    
    // The current pixel buffer undergoing analysis. Run requests in a serial fashion, one after another.
    private var currentlyAnalyzedPixelBuffer: CVPixelBuffer?

    
    @discardableResult
    func setupVision() -> NSError? {
        // Setup Vision parts
        let error: NSError! = nil
        
        guard let modelURL = Bundle.main.url(forResource: "ObjectDetector", withExtension: "mlmodelc") else {
            return NSError(domain: "VisionObjectRecognitionViewController", code: -1, userInfo: [NSLocalizedDescriptionKey: "Model file is missing"])
        }
        do {
            let visionModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
            let objectRecognition = VNCoreMLRequest(model: visionModel, completionHandler: { (request, error) in
                DispatchQueue.main.async(execute: {
                    // perform all the UI updates on the main queue
                    if let results = request.results {
                        self.drawVisionRequestResults(results)
                    }
                })
            })
            self.requests = [objectRecognition]
        } catch let error as NSError {
            print("Model loading went wrong: \(error)")
        }
        
        return error
    }
    
    func drawVisionRequestResults(_ results: [Any]) {
        detectionViewOpen = true
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        detectionOverlay.sublayers = nil // remove all the old recognized objects
        for observation in results where observation is VNRecognizedObjectObservation {
            guard let objectObservation = observation as? VNRecognizedObjectObservation else {
                continue
            }
            // Select only the label with the highest confidence.
            let topLabelObservation = objectObservation.labels[0]
            let objectBounds = VNImageRectForNormalizedRect(objectObservation.boundingBox, Int(bufferSize.width), Int(bufferSize.height))
            
            let shapeLayer = self.createRoundedRectLayerWithBounds(objectBounds)
            
            let textLayer = self.createTextSubLayerInBounds(objectBounds,
                                                            identifier: topLabelObservation.identifier,
                                                            confidence: topLabelObservation.confidence)
            shapeLayer.addSublayer(textLayer)
            detectionOverlay.addSublayer(shapeLayer)
        }
        self.updateLayerGeometry()
        CATransaction.commit()
        
        // Pause capture session
        self.stopCaptureSession()
    }
    
    override func stopCaptureSession() {
        super.stopCaptureSession()
        
        UIView.animate(withDuration: 0.33, delay: 0.1, options: .curveEaseOut, animations: { () -> Void in
            
            self.actionButton.isHidden = false
            self.trainButton.isHidden = false
            self.skipButton.isHidden = false
            
            
        }, completion: { (done) -> Void in
            // Set underLine width
            
        })

    }
    
    override func startCaptureSession() {
        super.startCaptureSession()
        
        UIView.animate(withDuration: 0.33, delay: 0.1, options: .curveEaseOut, animations: { () -> Void in
            
            self.actionButton.isHidden = true
            self.trainButton.isHidden = true
            self.skipButton.isHidden = true
            
            
        }, completion: { (done) -> Void in
            // Set underLine width
            
        })
        
    }

    
    override func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
                sceneStabilityAchieved(pixelBuffer) == true else {
            return
        }
        
        let exifOrientation = exifOrientationFromDeviceOrientation()
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: exifOrientation, options: [:])
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    

    override func setupAVCapture() {
        super.setupAVCapture()
        
        guard didSetupAVCapture == true else {
            print("Error setting up AV Capture")
            return
        }
        
        // setup Vision parts
        setupLayers()
        updateLayerGeometry()
        
        if let err = setupVision() {
            print("Error setting up vision", err.localizedDescription)
            return
        }
        
        // start the capture
        startCaptureSession()
    }
    
    func setupLayers() {
        detectionOverlay = CALayer() // container layer that has all the renderings of the observations
        detectionOverlay.name = "DetectionOverlay"
        detectionOverlay.bounds = CGRect(x: 0.0,
                                         y: 0.0,
                                         width: bufferSize.width,
                                         height: bufferSize.height)
        detectionOverlay.position = CGPoint(x: rootLayer.bounds.midX, y: rootLayer.bounds.midY)
        rootLayer.addSublayer(detectionOverlay)
    }
    
    func updateLayerGeometry() {
        let bounds = rootLayer.bounds
        var scale: CGFloat
        
        let xScale: CGFloat = bounds.size.width / bufferSize.height
        let yScale: CGFloat = bounds.size.height / bufferSize.width
        
        scale = fmax(xScale, yScale)
        if scale.isInfinite {
            scale = 1.0
        }
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        
        // rotate the layer into screen orientation and scale and mirror
        detectionOverlay.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(.pi / 2.0)).scaledBy(x: scale, y: -scale))
        // center the layer
        detectionOverlay.position = CGPoint (x: bounds.midX, y: bounds.midY)
        
        CATransaction.commit()
        
    }
    
    func createTextSubLayerInBounds(_ bounds: CGRect, identifier: String, confidence: VNConfidence) -> CATextLayer {
        let textLayer = CATextLayer()
        textLayer.name = "Object Label"
        let formattedString = NSMutableAttributedString(string: String(format: "\(identifier)\nConfidence:  %.2f", confidence))
        let largeFont = UIFont(name: "Helvetica", size: 24.0)!
        formattedString.addAttributes([NSAttributedString.Key.font: largeFont], range: NSRange(location: 0, length: identifier.count))
        textLayer.string = formattedString
        textLayer.bounds = CGRect(x: 0, y: 0, width: bounds.size.height - 10, height: bounds.size.width - 10)
        textLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        textLayer.shadowOpacity = 0.7
        textLayer.shadowOffset = CGSize(width: 2, height: 2)
        textLayer.foregroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [0.0, 0.0, 0.0, 1.0])
        textLayer.contentsScale = 2.0 // retina rendering
        // rotate the layer into screen orientation and scale and mirror
        textLayer.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(.pi / 2.0)).scaledBy(x: 1.0, y: -1.0))
        return textLayer
    }
    
    func createRoundedRectLayerWithBounds(_ bounds: CGRect) -> CALayer {
        let shapeLayer = CALayer()
        shapeLayer.bounds = bounds
        shapeLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        shapeLayer.name = "Found Object"
        shapeLayer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 0.2, 0.4])
        shapeLayer.cornerRadius = 7
        return shapeLayer
    }

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
//        if segue.identifier == "scoreSegue" {
//            let controller = segue.destination as! GameViewController
//            controller.currentTeam = self.scoredTeam
//        }
    }

}

extension ViewController {
    
    // MARK: - SceneStability Check
    
    func sceneStabilityAchieved(_ pixelBuffer: CVImageBuffer) -> Bool {        
        guard previousPixelBuffer != nil else {
            previousPixelBuffer = pixelBuffer
            self.resetTranspositionHistory()
            return false
        }
        
        if detectionViewOpen {
            return false
        }
        
        let registrationRequest = VNTranslationalImageRegistrationRequest(targetedCVPixelBuffer: pixelBuffer)
        do {
            try sequenceRequestHandler.perform([ registrationRequest ], on: previousPixelBuffer!)
        } catch let error as NSError {
            print("Failed to process request: \(error.localizedDescription).")
            return false
        }
        
        previousPixelBuffer = pixelBuffer
        
        if let results = registrationRequest.results {
            if let alignmentObservation = results.first as? VNImageTranslationAlignmentObservation {
                let alignmentTransform = alignmentObservation.alignmentTransform
                self.recordTransposition(CGPoint(x: alignmentTransform.tx, y: alignmentTransform.ty))
            }
        }

        // Determine if we have enough evidence of stability.
        if transpositionHistoryPoints.count == maximumHistoryLength {
            // Calculate the moving average.
            var movingAverage: CGPoint = CGPoint.zero
            for currentPoint in transpositionHistoryPoints {
                movingAverage.x += currentPoint.x
                movingAverage.y += currentPoint.y
            }
            let distance = abs(movingAverage.x) + abs(movingAverage.y)
            if distance < 20 {
                return true
            }
        }
        return false
    }

    fileprivate func resetTranspositionHistory() {
        transpositionHistoryPoints.removeAll()
    }
    
    fileprivate func recordTransposition(_ point: CGPoint) {
        transpositionHistoryPoints.append(point)
        
        if transpositionHistoryPoints.count > maximumHistoryLength {
            transpositionHistoryPoints.removeFirst()
        }
    }

}

extension ViewController : SwipeNavigationControllerDelegate {
    
    /// Callback when embedded view started moving to new position
    func swipeNavigationController(_ controller: SwipeNavigationController, willShowEmbeddedViewForPosition position: Position) {
        parentVC = controller
        
        // Check if user wants to Train / Add the current image
        if position == .right {
            doInjectCurrentImage()
        }
    }
    
    /// Callback when embedded view had moved to new position
    func swipeNavigationController(_ controller: SwipeNavigationController, didShowEmbeddedViewForPosition position: Position) {
        parentVC = controller
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        DEBUG_LOG("OOM",details: "warning: \(#line) \(#function)")
    }
    
}

