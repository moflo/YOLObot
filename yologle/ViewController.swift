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
import Firebase

class ViewController: UIViewController {

    // MARK: - UI
    
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var trainButton: UIButton!
    @IBOutlet weak var actionIcon: UIImageView!
    @IBOutlet weak var actionLabel: UILabel!
    
    @IBOutlet weak private var previewView: UIView!

    @IBOutlet weak var overlayTextView: OverlayTextView!
    
    @IBOutlet weak var overlayYOLOView: OverlayYOLOView!
    
    @IBOutlet weak var stabilityImageView: UIImageView!

    @IBOutlet weak var performanceHUD: PerformanceHUDView!

    // MARK : CameraControl
    var videoCapture: CameraController!

    // MARK: ML Kit Vision
    lazy var vision = Vision.vision()
    lazy var textRecognizer = vision.onDeviceTextRecognizer()
    
    private var detectionViewOpen :Bool = false
    private var detectionOverlay: CALayer! = nil

    // MARK: - Navigation
    var parentVC :SwipeNavigationController? = nil
    
    @IBAction func doHelpButton(_ sender: Any) {
        self.detectionViewOpen = false
//        self.resetTranspositionHistory()
        parentVC?.showEmbeddedView(position: .top)
    }
    
    @IBAction func doSettingsButton(_ sender: Any) {
        self.detectionViewOpen = false
//        self.resetTranspositionHistory()
        parentVC?.showEmbeddedView(position: .left)
    }
    
    @IBAction func doTrainButton(_ sender: Any) {
        self.detectionViewOpen = false
//        self.resetTranspositionHistory()
        doInjectCurrentImage()
        //        self.present(vc, animated: true)
        parentVC?.showEmbeddedView(position: .right)

    }
    
    @IBAction func doSkipButton(_ sender: Any) {
        self.detectionViewOpen = false
//        self.resetTranspositionHistory()
        self.startCaptureSession()
    }
    
    @IBAction func doActionButton(_ sender: Any) {
        let url = URL(string: "tel://1-408-555-1212")
        let options :[UIApplication.OpenExternalURLOptionsKey : Any] = [:]
        UIApplication.shared.open(url!,options:options,completionHandler: { done in
            print("URL open :", done)
        })
    }


    // MARK: - CoreML Vision
    private var requests = [VNRequest]()

    // The current pixel buffer undergoing analysis. Run requests in a serial fashion, one after another.
    private var currentlyAnalyzedPixelBuffer: CVPixelBuffer?

    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up CoreML vision
        setupVision()
        
        // Set up CameraController
        setupAVCapture()
        
//        self.overlayTextView.frame = self.view.frame
        self.overlayTextView.bounds = self.view.frame
        // TODO: Why??? Also, this causes view to 'extend' into left & right screens?
        self.overlayTextView.transform = CGAffineTransform.init(scaleX: 1.7, y: 1.0)
        
