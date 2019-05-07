//
//  MFButtons.swift
//  feedthebot
//
//  Created by d. nye on 4/11/19.
//  Copyright © 2019 Mobile Flow LLC. All rights reserved.
//

import Foundation
import UIKit


// MARK: - MFRoundedButton

class MFRoundedButton : UIButton {
    
    var borderWidth : CGFloat! = 1.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    var insetWidth : CGFloat! = 2.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.awakeFromNib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.awakeFromNib()
    }
    
    
    override func awakeFromNib()
    {
        self.setTitleColor(UIColor.black, for: UIControl.State())
        self.setTitleColor(UIColor.black, for: .highlighted)
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        self.borderWidth = 2
        self.insetWidth = self.borderWidth! * 2.5
        self.layer.contentsScale = UIScreen.main.scale
    }
    
    override func draw(_ rect :CGRect) {
        let ctx = UIGraphicsGetCurrentContext() //as CGContextRef
        
        var strokeColor = UIColor.black.cgColor
        var fillColor = UIColor.black.cgColor
        
        if (self.tag == 0) {
            // Default behavior
            
            switch self.state {
            case UIControl.State():
                strokeColor = (self.titleColor(for: UIControl.State()) != nil) ? self.titleColor(for: UIControl.State())!.cgColor : UIColor.blue.cgColor
                fillColor = (self.titleColor(for: UIControl.State()) != nil) ? self.titleColor(for: UIControl.State())!.cgColor : UIColor.blue.cgColor
                
            case UIControl.State.selected:
                strokeColor = (self.titleColor(for: UIControl.State()) != nil) ? self.titleColor(for: UIControl.State())!.cgColor : UIColor.blue.cgColor
                fillColor = (self.titleColor(for: UIControl.State()) != nil) ? self.titleColor(for: UIControl.State())!.cgColor : UIColor.blue.cgColor
                
            case UIControl.State.disabled:
                strokeColor = (self.titleColor(for: UIControl.State()) != nil) ? self.titleColor(for: UIControl.State())!.cgColor : UIColor.blue.cgColor
                fillColor = (self.titleColor(for: UIControl.State()) != nil) ? self.titleColor(for: UIControl.State())!.cgColor : UIColor.blue.cgColor
                
            default:
                strokeColor = (self.titleColor(for: UIControl.State()) != nil) ? self.titleColor(for: UIControl.State())!.cgColor : UIColor.blue.cgColor
                fillColor = UIColor.clear.cgColor
                
            }
        }
        
        if (self.tag == 100) {
            // Green button, no border
            self.insetWidth = 0.0
            self.setTitleColor(.black, for: UIControl.State())
            self.setTitleColor(.black, for: .highlighted)
            self.setTitleColor(.black, for: .disabled)
            self.titleLabel?.font = UIFont.systemFont(ofSize: 22)
            
            switch (self.state) {
            case UIControl.State.highlighted:
                strokeColor = MFGreen().cgColor
                fillColor = MFGreen().cgColor
                
            case UIControl.State.selected:
                strokeColor = MFGreen().cgColor
                fillColor = MFGreen().cgColor
                
            case UIControl.State.disabled:
                strokeColor = MFGreen().cgColor
                fillColor = UIColor.clear.cgColor
                self.insetWidth = self.borderWidth * 2.5
                
            default:
                strokeColor = MFGreen().cgColor
                fillColor = MFGreen().cgColor
            }
            
            
        }
        
        if (self.tag == 101) {
            // Black button, no border
            self.insetWidth = 0.0
            self.setTitleColor(UIColor.white, for: UIControl.State())
            self.setTitleColor(UIColor.black, for: .highlighted)
            self.titleLabel?.font = UIFont.systemFont(ofSize: 22)
            
            switch (self.state) {
            case UIControl.State.highlighted:
                strokeColor = MFBlue().cgColor
                fillColor = MFBlue().cgColor
            case UIControl.State.selected:
                strokeColor = MFBlue().cgColor
                fillColor = MFBlue().cgColor
            case UIControl.State.disabled:
                strokeColor = MFBlue().cgColor
                fillColor = UIColor.clear.cgColor
                self.insetWidth = self.borderWidth * 2.5
            default:
                strokeColor = MFBlue().cgColor
                fillColor = MFBlue().cgColor
            }
            
        }
        
        if (self.tag == 102) {
            // Orange button, no border, smaller text, green text when selected
            self.setTitleColor(UIColor.white, for: UIControl.State())
            self.setTitleColor(UIColor.white, for: .highlighted)
            self.setTitleColor(MFRed(), for: .disabled)
            self.titleLabel?.font = UIFont.systemFont(ofSize: 22)
            
            switch (self.state) {
            case UIControl.State.highlighted:
                strokeColor = MFRed().cgColor
                fillColor = MFRed().cgColor
            case UIControl.State.selected:
                strokeColor = MFRed().cgColor
                fillColor = MFRed().cgColor
            case UIControl.State.disabled:
                strokeColor = MFRed().cgColor
                fillColor = MFRed().cgColor
                self.insetWidth = self.borderWidth * 2.5
            default:
                strokeColor = MFRed().cgColor
                fillColor = MFRed().cgColor
            }
            
            
        }
        
        if (self.tag == 103) {
            // Orange button, no border, smaller text, green text when selected
            self.setTitleColor(.white, for: UIControl.State())
            self.setTitleColor(.white, for: .highlighted)
            self.setTitleColor(.white, for: .disabled)
            self.titleLabel?.font = UIFont.systemFont(ofSize: 22)
            
            switch (self.state) {
            case UIControl.State.highlighted:
                strokeColor = UIColor.gray.cgColor
                fillColor = UIColor.gray.cgColor
            case UIControl.State.selected:
                strokeColor = UIColor.gray.cgColor
                fillColor = UIColor.gray.cgColor
            case UIControl.State.disabled:
                strokeColor = UIColor.lightGray.cgColor
                fillColor = UIColor.black.cgColor
                self.insetWidth = self.borderWidth * 2.5
            default:
                strokeColor = UIColor.white.cgColor
                fillColor = UIColor.white.cgColor
            }
            
            
        }
        
        
        ctx?.setFillColor(fillColor)
        ctx?.setStrokeColor(strokeColor)
        ctx?.saveGState()
        
        ctx?.setLineWidth(self.borderWidth)
        
        if (self.tag == 0 || self.tag == 103) {
            // Default style is to draw an outline, highlight is filled rounded rect
            let outlinePath = UIBezierPath(roundedRect: self.bounds.insetBy(dx: self.borderWidth, dy: self.borderWidth), cornerRadius: (self.bounds.height-2)/2)
            
            ctx?.addPath(outlinePath.cgPath)
            ctx?.strokePath()
            
            ctx?.restoreGState()
            
            if (self.isHighlighted || self.isSelected) {
                ctx?.saveGState()
                let fillPath = UIBezierPath(roundedRect:self.bounds.insetBy(dx: self.insetWidth, dy: self.insetWidth), cornerRadius:self.bounds.height/2)
                
                ctx?.addPath(fillPath.cgPath)
                ctx?.fillPath()
                
                ctx?.restoreGState()
            }
        }
        
        if (self.tag == 100 || self.tag == 101 || self.tag == 102) {
            // Draw filled rounded rect, outline when highlighted
            
            let outlinePath = UIBezierPath(roundedRect: self.bounds.insetBy(dx: self.borderWidth, dy: self.borderWidth), cornerRadius: (self.bounds.height-2)/2)
            
            ctx?.addPath(outlinePath.cgPath)
            ctx?.strokePath()
            
            ctx?.restoreGState()
            
            if (!self.isHighlighted && !self.isSelected) {
                ctx?.saveGState()
                let fillPath = UIBezierPath(roundedRect:self.bounds.insetBy(dx: self.insetWidth, dy: self.insetWidth), cornerRadius:self.bounds.height/2)
                
                ctx?.addPath(fillPath.cgPath)
                ctx?.fillPath()
                
                ctx?.restoreGState()
            }
        }
        
        if(self.isHighlighted) {
            self.imageView?.tintColor = self.titleColor(for: UIControl.State.highlighted)
        }
        else if(self.isSelected) {
            self.imageView?.tintColor = self.titleColor(for: UIControl.State.selected)
        }
        else {
            self.imageView?.tintColor = self.titleColor(for: UIControl.State())
            
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setNeedsDisplay()
    }
    
    override var isHighlighted: Bool {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override var isSelected: Bool {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
}

// MARK: - MFRectIconButton

class MFRectIconButton : UIButton {
    
    var borderWidth : CGFloat! = 1.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    var insetWidth : CGFloat! = 2.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    var cornerRadius : CGFloat! = 16.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    var fontSize : CGFloat! = 22.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    func configure(_ title:String, icon:String, tag:Int) {
        self.setTitle(title, for: .normal)
        self.setTitle(title, for: .highlighted)
        self.setImage(UIImage(named: icon), for: .normal)
        self.setImage(UIImage(named: icon), for: .highlighted)
        self.tag = tag
        self.setNeedsDisplay()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.awakeFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.awakeFromNib()
    }
    
    
    override func awakeFromNib()
    {
        self.setTitleColor(UIColor.black, for: UIControl.State())
        self.setTitleColor(UIColor.black, for: .highlighted)
        
        self.imageView?.contentMode = .scaleAspectFit
        self.contentMode = .center
        
        self.borderWidth = 2
        self.insetWidth = self.borderWidth! * 2.5
        self.layer.contentsScale = UIScreen.main.scale
        
        // Arrange icon & text
        
    }
    
    override func draw(_ rect :CGRect) {
        let ctx = UIGraphicsGetCurrentContext() //as CGContextRef
        
        var strokeColor = UIColor.black.cgColor
        var fillColor = UIColor.black.cgColor
        
        if (self.tag == 0) {
            // Default behavior
            
            switch self.state {
            case UIControl.State():
                strokeColor = (self.titleColor(for: UIControl.State()) != nil) ? self.titleColor(for: UIControl.State())!.cgColor : UIColor.blue.cgColor
                fillColor = (self.titleColor(for: UIControl.State()) != nil) ? self.titleColor(for: UIControl.State())!.cgColor : UIColor.blue.cgColor
                
            case UIControl.State.selected:
                strokeColor = (self.titleColor(for: UIControl.State()) != nil) ? self.titleColor(for: UIControl.State())!.cgColor : UIColor.blue.cgColor
                fillColor = (self.titleColor(for: UIControl.State()) != nil) ? self.titleColor(for: UIControl.State())!.cgColor : UIColor.blue.cgColor
                
            case UIControl.State.disabled:
                strokeColor = (self.titleColor(for: UIControl.State()) != nil) ? self.titleColor(for: UIControl.State())!.cgColor : UIColor.blue.cgColor
                fillColor = (self.titleColor(for: UIControl.State()) != nil) ? self.titleColor(for: UIControl.State())!.cgColor : UIColor.blue.cgColor
                
            default:
                strokeColor = (self.titleColor(for: UIControl.State()) != nil) ? self.titleColor(for: UIControl.State())!.cgColor : UIColor.blue.cgColor
                fillColor = UIColor.clear.cgColor
                
            }
        }
        
        if (self.tag == 100) {
            // Green button, no border
            self.insetWidth = 0.0
            self.setTitleColor(.black, for: UIControl.State())
            self.setTitleColor(.black, for: .highlighted)
            self.setTitleColor(.black, for: .disabled)
            self.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
            
            switch (self.state) {
            case UIControl.State.highlighted:
                strokeColor = MFGreen().cgColor
                fillColor = MFGreen().cgColor
                
            case UIControl.State.selected:
                strokeColor = MFGreen().cgColor
                fillColor = MFGreen().cgColor
                
            case UIControl.State.disabled:
                strokeColor = MFGreen().cgColor
                fillColor = UIColor.clear.cgColor
                self.insetWidth = self.borderWidth * 2.5
                
            default:
                strokeColor = MFGreen().cgColor
                fillColor = MFGreen().cgColor
            }
            
            
        }
        
        if (self.tag == 101) {
            // Black button, no border
            self.insetWidth = 0.0
            self.setTitleColor(UIColor.white, for: UIControl.State())
            self.setTitleColor(UIColor.black, for: .highlighted)
            self.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
            
            switch (self.state) {
            case UIControl.State.highlighted:
                strokeColor = MFBlue().cgColor
                fillColor = MFBlue().cgColor
            case UIControl.State.selected:
                strokeColor = MFBlue().cgColor
                fillColor = MFBlue().cgColor
            case UIControl.State.disabled:
                strokeColor = MFBlue().cgColor
                fillColor = UIColor.clear.cgColor
                self.insetWidth = self.borderWidth * 2.5
            default:
                strokeColor = MFBlue().cgColor
                fillColor = MFBlue().cgColor
            }
            
        }
        
        if (self.tag == 102) {
            // Orange button, no border, smaller text, green text when selected
            self.setTitleColor(UIColor.white, for: UIControl.State())
            self.setTitleColor(UIColor.white, for: .highlighted)
            self.setTitleColor(MFRed(), for: .disabled)
            self.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
            
            switch (self.state) {
            case UIControl.State.highlighted:
                strokeColor = MFRed().cgColor
                fillColor = MFRed().cgColor
            case UIControl.State.selected:
                strokeColor = MFRed().cgColor
                fillColor = MFRed().cgColor
            case UIControl.State.disabled:
                strokeColor = MFRed().cgColor
                fillColor = MFRed().cgColor
                self.insetWidth = self.borderWidth * 2.5
            default:
                strokeColor = MFRed().cgColor
                fillColor = MFRed().cgColor
            }
            
            
        }
        
        if (self.tag == 103) {
            // Orange button, no border, smaller text, green text when selected
            self.setTitleColor(.white, for: UIControl.State())
            self.setTitleColor(.white, for: .highlighted)
            self.setTitleColor(.white, for: .disabled)
            self.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
            
            switch (self.state) {
            case UIControl.State.highlighted:
                strokeColor = UIColor.gray.cgColor
                fillColor = UIColor.gray.cgColor
            case UIControl.State.selected:
                strokeColor = UIColor.gray.cgColor
                fillColor = UIColor.gray.cgColor
            case UIControl.State.disabled:
                strokeColor = UIColor.lightGray.cgColor
                fillColor = UIColor.black.cgColor
                self.insetWidth = self.borderWidth * 2.5
            default:
                strokeColor = UIColor.white.cgColor
                fillColor = UIColor.white.cgColor
            }
            
            
        }
        
        
        ctx?.setFillColor(fillColor)
        ctx?.setStrokeColor(strokeColor)
        ctx?.saveGState()
        
        ctx?.setLineWidth(self.borderWidth)
        
        if (self.tag == 0 || self.tag == 103) {
            // Default style is to draw an outline, highlight is filled rounded rect
            let outlinePath = UIBezierPath(roundedRect: self.bounds.insetBy(dx: self.borderWidth, dy: self.borderWidth), cornerRadius: cornerRadius)
            
            ctx?.addPath(outlinePath.cgPath)
            ctx?.strokePath()
            
            ctx?.restoreGState()
            
            if (self.isHighlighted || self.isSelected) {
                ctx?.saveGState()
                let fillPath = UIBezierPath(roundedRect:self.bounds.insetBy(dx: self.insetWidth, dy: self.insetWidth), cornerRadius:cornerRadius)
                
                ctx?.addPath(fillPath.cgPath)
                ctx?.fillPath()
                
                ctx?.restoreGState()
            }
        }
        
        if (self.tag == 100 || self.tag == 101 || self.tag == 102) {
            // Draw filled rounded rect, outline when highlighted
            
            let outlinePath = UIBezierPath(roundedRect: self.bounds.insetBy(dx: self.borderWidth, dy: self.borderWidth), cornerRadius: cornerRadius)
            
            ctx?.addPath(outlinePath.cgPath)
            ctx?.strokePath()
            
            ctx?.restoreGState()
            
            if (!self.isHighlighted && !self.isSelected) {
                ctx?.saveGState()
                let fillPath = UIBezierPath(roundedRect:self.bounds.insetBy(dx: self.insetWidth, dy: self.insetWidth), cornerRadius:cornerRadius)
                
                ctx?.addPath(fillPath.cgPath)
                ctx?.fillPath()
                
                ctx?.restoreGState()
            }
        }
        
        if(self.isHighlighted) {
            self.imageView?.tintColor = self.titleColor(for: UIControl.State.highlighted)
        }
        else if(self.isSelected) {
            self.imageView?.tintColor = self.titleColor(for: UIControl.State.selected)
        }
        else {
            self.imageView?.tintColor = self.titleColor(for: UIControl.State())
            
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setNeedsDisplay()
    }
    
    override var isHighlighted: Bool {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override var isSelected: Bool {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
}

// MARK: - MFAlertButton

class MFAlertButton : UIButton {
    // UIButton subclass to mimic the UIAlert button
    
    var borderWidth : CGFloat! = 0.5
    var insetWidth : CGFloat! = 0.5
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    func initialize()
    {
        self.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 15.0)
        self.setTitleColor(.white, for: .normal)
        self.setTitleColor(.darkGray, for: .highlighted)
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        self.layer.contentsScale = UIScreen.main.scale
        self.backgroundColor = MFGreen()
    }
    
    fileprivate var borderLayer: CAShapeLayer?
    fileprivate func layoutOutlineLayer() {
        if let existingLayer = borderLayer {
            existingLayer.removeFromSuperlayer()
        }
        let outlineShape = CAShapeLayer()
        let w = self.frame.size.width
        let h = CGFloat(0.1)
        let frame = CGRect(x: 0.0, y: 0.0, width: w, height: h)
        outlineShape.frame = frame
        outlineShape.path = UIBezierPath(roundedRect: frame, cornerRadius: 0.0).cgPath
        outlineShape.fillColor = MFGreen().cgColor
        outlineShape.strokeColor = UIColor.lightGray.cgColor
        outlineShape.lineWidth = 0.5
        self.layer.insertSublayer(outlineShape, at: 0)
        self.borderLayer = outlineShape
    }
    
    override func draw(_ rect :CGRect) {
        let ctx = UIGraphicsGetCurrentContext() //as CGContextRef
        
        let strokeColor = UIColor.clear.cgColor
        let fillColor = MFGreen().cgColor
        
        
        ctx?.setFillColor(fillColor)
        ctx?.setStrokeColor(strokeColor)
        ctx?.saveGState()
        
        //        CGContextSetLineWidth(ctx, self.borderWidth)
        //
        ////        let outlinePath = UIBezierPath(roundedRect: CGRectInset(self.bounds, self.borderWidth, self.borderWidth), cornerRadius: 0.0)
        //
        //        CGContextAddPath(ctx, outlinePath.CGPath)
        //        CGContextStrokePath(ctx)
        //
        //        CGContextRestoreGState(ctx)
        
        if (self.isHighlighted || self.isSelected) {
            ctx?.saveGState()
            let fillPath = UIBezierPath(roundedRect:self.bounds.insetBy(dx: self.insetWidth, dy: self.insetWidth), cornerRadius:0.0)
            
            ctx?.addPath(fillPath.cgPath)
            ctx?.fillPath()
            
            ctx?.restoreGState()
        }
        
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutOutlineLayer()
        self.setNeedsDisplay()
    }
    
    override var isHighlighted: Bool {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override var isSelected: Bool {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    
}

// MARK: - MFTrainButton

enum MFTrainButtonType {
    case Orange
    case DarkBlue
}

class MFTrainButton {
    
    var completionHandler:((AnyObject)->Void)!
    
    var title: String!
    var icon_name :String!
    var category :BoundingBoxShotType = .mark
    
    init() {
        title = "Text"
        icon_name = "icon_text"
        completionHandler = nil
    }
    
    convenience init(title: String, icon: String) {
        self.init()
        self.title = title
        self.icon_name = icon
    }

    convenience init(title: String, icon: String, category: BoundingBoxShotType) {
        self.init()
        self.title = title
        self.icon_name = icon
        self.category = category
    }

}

class MFTrainingButtonView : UIView, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var collectionView :UICollectionView!
    
    var menuButtons :[MFTrainButton]? = nil {
        didSet {
            self.awakeFromNib()
        }
    }
    
    var menuType :MFTrainButtonType = .Orange {
        didSet {
            self.awakeFromNib()
        }
    }
    
    override init(frame :CGRect)  {
        // Initialize the UIView
        super.init(frame : frame)
        
        self.awakeFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.awakeFromNib()
    }
    
    override func awakeFromNib() {
        self.initialize()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.initialize()
        self.setNeedsDisplay()
    }
    
    func initialize() {
        //        print(self.bounds)
        
        self.backgroundColor = .clear
        
        // Add UICollectionView
        if self.collectionView != nil {
            self.collectionView.removeFromSuperview()
            self.collectionView = nil
        }
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        
        let rect       = self.bounds    // CGRect(x: 25.0, y: 85.0, width: self.bounds.width-50.0, height: 28.0 * 5)
        let width      = rect.width
        let height     = rect.height
        
        var itemWidth  = floor(width / 2)
        var itemHeight = floor(height / 2)
        
        if menuType == .DarkBlue {
            itemWidth = floor(width / 2)
            itemHeight = floor(height / 3)
        }
        
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        layout.scrollDirection = .horizontal
        
        if menuType == .DarkBlue {
            layout.scrollDirection = .vertical
        }
        
        self.collectionView = UICollectionView(frame: rect, collectionViewLayout: layout)
        self.collectionView.backgroundColor = .clear
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.allowsSelection = true
        self.collectionView.allowsMultipleSelection = false
        self.collectionView.register(MFTrainButtonCell.self, forCellWithReuseIdentifier: "MFTrainButtonCell")
        self.addSubview(self.collectionView)
        
        
        collectionView.contentOffset.x = bounds.width * 1.1
        
    }
    
    func reset() {
        // Scroll view into first posotion
        
        collectionView.setContentOffset(CGPoint(x:0,y:0), animated: true)
        
        if let paths = collectionView.indexPathsForSelectedItems {
            for indexPath in paths {
                if let cell = collectionView.cellForItem(at: indexPath) {
                    cell.isSelected = false
                }
            }
        }
        
    }
    // UICollectionCell
    
    class MFTrainButtonCell: UICollectionViewCell {
        var title: UILabel!
        var icon: UIImageView!
        var btn: UIView!
        var enabled: Bool = true
        var buttonType :MFTrainButtonType = .Orange
        var buttonColor: UIColor = MFDarkBlue()
        var textColor: UIColor = .white
        
        override func prepareForReuse() {
            super.prepareForReuse()
            //            print("Cell prepare for reuse")
            
            title.text = ""
            title.textColor = UIColor.white
            icon.image = nil    // UIImage(named: "square_goal")
            self.contentView.backgroundColor = .green
        }
        
        func initialize() {
            //            print("Cell initialize: ",buttonType)
            
            self.isSelected = false
            
        }
        
        func configure(_ menuType: MFTrainButtonType, category: BoundingBoxShotType = .none) {
            buttonType = menuType
            buttonColor = UIColor(cgColor: category.fillColor())
            
//            print("Cell configure: ",buttonType)
            
            if buttonType == .Orange {
            let iconSize = CGFloat(64)
            
            btn = UIView(frame: CGRect(x: 0, y: 0, width: bounds.width*0.9, height: bounds.height*0.9))
            btn.backgroundColor = .green
            
            let radius :CGFloat = 0.25 * btn.frame.size.height
            btn.layer.cornerRadius = radius
            //            btn.layer.masksToBounds = true
            btn.layer.shadowColor = UIColor.darkGray.cgColor
            
            btn.layer.shadowOffset = CGSize(width: 0.0,height: 3.0)
            
            btn.layer.shadowOpacity = 0.4
            btn.layer.shadowRadius = 3.0
            
            btn.center = self.contentView.center
            self.contentView.addSubview(btn)
            
            icon = UIImageView(frame: CGRect(x: iconSize*0.25, y: 0, width: iconSize, height: iconSize))
            //            icon.center = CGPoint(x: bounds.midX, y: bounds.midY - 12)
            icon.image = UIImage(named: "square_goal")
            btn.addSubview(icon)
            
            let fontSize = CGFloat(18.0)
            title = UILabel(frame: CGRect(x: 0, y: 0, width: btn.bounds.width, height: fontSize*1.2))
            title.textAlignment = .left
            title.numberOfLines = 1
            title.translatesAutoresizingMaskIntoConstraints = false
            title.font = UIFont(name: "HelveticaNeue", size: fontSize)
            title.textColor = .blue
            btn.addSubview(title)
            
            // Auto layout
            icon.translatesAutoresizingMaskIntoConstraints = false
            title.translatesAutoresizingMaskIntoConstraints = false
            
            let views = [ "icon" : icon,  "title": title ] as [String : Any]
            
            icon.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            title.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            
            let constHbody = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(>=5)-[icon(\(iconSize))]-(>=5)-|", options: .alignAllCenterY, metrics: nil, views: views)
            self.addConstraints(constHbody)
            
            let constV = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(8)-[icon(\(iconSize))]-(16)-[title(\(fontSize*1.2))]-(>=15)-|", options: .alignAllCenterX, metrics: nil, views: views)
            self.addConstraints(constV)
            
            // Add border
            //            self.layoutBorderLayer()
            }
            
            if buttonType == .DarkBlue {
                
                let iconSize = CGFloat(22)
                
                btn = UIView(frame: CGRect(x: 0, y: 0, width: bounds.width*0.9, height: 44))
                btn.backgroundColor = self.buttonColor
                
                let radius :CGFloat = 0.25 * btn.frame.size.height
                btn.layer.cornerRadius = radius
                //            btn.layer.masksToBounds = true
                btn.layer.shadowColor = UIColor.darkGray.cgColor
                
                btn.layer.shadowOffset = CGSize(width: 0.0,height: 3.0)
                
                btn.layer.shadowOpacity = 0.4
                btn.layer.shadowRadius = 3.0
                
                btn.center = self.contentView.center
                self.contentView.addSubview(btn)
                
                icon = UIImageView(frame: CGRect(x: iconSize*0.25, y: 0, width: iconSize, height: iconSize))
                //            icon.center = CGPoint(x: bounds.midX, y: bounds.midY - 12)
                icon.image = UIImage(named: "square_goal")
                btn.addSubview(icon)
                
                let fontSize = CGFloat(12.0)
                title = UILabel(frame: CGRect(x: iconSize*1.5, y: 0, width: btn.bounds.width, height: fontSize*1.2))
                title.textAlignment = .left
                title.numberOfLines = 1
                title.translatesAutoresizingMaskIntoConstraints = false
                title.font = UIFont(name: "HelveticaNeue", size: fontSize)
                title.textColor = self.textColor
                btn.addSubview(title)
                
                // Auto layout
                icon.translatesAutoresizingMaskIntoConstraints = false
                title.translatesAutoresizingMaskIntoConstraints = false
                
                let views = [ "icon" : icon,  "title": title ] as [String : Any]
                
                icon.centerYAnchor.constraint(equalTo: btn.centerYAnchor).isActive = true
                title.centerYAnchor.constraint(equalTo: btn.centerYAnchor).isActive = true
                
                let constVbody = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(>=5)-[icon(\(iconSize))]-(>=5)-|", options: .alignAllCenterX, metrics: nil, views: views)
                btn.addConstraints(constVbody)
                
                let constH = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(8)-[icon(\(iconSize))]-(8)-[title]-(>=4)-|", options: .alignAllCenterY, metrics: nil, views: views)
                btn.addConstraints(constH)

            }
            
        }
        
        override var isSelected : Bool {
            didSet {

                if buttonType == .Orange {
                    self.title?.textColor = isSelected ? UIColor.darkGray : UIColor.blue
                }
                if buttonType == .DarkBlue {
                    self.title?.textColor = isSelected ? MFGreen() : UIColor.white
                }
            }
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            initialize()
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            
            initialize()
        }
        
        var borderLayer: CALayer?
        func layoutBorderLayer() {
            if let existingLayer = borderLayer {
                existingLayer.removeFromSuperlayer()
            }
            let border = CAShapeLayer()
            border.contentsScale = UIScreen.main.scale
            
            //        border.frame = bounds
            border.path = UIBezierPath(rect: bounds).cgPath
            border.lineWidth = 0.5
            border.fillColor = UIColor.clear.cgColor
            border.strokeColor = UIColor.darkGray.cgColor
            
            self.layer.insertSublayer(border, at: 1)
            self.borderLayer = border
            
        }
        
    }
    
    
    // UICollection View Methods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.menuButtons?.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MFTrainButtonCell", for: indexPath) as! MFTrainButtonCell
        self.configureCell(cell, atIndexPath: indexPath)

        
        return cell
    }
    
    func configureCell(_ cell: MFTrainButtonCell, atIndexPath indexPath: IndexPath) {

        let item = (indexPath as NSIndexPath).item
        if let button = menuButtons?[item] {
            let category = self.menuType == .DarkBlue ? button.category : .none
            cell.configure(self.menuType, category: category)
            
            cell.title?.text = button.title
            cell.icon?.image = UIImage(named: button.icon_name)
        }
        else {
            cell.configure(self.menuType)
            
            cell.title.text = "Test Button"
            cell.icon.image = UIImage(named: "square_goal")
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let cell = self.collectionView(collectionView, cellForItemAt: indexPath) as! MFTrainButtonCell
        
        if cell.enabled {
            collectionView.selectItem(at: indexPath, animated:true, scrollPosition:.top)
        }
        //        else {
        //            self.selectDate(self.selectedDate)
        //        }
        
        return cell.enabled
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = self.collectionView(collectionView, cellForItemAt: indexPath) as! MFTrainButtonCell
        
        if cell.enabled {
            
            let item = (indexPath as NSIndexPath).item
            if let button = menuButtons?[item] {
                if (button.completionHandler != nil) { button.completionHandler(self) }
            }
            else {
                print(item)
                
            }
            
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = self.collectionView(collectionView, cellForItemAt: indexPath) as! MFTrainButtonCell
        
        if cell.enabled {
            
            let item = (indexPath as NSIndexPath).item
            
            print(item)
        }
        
    }
    
    
    
    
}


// MARK: - Device Types

enum UIUserInterfaceIdiom : Int
{
    case unspecified
    case phone
    case pad
}

struct ScreenSize
{
    static let SCREEN_WIDTH         = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

struct DeviceType
{
    static let IS_IPHONE_4_OR_LESS  = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let IS_IPHONE_5          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6P         = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
    static let IS_IPAD              = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1024.0
}
