//
//  ActionManager.swift
//  yologle
//
//  Created by d. nye on 5/12/19.
//  Copyright © 2019 Mobile Flow LLC. All rights reserved.
//

import UIKit
import MessageUI
import ContactsUI


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

    var recentAction :MFActionType? = nil
    var recentActionText :String? = nil

    func estimateAction(text: String?, objectLabel: String?) -> (type:MFActionType, prompt:String) {
        

        let phone = containsPhone(text: text)
        if phone.valid {
            recentAction = .phone
            recentActionText = phone.number
            return (.phone, phone.number)
        }

        let map = containsAddress(text: text)
        if map.valid {
            recentAction = .map
            recentActionText = map.address
            return (.map, map.address)
        }

        let email = containsEmail(text: text)
        if email.valid {
            recentAction = .email
            recentActionText = email.address
            return (.email, email.address)
        }

        // Default value
        recentAction = .meishi
        recentActionText = text
        return (.meishi, text ?? "Unknown")
        
    }
    
    // http://userguide.icu-project.org/strings/regexp
    // https://nshipster.com/swift-regular-expressions/
    
    private func containsPhone(text: String?) -> (valid :Bool, number:String) {
        guard let text = text else { return (false,"") }
        
        
        let componentArray = ["area", "region", "local"]
        
        let pattern = """
        (?xi)\\(*
        (?<area>
            [0-9]+
        )\\)*(\\h | \\. | -)
        (?<region>
            [0-9]+
        )(\\h | \\. | -)
        (?<local>
            [0-9]+
        )
        """
        
        var phone = [String:String]()
        
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let nsrange = NSRange(text.startIndex..<text.endIndex,
                                  in: text)
            if let match = regex.firstMatch(in: text,
                                            options: [],
                                            range: nsrange)
            {
                for component in componentArray {
                    let nsrange = match.range(withName: component)
                    if nsrange.location != NSNotFound,
                        let range = Range(nsrange, in: text)
                    {
//                        print("\(component): \(text[range])")
                        phone[component] = String(text[range])
                    }
                }
            }
            
        }
        
        if phone.count == 0 {
            return (false,"")
        }
        
        let phone_string :String? = componentArray.map{ phone[$0] ?? "" }.joined(separator: "-")
        
        return (true,"1-\(phone_string ?? "")")
        
    }

    
    private func containsEmail(text: String?) -> (valid :Bool, address:String) {
        guard let text = text else { return (false,"") }
        
        
        let componentArray = ["name", "company", "tld"]
        
        let pattern = """
        (?xi)
        (?<name>
            [[a-z][\\w][\\.][0-9]]+
        )@
        (?<company>
            [[a-z][\\w][-][0-9]]+
        )\\.
        (?<tld>
            COM | CO | ORG | CA | EDU | CN | DE | NET | UK | INFO | NL | EU
        )
        """
        
        var result = [String:String]()
        
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let nsrange = NSRange(text.startIndex..<text.endIndex,
                                  in: text)
            if let match = regex.firstMatch(in: text,
                                            options: [],
                                            range: nsrange)
            {
                for component in componentArray {
                    let nsrange = match.range(withName: component)
                    if nsrange.location != NSNotFound,
                        let range = Range(nsrange, in: text)
                    {
                        //                        print("\(component): \(text[range])")
                        result[component] = String(text[range])
                    }
                }
            }
            
        }
        
        if result.count == 0 {
            return (false,"")
        }
        
        let result_string = "\(result["name"] ?? "email")@\(result["company"] ?? "address").\(result["tld"] ?? "com")"
        
        return (true,result_string )
        
    }

    private func containsAddress(text: String?) -> (valid :Bool, address:String) {
        guard let text = text else { return (false,"") }
        
        
        let componentArray = ["street", "street2", "town", "state", "zip"]
        
        let pattern = """
        (?xi)
        (?<street>
            .*
        )\\R
        (?<street2>
            .*
        )\\R
        (?<town>
            [[a-z][A-Z][\\h]]+
        )\\h
        (?<state>
            AZ | HI | CA | MO
        )\\h
        (?<zip>
            [0-9]+
        )
        """
        
        var address = [String:String]()
        
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let nsrange = NSRange(text.startIndex..<text.endIndex,
                                  in: text)
            if let match = regex.firstMatch(in: text,
                                            options: [],
                                            range: nsrange)
            {
                for component in componentArray {
                    let nsrange = match.range(withName: component)
                    if nsrange.location != NSNotFound,
                        let range = Range(nsrange, in: text)
                    {
//                        print("\(component): \(text[range])")
                        address[component] = String(text[range])
                    }
                }
            }
            
        }

        if address.count == 0 {
            return (false,"")
        }
        
        let address_string :String? = componentArray.map{ address[$0] ?? "" }.joined(separator: " ")
        
        return (true,"\(address_string ?? " ")")

    }
    
    func URLEncodedString(_ string: String) -> String? {
        let customAllowedSet =  CharacterSet.urlQueryAllowed
        let escapedString = string.addingPercentEncoding(withAllowedCharacters: customAllowedSet)
        return escapedString
    }

    var senderViewController :UIViewController? = nil

    public func performAction(_ vc: UIViewController) {
        guard let action = recentAction, let actionText = recentActionText else { return }
        
        self.senderViewController = vc
        
        if action == .phone {
            let url = URL(string: "tel://\(actionText)")
            let options :[UIApplication.OpenExternalURLOptionsKey : Any] = [:]
            UIApplication.shared.open(url!,options:options,completionHandler: { done in
                print("URL open :", done)
            })
        }
        
        if action == .map {
        
            let address = URLEncodedString(actionText) ?? "cupertino,ca"
            UIApplication.shared.open(URL(string:"http://maps.apple.com/?address=\(address)")!)

        }
        
        if action == .email {
            
            let emailTitle = "YOLObot Email"
            let message_text = "Sending YOLObot email message...\n\n"
            let email = actionText
            let toRecipents = [email]
            
            if let mc = MFMailComposeViewController() as MFMailComposeViewController? {
                mc.mailComposeDelegate = self
                mc.setSubject(emailTitle)
                
                mc.setMessageBody(message_text, isHTML: false)
                mc.setToRecipients(toRecipents)
                
                vc.present(mc, animated: true, completion: nil)
            }

        }
        
        if action == .meishi {
            let contact = CNMutableContact()
            contact.note = actionText
            let cvc = CNContactViewController(forNewContact: contact)
            cvc.delegate = self
            let nav = UINavigationController(rootViewController: cvc)
            vc.present(nav, animated: true, completion: nil)

        }
    }
    
}

extension ActionManager : MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result.rawValue {
        case MFMailComposeResult.cancelled.rawValue:
            print("Mail cancelled")
        case MFMailComposeResult.saved.rawValue:
            print("Mail saved")
        case MFMailComposeResult.sent.rawValue:
            print("Mail sent")
        case MFMailComposeResult.failed.rawValue:
            print("Mail sent failure: \(error!.localizedDescription)")
        default:
            break
        }
        senderViewController?.dismiss(animated: false, completion: nil)
    }

}

extension ActionManager : CNContactViewControllerDelegate {
    
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
//        print("ContactViewController done")
        viewController.dismiss(animated: false, completion: nil)

    }
}
