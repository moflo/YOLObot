//
//  CameraController.swift
//  yologle
//
//  Created by d. nye on 5/6/19.
//  Copyright © 2019 Mobile Flow LLC. All rights reserved.
//

import UIKit
import AVFoundation
import Vision
import CoreVideo

public protocol CameraControllerDelegate: class {
    func videoCapture(_ capture: CameraController, sampleBuffer: CVPixelBuffer?, timestamp: CMTime)
    
    func videoDidStablize(_ isStable:Bool)
}

public class CameraController: NSObject  {
    public var previewLayer: AVCaptureVideoPreviewLayer? = nil
    public weak var delegate: CameraControllerDelegate?
    public var fps = 15
    public var bufferSize: CGSize = .zero
    
    var rootLayer: CALayer! = nil

    var lastTimestamp = CMTime()    

    private let session = AVCaptureSession()
    private let videoDataOutput = AVCaptureVideoDataOutput()
    
    private let videoDataOutputQueue = DispatchQueue(label: "VideoDataOutput", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    
    public func setupAVCapture(sessionPreset: AVCaptureSession.Preset = .vga640x480,
                      completion: @escaping (Bool) -> Void) {
        
        self.setupCamera(sessionPreset: sessionPreset, completion: { success in
            completion(success)
        })
        
    }
    
    func setupCamera(sessionPreset: AVCaptureSession.Preset, completion: @escaping (_ success: Bool) -> Void) {
        // Select a video device, make an input
        guard let videoDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices.first else {
            print("Could not find valid video for the session")
            completion(false)
            return
        }
        
        var deviceInput: AVCaptureDeviceInput!
        
        do {
            deviceInput = try AVCaptureDeviceInput(device: videoDevice)
        } catch {
            print("Could not create video device input: \(error)")
            completion(false)
            return
        }
        
        session.beginConfiguration()
        session.sessionPreset = sessionPreset // Model image size is smaller, use .vga640x480
        
        // Add a video input
        guard session.canAddInput(deviceInput) else {
            print("Could not add video device input to the session")
            session.commitConfiguration()
            completion(false)
            return
        }
        
        session.addInput(deviceInput)
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
            // Add a video data output
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
            videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
            videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
            videoDataOutput.connection(with: AVMediaType.video)?.videoOrientation = .portrait
        } else {
            print("Could not add video data output to the session")
            session.commitConfiguration()
            completion(false)
            return
        }
        let captureConnection = videoDataOutput.connection(with: .video)
        // Always process the frames
        captureConnection?.isEnabled = true
        do {
            try  videoDevice.lockForConfiguration()
            let dimensions = CMVideoFormatDescriptionGetDimensions((videoDevice.activeFormat.formatDescription))
            bufferSize.width = CGFloat(dimensions.width)
            bufferSize.height = CGFloat(dimensions.height)
            videoDevice.unlockForConfiguration()
        } catch {
            completion(false)
            print(error)
        }
        session.commitConfiguration()
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer?.connection?.videoOrientation = .portrait
        
////        rootLayer = previewView.layer
//        previewLayer.frame = rootLayer.bounds
//        rootLayer.addSublayer(previewLayer)
        
        completion(true)
    }
    
    func startCaptureSession() {
        session.startRunning()
    }
    
    func stopCaptureSession() {
        session.stopRunning()
    }
    
    // Clean up capture setup
    func teardownAVCapture() {
        previewLayer?.removeFromSuperlayer()
        previewLayer = nil
    }
    
    
    // MARK: - SceneStability Check
    
    // Stability check
    private let sequenceRequestHandler = VNSequenceRequestHandler()
    private let maximumHistoryLength = 15
    private var transpositionHistoryPoints: [CGPoint] = [ ]
    private var previousPixelBuffer: CVPixelBuffer?
    
    public func resetTranspositionHistory() {
        transpositionHistoryPoints.removeAll()
    }

    public func getCurrentPixelBuffer() -> CVPixelBuffer? {
        return previousPixelBuffer
    }

    func sceneStabilityAchieved(_ pixelBuffer: CVImageBuffer) -> Bool {
        guard previousPixelBuffer != nil else {
            previousPixelBuffer = pixelBuffer
            self.resetTranspositionHistory()
            self.delegate?.videoDidStablize(false)
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
                self.delegate?.videoDidStablize(true)
                return true
            }
        }
        self.delegate?.videoDidStablize(false)
        return false
    }
    
    fileprivate func recordTransposition(_ point: CGPoint) {
        transpositionHistoryPoints.append(point)
        
        if transpositionHistoryPoints.count > maximumHistoryLength {
            transpositionHistoryPoints.removeFirst()
        }
    }
    
}

extension CameraController : AVCaptureVideoDataOutputSampleBufferDelegate {
    
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        
        // Check for stability
        if imageBuffer != nil {
            _ = self.sceneStabilityAchieved(imageBuffer!)
        }
        
        // Because lowering the capture device's FPS looks ugly in the preview,
        // we capture at full speed but only call the delegate at its desired
        // framerate.
        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        let deltaTime = timestamp - lastTimestamp
        if deltaTime >= CMTimeMake(value: 1, timescale: Int32(fps)) {
            lastTimestamp = timestamp
            delegate?.videoCapture(self, sampleBuffer: imageBuffer, timestamp: timestamp)
        }
    }
    
    public func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        //print("dropped frame")
    }
}

