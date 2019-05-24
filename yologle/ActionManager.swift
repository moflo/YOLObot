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
    case web = "webSite"
    case text = "text"
    
    func title() -> String {
        switch self {
        case .phone : return "Phone Number"
        case .map : return "Street Address"
        case .email : return "Email Address"
        case .food : return "Food or Meal"
        case .upc : return "Bar Code"
        case .qr : return "QR Code"
        case .meishi : return "Business Card"
        case .web : return "Website"
        case .text : return "text"
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
        case .web : return "Open Website"
        case .text : return "View Text"
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
        case .web : return "Open Website"
        case .text : return "Copy Text"
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

// MARK: - Action Manager

class ActionManager : NSObject {
    static let sharedInstance = ActionManager()

    var recentAction :MFActionType? = nil
    var recentActionText :String? = nil

    // MARK: Estimate Action
    
    func estimateAction(text: String?, objectLabel: String?) -> (type:MFActionType, prompt:String) {
        

        let phone = containsPhone(text: text)
        if phone.valid {
            recentAction = .phone
            recentActionText = phone.number
            return (.phone, phone.number)
        }

        let www = containsWebsite(text: text)
        if www.valid {
            recentAction = .web
            recentActionText = www.url
            return (.web, www.url)
        }

        let email = containsEmail(text: text)
        if email.valid {
            recentAction = .email
            recentActionText = email.address
            return (.email, email.address)
        }

        let map = containsAddress(text: text)
        if map.valid {
            recentAction = .map
            recentActionText = map.address
            return (.map, map.address)
        }
        
        // Default value
        recentAction = .text
        recentActionText = text
        return (.text, text ?? "Unknown")
        
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

    
    private func containsWebsite(text: String?) -> (valid :Bool, url:String) {
        guard let text = text else { return (false,"") }
        
        
        let componentArray = ["http", "company", "tld"]
        
        let pattern = """
        (?xi)
        (?<http>
            [[http][https]]+
        )\\:\\/\\/
        (?<company>
            [[a-z][\\w][-][0-9][\\.]]+
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
        
        let result_string = "\(result["http"] ?? "http"):\\\(result["company"] ?? "address").\(result["tld"] ?? "com")"
        
        return (true,result_string )
        
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
    
    // MARK: Perform Action
    
    func URLEncodedString(_ string: String) -> String? {
        let customAllowedSet =  CharacterSet.urlQueryAllowed
        let escapedString = string.addingPercentEncoding(withAllowedCharacters: customAllowedSet)
        return escapedString
    }

    var senderViewController :UIViewController? = nil

    func doScriptAction(_ shortCutName: String) {
        // shortcuts://x-callback-url/run-shortcut?name=Take%20Picture&id=FC92D7EC-D9C5-490A-949B-3119568EBC75&source=homescreen

        // Save actionText to clipboard
        let pasteboard = UIPasteboard.general
        pasteboard.string = self.recentActionText

        let script = URLEncodedString(shortCutName) ?? "Shorten%20URL"
        UIApplication.shared.open(URL(string:"shortcuts://x-callback-url/run-shortcut?name=\(script)")!)

    }
    
    public func performAction(_ vc: UIViewController) {
        guard let action = recentAction, let actionText = recentActionText else { return }
        
        self.senderViewController = vc

        // Run shortcut for item

        let actions = UserManager.sharedInstance.getUserDefaultActions()
        if let userDefault = actions[action] as MFActionItem? {
            
            if let shortCutName = userDefault.scriptName {
                doScriptAction(shortCutName)
                return
            }
            
        }

        
        if action == .phone {
            let url = URL(string: "tel://\(actionText)")
            let options :[UIApplication.OpenExternalURLOptionsKey : Any] = [:]
            UIApplication.shared.open(url!,options:options,completionHandler: { done in
                print("URL open :", done)
            })
        }

        if action == .web {
            let url = URL(string: actionText)
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
        
        if action == .text {
            let pasteboard = UIPasteboard.general
            pasteboard.string = self.recentActionText

            let alert = UIAlertController(title: "Text Copied",
                                          message: "Text was copied to the clipboard.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {
                (alertAction :UIAlertAction) -> Void in
                // Ready to score...
                print("Cancel")
            }))
            vc.present(alert, animated: true, completion:nil)

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