        self.overlayYOLOView.bounds = self.view.frame
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let show = UserManager.sharedInstance.getShowFPS()
        self.performanceHUD.isHidden = !show
    }

    func setupAVCapture() {
        videoCapture = CameraController()
        videoCapture.delegate = self
        videoCapture.setupAVCapture(sessionPreset: .vga640x480) { success in
            
            if success {
                // add preview view on the layer
                if let previewLayer = self.videoCapture.previewLayer {
                    self.previewView.layer.addSublayer(previewLayer)
                    self.resizePreviewLayer()
                }
                
                // setup Vision parts
                self.setupLayers()
                self.updateLayerGeometry()
                
                if let err = self.setupVision() {
                    print("Error setting up vision", err.localizedDescription)
                    return
                }
                
                // start the capture
                self.startCaptureSession()
            }
            else {
                print("Error setting up AV Capture")
                return
            }

        }

    }
    
    
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
            
            let textRegcognition = VNDetectTextRectanglesRequest { (request, error) in
                DispatchQueue.main.async(execute: {
                    // perform all the UI updates on the main queue
                    if let results = request.results {
                        self.drawTextRequestResults(results)
                    }
                })
                
            }
            textRegcognition.reportCharacterBoxes = true
            
            self.requests = [objectRecognition, textRegcognition]
            
        } catch let error as NSError {
            print("Model loading went wrong: \(error)")
        }
        
        return error
    }
    
    func drawVisionRequestResults(_ results: [Any]) {
        guard results.count > 0 else {
//            self.showStabilityImage(false)
//            self.resetTranspositionHistory()
            return
        }

        let observations: [VNRecognizedObjectObservation]? = results.filter({return $0 is VNRecognizedObjectObservation}).map({$0}) as? [VNRecognizedObjectObservation]
        
        self.overlayYOLOView.observations = observations

    }
    
    func drawTextRequestResults(_ results: [Any]) {
        guard results.count > 0 else {
//            self.showStabilityImage(false)
//            self.resetTranspositionHistory()
            return
        }
        
        self.performanceHUD.label(with: "endInference")

        let regions: [VNTextObservation?] = results.map({$0 as? VNTextObservation})
        
        self.overlayTextView.regions = regions
        
        self.performanceHUD.stop()
    }
    
    
    
    func updateObservationLabel(_ obervations: [VNClassificationObservation]) {
        guard obervations.count > 0 else { return }
        
        let max_label = obervations.sorted(by: { $0.confidence > $1.confidence } )[0].identifier
        
        self.actionLabel.text = max_label
    }
    
    func stopCaptureSession() {
//        self.videoCapture.stopCaptureSession()
        
        UIView.animate(withDuration: 0.33, delay: 0.1, options: .curveEaseOut, animations: { () -> Void in
            
            self.actionButton.isHidden = false
            self.trainButton.isHidden = false
            self.skipButton.isHidden = false
            self.actionIcon.isHidden = false
            self.actionLabel.isHidden = false
            
        }, completion: { (done) -> Void in
            // Set underLine width
            
        })
        
    }
    
    func startCaptureSession() {
        self.videoCapture.startCaptureSession()
        
        UIView.animate(withDuration: 0.33, delay: 0.1, options: .curveEaseOut, animations: { () -> Void in
            
            self.actionButton.isHidden = true
            self.trainButton.isHidden = true
            self.skipButton.isHidden = true
            self.actionIcon.isHidden = true
            self.actionLabel.isHidden = true
            
            
        }, completion: { (done) -> Void in
            // Set underLine width
            
        })
        
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        resizePreviewLayer()
    }
    
    func resizePreviewLayer() {
        videoCapture.previewLayer?.frame = previewView.bounds
    }

    func setupLayers() {
        let bufferSize = videoCapture.bufferSize
        let rootLayer = self.previewView.layer
        
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
        let rootLayer = self.previewView.layer

        let bounds = rootLayer.bounds
        var scale: CGFloat
        
        let bufferSize = videoCapture.bufferSize

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


// MARK: - Swipe Navigation Controller
extension ViewController : SwipeNavigationControllerDelegate {
    
    /// Callback when embedded view started moving to new position
    func swipeNavigationController(_ controller: SwipeNavigationController, willShowEmbeddedViewForPosition position: Position) {
        parentVC = controller
        
        // Check if user wants to Train / Add the current image
        if position == .right {
            doInjectCurrentImage()
        }
    }
    
    func MFScaleCenterUIImage(_ image:UIImage, width:Double, height:Double) -> UIImage {
        guard height != 0.0, width != 0.0, let cgImage = image.cgImage else { return image }
        
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        //        let scaled_rect = AVMakeRect(aspectRatio: image.size,insideRect: CGRect(x:0, y:0, width:width, height:height))
        
        
        let size = CGSize(width: CGFloat(width), height: CGFloat(height))
        let sizeRect = CGRect(x:0, y:0, width:width, height:height)
        
        let imgW = image.size.width
        let imgH = image.size.height
        let minDim = CGFloat.minimum(imgW,imgH)
        let maxDim = CGFloat.maximum(imgW,imgH)
        
        let Yoffset = minDim == imgW ? (maxDim - minDim) * 0.5 : 0.0
        let Xoffset = minDim == imgW ? 0.0 : (maxDim - minDim) * 0.5
        
        let cropRect = CGRect(x: Xoffset, y: Yoffset, width: minDim, height: minDim)
        guard let crop = cgImage.cropping(to: cropRect) else { return image }
        let cropImage = UIImage(cgImage: crop)
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        //        let context = UIGraphicsGetCurrentContext()
        //        context?.clip(to: sizeRect)
        
        cropImage.draw(in: sizeRect)
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage!
        
    }
    
    func doInjectCurrentImage() {
        guard let nc = parentVC?.rightViewController as? UINavigationController,
            let tc = nc.viewControllers[0] as? PolyCatViewController else { return }
        
        let dataSet = MFDataSet(
            categoryArray:["Signage","Telephone","URL","UPC","Menu","Other"]
        )
        
        if let pixelBuffer = self.videoCapture.getCurrentPixelBuffer() {
            //            let exifOrientation = exifOrientationFromDeviceOrientation()
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let context = CIContext(options: nil)
            guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
                return
            }
            let rotatedImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: .right)
            
            dataSet.currentImage = MFScaleCenterUIImage(rotatedImage,width: 416.0,height: 416.0)
        }
        
        tc.dataSetObj = dataSet
        
    }

    
    /// Callback when embedded view had moved to new position
    func swipeNavigationController(_ controller: SwipeNavigationController, didShowEmbeddedViewForPosition position: Position) {
        parentVC = controller

        // Update UI based on settings
        let show = UserManager.sharedInstance.getShowFPS()
        self.performanceHUD.isHidden = !show

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        DEBUG_LOG("OOM",details: "warning: \(#line) \(#file)\n\(Thread.callStackSymbols.forEach{print($0)})")
    }
    
}
// MARK: - ML Kit Processing

