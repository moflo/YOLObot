//
//  MFColors.swift
//  feedthebot
//
//  Created by d. nye on 4/11/19.
//  Copyright © 2019 Mobile Flow LLC. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    convenience init(r: Int, g: Int, b: Int, a: Float) {
        let floatRed = CGFloat(r) / 255.0
        let floatGreen = CGFloat(g) / 255.0
        let floatBlue = CGFloat(b) / 255.0
        self.init(red: floatRed, green: floatGreen, blue: floatBlue, alpha: CGFloat(a))
    }
    // UIColor(hex:0xFF8C00)
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hex & 0xFF00) >> 8) / 255.0
        let blue = CGFloat((hex & 0xFF)) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    
}

func MFBlue(_ alpha :CGFloat = 1.0) -> UIColor {
    let c = UIColor(hex:0x2096FF)
    if alpha == 1.0 { return c }
    return c.withAlphaComponent(alpha)
}

func MFRed(_ alpha :CGFloat = 1.0) -> UIColor {
    let c = UIColor(hex:0xE31153)
    if alpha == 1.0 { return c }
    return c.withAlphaComponent(alpha)
}

func MFGreen(_ alpha :CGFloat = 1.0) -> UIColor {
    let c = UIColor(hex:0x7ED321)
    if alpha == 1.0 { return c }
    return c.withAlphaComponent(alpha)
}

func MFPurple(_ alpha :CGFloat = 1.0) -> UIColor {
    let c = UIColor(hex:0x99056B)
    if alpha == 1.0 { return c }
    return c.withAlphaComponent(alpha)
}

func MFDarkBlue(_ alpha :CGFloat = 1.0) -> UIColor {
    let c = UIColor(hex:0x1C276E)
    if alpha == 1.0 { return c }
    return c.withAlphaComponent(alpha)
}

func MFYellow(_ alpha :CGFloat = 1.0) -> UIColor {
    let c = UIColor(hex:0xF7BA0A)
    if alpha == 1.0 { return c }
    return c.withAlphaComponent(alpha)
}


// Gradient 0x70CDF4 - 0xCDE7F2
func MFBlueStart(_ alpha :CGFloat = 1.0) -> UIColor {
    let c = UIColor(hex:0x70CDF4)
    if alpha == 1.0 { return c }
    return c.withAlphaComponent(alpha)
}

func MFBlueEnd(_ alpha :CGFloat = 1.0) -> UIColor {
    let c = UIColor(hex:0xCDE7F2)
    if alpha == 1.0 { return c }
    return c.withAlphaComponent(alpha)
}

// MARK: - MFAlert colors
func MFAlertBlue(_ alpha :CGFloat = 1.0) -> UIColor {
    let c = UIColor(hex:0x0078ff)
    if alpha == 1.0 { return c }
    return c.withAlphaComponent(alpha)
}

func MFAlertGrayFill(_ alpha :CGFloat = 1.0) -> UIColor {
    let c = UIColor(hex:0xe5e5e5)
    if alpha == 1.0 { return c }
    return c.withAlphaComponent(alpha)
}

