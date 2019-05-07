//
//  AccountViewController.swift
//  oyawatch
//
//  Created by d. nye on 10/21/18.
//  Copyright © 2018 Mobile Flow LLC. All rights reserved.
//

import UIKit
import FirebaseUI
//import StoreKit
//import Purchases
import AVFoundation
//import Kingfisher

class MFImageViewUser : UIImageView {
    // Subclass of UIImageView to add circle mask, simmple shadow
    //    override func awakeFromNib()  {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let radius :CGFloat = 0.5 * self.frame.size.width
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
        self.layer.shadowColor = UIColor.black.cgColor
        
        self.layer.shadowOffset = CGSize(width: 0.0,height: 1.0)
        
        self.layer.shadowOpacity = 0.6
        self.layer.shadowRadius = 0.8
        
        self.image = UIImage(named:"AvatarDefault")
    }
}

class AccountViewController: UIViewController, AVCapturePhotoCaptureDelegate {

    @IBAction func doCancelButton(_ sender: AnyObject) {
        //        self.navigationController?.popViewControllerAnimated(true)
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    @IBOutlet weak var reloadButton: UIBarButtonItem!
    @IBAction func doReloadUser(_ sender: AnyObject) {
        self.reloadButton.isEnabled = false
//        UserManager.sharedInstance.refreshUserData { (error) in
//            DispatchQueue.main.async {
//                self.reloadButton.isEnabled = true
//                let user = UserManager.sharedInstance.getUserDetails()
//                self.accountName.text = "\(user.nickname) (\(user.product))"
//                self.accountType.text = user.email
//                let url: String = user.url
//                if url.count > 0 {
//                    let image = UIImage(named: "icon_user")
//                    self.avatarView.kf.setImage(with: URL(string: url), placeholder: image)
//                }
//            }
//        }
    }
    @IBOutlet weak var avatarView: MFImageViewUser!
    @IBOutlet weak var changeImageButton: UIButton!
    @IBAction func doChangeImageButton(_ sender: AnyObject) {
        // Method to allow user to upload new avatar
        self.doStartCapture()
    }
    
    @IBOutlet weak var accountName: UILabel!
    @IBOutlet weak var accountType: UILabel!
    @IBAction func doRestoreButton(_ sender: Any) {
        let alert = UIAlertController(title: "Restore Purchase", message: "Restore previous purchase for this account?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Restore", style: UIAlertAction.Style.default, handler: {
            (alert :UIAlertAction) -> Void in
//            self.restorePurchases()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    @IBOutlet weak var logoutButton: UIButton!
    @IBAction func doLogout(_ sender: Any) {
        let alert = UIAlertController(title: "Switch Accounts", message: "Sign out and switch accounts", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Sign Out", style: UIAlertAction.Style.default, handler: {
            (alert :UIAlertAction) -> Void in
            self.doLogoutAccount()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    func doLogoutAccount() {
        // Method to log out of previous Firebase account
        self.navigationController?.popViewController(animated: true)
        

    }
    
    @IBOutlet weak var subscriptionView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBAction func doPurchaseButton(_ sender: Any) {

    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.view.backgroundColor = MFHomeBackground()
        
//        let user = UserManager.sharedInstance.getUserDetails()
//        self.accountName.text = "\(user.nickname) (\(user.product))"
//        self.accountType.text = user.email
//        if let url: String = user.url, url.count > 0 {
//            let image = UIImage(named: "icon_user")
//            self.avatarView.kf.setImage(with: URL(string: url), placeholder: image)
//        }

        doShowHideImageControls(false)
        
        let auth = FUIAuth.defaultAuthUI()!
//        Purchases.debugLogsEnabled = true
//        if let user = auth.auth?.currentUser, let userID = user.uid as String? {
//            Purchases.configure(withAPIKey: Defaults.MFRevenueCatID, appUserID: userID)
//        }
//        else {
//            Purchases.configure(withAPIKey: Defaults.MFRevenueCatID)
//        }
//        Purchases.delegate = self
        
        self.subscriptionView.layer.cornerRadius = 4.0
        self.subscriptionView.layer.masksToBounds = true

        self.titleLabel.text = "Monthly Subscription Fee"
        self.priceLabel.text = "$ 4.99 / mo."
        self.descriptionLabel.text = "Monthly subcription to enable advance statistic calculation and reporting features."
        
        displayEntitlements()
        
    }
    
    func displayEntitlements() {
        // Load default pricing
        

    }
    
    // MARK: - Avatar Image Capture method
    
    // MARK: - AVCapture session to take user avatar image
    // http://stackoverflow.com/questions/29930699/avcapture-session-to-capture-image-swift
    // https://github.com/zshannon/ZCSAvatarCapture
    
    var captureSession :AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var captureDevice : AVCaptureDevice?
    
    func doStartCapture() {
        // Start image capture
        self.captureSession = AVCaptureSession()
        self.captureDevice = AVCaptureDevice.default(for: .video)
        if(captureDevice != nil){
            // Start capturing frames...
            DispatchQueue.main.async {
                self.stillImageOutput = AVCapturePhotoOutput()
                self.captureSession.addOutput(self.stillImageOutput)
                
                let err : NSError? = nil
                do {
                    self.captureSession.addInput(try AVCaptureDeviceInput(device: self.captureDevice!))
                }
                catch {
                    print("error: device capture",error.localizedDescription)
//                    DEBUG_CRASH("device_capture", details: error.localizedDescription)
                }
                self.captureSession.sessionPreset = AVCaptureSession.Preset.photo
                if err != nil {
                    print("error: \(String(describing: err?.localizedDescription))")
                }
                let previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
                previewLayer.frame = self.avatarView.layer.bounds
                previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                DispatchQueue.main.async(execute: {
                    self.doShowHideImageControls(true)
                    self.avatarView.layer.addSublayer(previewLayer)
                    self.captureSession.startRunning()
                });
                
            }
        }
    }
    
    @IBOutlet weak var switchButton: UIButton!
    @IBAction func doSwitchButton(_ sender: AnyObject) {
        let backcamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        
        let frontcamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
        
        if self.captureDevice! == backcamera {
            self.captureDevice = frontcamera
        }
        else {
            self.captureDevice = backcamera
        }
        
        self.captureSession.beginConfiguration()
        for camera in self.captureSession.inputs {
            let old_input :AVCaptureInput = camera //as! AVCaptureInput
            self.captureSession.removeInput(old_input)
        }
        self.captureSession.addInput(try! AVCaptureDeviceInput(device: self.captureDevice!))
        self.captureSession.commitConfiguration()
    }
    
    @IBOutlet weak var doneCaptureButton: UIButton!
    @IBAction func doDoneCaptureButton(_ sender: AnyObject) {
        
        let settings = AVCapturePhotoSettings.init(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        settings.isAutoStillImageStabilizationEnabled = true
        settings.isHighResolutionPhotoEnabled = false
        settings.flashMode = .off
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                             kCVPixelBufferWidthKey as String: 64,
                             kCVPixelBufferHeightKey as String: 64]
        settings.previewPhotoFormat = previewFormat
        self.stillImageOutput.capturePhoto(with: settings, delegate: self)
        
        self.doShowHideImageControls(false)
    }
    
    
    func MFScaleUIImage(_ image:UIImage, percent:Float) -> UIImage {
        
        let scale_width :Float = percent * Float(image.size.width)
        let scale_height :Float = percent * Float(image.size.height)
        
        return MFScaleUIImage(image, width: scale_width, height: scale_height)
    }
    
    func MFScaleUIImage(_ image:UIImage, width:Float, height:Float) -> UIImage {
        
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        let size = CGSize(width: CGFloat(width), height: CGFloat(height))
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        image.draw(in: CGRect(origin: CGPoint.zero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage!
        
    }


    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {

        guard let imageData = photo.fileDataRepresentation(), let image = UIImage(data: imageData) else { return }
        
        let scaledImage = MFScaleUIImage(image, width: 64.0, height: 64.0)
        print ("Image size: \(scaledImage.size)")

        DispatchQueue.main.async {
            self.avatarView.image = scaledImage
        }
        
        // Upload new image button
        self.doSaveNewImage()
        
        
        self.captureSession.stopRunning()
        self.captureSession = nil
        self.stillImageOutput = nil
        self.captureDevice = nil
        
    }
    
    func doShowHideImageControls(_ hide:Bool) {
        self.changeImageButton.isHidden = hide
        self.switchButton.isHidden = !hide
        self.doneCaptureButton.isHidden = !hide
    }
    
    func doSaveNewImage() {
        let alert = UIAlertController(title: "Update Info", message: "Save account avatar image?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Save Updates", style: UIAlertAction.Style.default, handler: {
            (alert :UIAlertAction) -> Void in
            self.uploadAvatarImage()
        }))
        self.present(alert, animated: true, completion: nil)

    }
    
    func uploadAvatarImage() {
//                MFProgressHUD.sharedView.wait("Update Account", detail: "Contacting server…")

        
        
    }

}

