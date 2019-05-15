//
//  OverlayYOLOView.swift
//  yologle
//
//  Created by d. nye on 5/14/19.
//  Copyright © 2019 Mobile Flow LLC. All rights reserved.
//

import UIKit
import Vision

class OverlayYOLOView: UIView {
    
    public var observations: [VNRecognizedObjectObservation]? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        ctx.clear(rect);
        guard let observations = observations else { return }
        
        let frameSize = self.bounds.size
        
        for observation in observations {

            // Select only the label with the highest confidence.
            let topLabelObservation = observation.labels[0]

            let objectBounds = VNImageRectForNormalizedRect(observation.boundingBox, Int(frameSize.width), Int(frameSize.height))
            
            self.drawRect(ctx, bounds: objectBounds)
            
            self.drawText(ctx, bounds: objectBounds, identifier: topLabelObservation.identifier, confidence: topLabelObservation.confidence)
        }
    }
    
    private func drawText(_ ctx: CGContext, bounds: CGRect, identifier: String, confidence: Float, color: CGColor = UIColor.red.cgColor) {
        ctx.setStrokeColor(color)
        ctx.setLineWidth(1.0)
        
        let formattedString = NSMutableAttributedString(string: String(format: "\(identifier)\nConfidence:  %.2f", confidence))
        let largeFont = UIFont(name: "Helvetica", size: 24.0)!
        formattedString.addAttributes([NSAttributedString.Key.font: largeFont], range: NSRange(location: 0, length: identifier.count))
        let ident :NSAttributedString = formattedString
        ident.draw(at: CGPoint(x: bounds.midX*0.80, y: bounds.midY))

        ctx.strokePath();
    }
    
    private func drawRect(_ ctx: CGContext, bounds: CGRect, color: CGColor = UIColor.green.cgColor, fill: Bool = false) {
        if fill {
            ctx.setStrokeColor(UIColor.clear.cgColor)
            ctx.setFillColor(color)
            ctx.setLineWidth(0.0)
        } else {
            ctx.setStrokeColor(color)
            ctx.setLineWidth(1.0)
        }
        
        let clipPath = UIBezierPath(roundedRect: bounds, cornerRadius: 6.0).cgPath
        ctx.addPath(clipPath)
        ctx.closePath()
        
        if fill {
            ctx.fillPath()
        } else {
            ctx.strokePath();
        }
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
    

}