extension ViewController {
    
    func predictUsingVision(pixelBuffer: CVPixelBuffer?) {
        guard pixelBuffer != nil else { return }
        
        let ciimage: CIImage = CIImage(cvImageBuffer: pixelBuffer!)

        let ciContext = CIContext()
        guard let cgImage: CGImage = ciContext.createCGImage(ciimage, from: ciimage.extent) else {
//            self.isInference = false
            // end of measure
            self.performanceHUD.start()
            return
        }
        
        let uiImage: UIImage = UIImage(cgImage: cgImage)
        let croppedImage = MFScaleCenterUIImage(uiImage,width: 416.0,height: 416.0)
        let visionImage = VisionImage(image: uiImage)
        textRecognizer.process(visionImage) { (result, error) in

            self.performanceHUD.label(with: "endInference")

            // this closure is called on main thread
            if error == nil, let features: VisionText = result {
//                print("Feature text: ",features.text)
                self.stopCaptureSession()
                self.actionLabel.text = features.text
                
            } else {
//                print("No features, error: ", error?.localizedDescription)
            }
            
            
//            self.isInference = false
            
            // end of measure
            self.performanceHUD.stop()
        }
    }

}

extension ViewController : CameraControllerDelegate {
    

    func videoDidStablize(_ isStable: Bool) {
        DispatchQueue.main.async(execute: {
            let image_name = isStable ? "focus_large_active" : "focus_large"
            self.stabilityImageView.image = UIImage(named: image_name)
            self.currentlyAnalyzedPixelBuffer = self.videoCapture.getCurrentPixelBuffer()
            self.predictUsingVision(pixelBuffer: self.currentlyAnalyzedPixelBuffer)
            
        })
    }
    
    
    func videoCapture(_ capture: CameraController, sampleBuffer: CVPixelBuffer?, timestamp: CMTime) {
        
        guard let pixelBuffer = sampleBuffer else {  // CMSampleBufferGetImageBuffer(sampleBuffer)
            //            ,
            //                sceneStabilityAchieved(pixelBuffer) == true
                return
        }
        
        self.performanceHUD.start()
        
        let exifOrientation = exifOrientationFromDeviceOrientation()
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: exifOrientation, options: [:])
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }

    }
    
    
    public func exifOrientationFromDeviceOrientation() -> CGImagePropertyOrientation {
        let curDeviceOrientation = UIDevice.current.orientation
        let exifOrientation: CGImagePropertyOrientation
        
        switch curDeviceOrientation {
        case UIDeviceOrientation.portraitUpsideDown:  // Device oriented vertically, home button on the top
            exifOrientation = .left
        case UIDeviceOrientation.landscapeLeft:       // Device oriented horizontally, home button on the right
            exifOrientation = .upMirrored
        case UIDeviceOrientation.landscapeRight:      // Device oriented horizontally, home button on the left
            exifOrientation = .down
        case UIDeviceOrientation.portrait:            // Device oriented vertically, home button on the bottom
            exifOrientation = .up
        default:
            exifOrientation = .up
        }
        return exifOrientation
    }

}
