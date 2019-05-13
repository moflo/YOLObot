//
//  ActionManager.swift
//  yologle
//
//  Created by d. nye on 5/12/19.
//  Copyright © 2019 Mobile Flow LLC. All rights reserved.
//

import Foundation

enum MFActionType :String, Codable {
    case phone = "phoneCall"
    case map = "streetAddress"
    case email = "emailAddress"
    case food = "foodItem"
    case upc = "barCode"
    case qr = "QRCode"
    case meishi = "businessCard"
    
    func title() -> String {
        switch self {
        case .phone : return "Phone Number"
        case .map : return "Street Address"
        case .email : return "Email Address"
        case .food : return "Food or Meal"
        case .upc : return "Bar Code"
        case .qr : return "QR Code"
        case .meishi : return "Business Card"
        }
    }
    
    func defaultAction() -> String {
        switch self {
        case .phone : return "Phone Call"
        case .map : return "Open Maps"
        case .email : return "Send Email"
        case .food : return "Lookup Calories"
        case .upc : return "Lookup Bar Code"
        case .qr : return "Scan QRCode"
        case .meishi : return "Import Biz Card"
        }
    }
    
    func payloadInfo() -> String {
        switch self {
        case .phone : return "Phone number to call"
        case .map : return "Street address infomation"
        case .email : return "Email address"
        case .food : return "Food item information"
        case .upc : return "UPC Code details"
        case .qr : return "QR Code details"
        case .meishi : return "Contact information"
        }
    }
}

struct MFActionItem : Codable {
    var activity :MFActionType = .phone
    var useDefault :Bool = true
    var scriptName :String? = nil
    
    init() {
    }
    
    init(_ activity :MFActionType) {
        self.init()
        self.activity = activity
    }
    
    func actionTitle() -> String {
        return self.useDefault ? activity.defaultAction() : "Shortcut '\(self.scriptName ?? "")'"
        
    }
}

class ActionManager : NSObject {
    static let sharedInstance = ActionManager()


}

