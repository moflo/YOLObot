//
//  UserManager.swift
//  feedthebot
//
//  Created by d. nye on 4/11/19.
//  Copyright © 2019 Mobile Flow LLC. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseUI

enum MFActionType :String {
    case phone = "phoneCall"
    case map = "streetAddress"
    case email = "emailAddress"
    case food = "foodItem"
    case upc = "barCode"
    case qr = "QRCode"
    case meishi = "businessCard"
    
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

struct MFActionItem {
    var activity :MFActionType = .phone
    var useDefault :Bool = true
    var scriptName :String = ""

    init() {
    }
    
    init(_ activity :MFActionType) {
        self.init()
        self.activity = activity
    }
}

struct MFUser {
    // User class object
    var uuid :String = UUID().uuidString
    var points :Int = 0
    var lifetimePoints :Int = 0
    var exchangeRate :Float = 0.013      // $0.013 per point
    var name :String
    var email :String
    var provider :String? = nil
    var avatar_url :String
    var fbid :String? = nil
    var defaultActions :[MFActionType:MFActionItem] = [
        .phone      : MFActionItem(.phone),
        .map        : MFActionItem(.map),
        .email      : MFActionItem(.email),
        .food       : MFActionItem(.food),
        .upc        : MFActionItem(.upc),
        .qr         : MFActionItem(.qr),
        .meishi     : MFActionItem(.meishi)
    ]
    var updatedAt :Timestamp = Timestamp()
    
    var dictionary: [String: Any] {
        return [
            "uuid": self.uuid,
            "points": self.points,
            "lifetime_points": self.lifetimePoints,
            "exchange_rate": self.exchangeRate,
            "name": self.name,
            "email": self.email,
            "provider": self.provider ?? "",
            "avatar_url": self.avatar_url,
            "fbid": self.fbid ?? "",
            "updatedAt": Timestamp()
        ]
    }
    
    init() {
        self.name = ""; self.email = ""; self.avatar_url = "";
    }
    
    init(uuid: String, points: Int) {
        self.init()
        self.uuid = uuid
        self.points = points
    }
    
    init(uuid: String, email: String, name: String, avatar: String) {
        self.init()
        self.uuid = uuid
        self.email = email
        self.name = name
        self.avatar_url = avatar
    }

    init?(dictionary: [String: Any] ) {
        guard let dict = dictionary as [String: Any]? else { return nil }
        guard let uuid = dict["uuid"] as? String else { return nil }
        guard let points = dict["points"] as? Int else { return nil }
        
        self.init(uuid: uuid, points: points)
        
        if let lifetimePoints = dict["lifetime_points"] as? Int { self.lifetimePoints = lifetimePoints }
        if let exchangeRate = dict["exchange_rate"] as? Float { self.exchangeRate = exchangeRate }
        if let name = dict["name"] as? String { self.name = name }
        if let email = dict["email"] as? String { self.email = email }
        if let provider = dict["provider"] as? String { self.provider = provider }
        if let avatar_url = dict["avatar_url"] as? String { self.avatar_url = avatar_url }
        if let fbid = dict["fbid"] as? String { self.fbid = fbid }
        
        
        if let timestamp = dict["updatedAt"] as? Timestamp {
            self.updatedAt = timestamp
        }
        
    }
}


class MFActivity {
    var uuid :String = UUID().uuidString
    var user_id :String = UUID().uuidString
    var points :Int = 0
    var trainingType :MFTrainingType
    var wasPaid :Bool = false
    var earnings :Double = 0.0
    var updatedAt :Date = Date()
    
    var dictionary: [String: Any] {
        return [
            "user_id": self.user_id,
            "points": self.points,
            "training_type": self.trainingType.rawValue,
            "was_paid": self.wasPaid,
            "updatedAt": Timestamp()
        ]
    }
    
    init() {
        self.uuid = ""; self.trainingType = .other;
    }
    
    convenience init(type: MFTrainingType, points: Int) {
        self.init()
        let user = UserManager.sharedInstance.getUserDetails()
        self.trainingType = type
        self.user_id = user.uuid
        self.points = points
        self.earnings = Double(points) * user.exchangeRate
    }
    
    convenience init?(snapshot: DocumentSnapshot) {
        guard let dict = snapshot.data() else { return nil }
        self.init(dictionary: dict)
        self.uuid = snapshot.documentID
    }

    convenience init?(dictionary: [String: Any] ) {
        guard let dict = dictionary as [String: Any]? else { return nil }
        guard let training_type = dict["training_type"] as? String else { return nil }
        guard let trainType = MFTrainingType(rawValue: training_type) else { return nil }
        guard let points = dict["points"] as? Int else { return nil }
        
        self.init(type: trainType, points: points)
        
        if let user_id = dict["user_id"] as? String { self.user_id = user_id }
        if let was_paid = dict["was_paid"] as? Bool { self.wasPaid = was_paid }

        if let timestamp = dict["updatedAt"] as? Timestamp {
            self.updatedAt = timestamp.dateValue()
        }
        
    }
    
    func getImage() -> UIImage {
        return UIImage(named: "icon_text")!
    }
}


class UserManager : NSObject {
    static let sharedInstance = UserManager()

    fileprivate var userUUID :String = ""

    fileprivate var userObj = MFUser()

    func getUUID() -> String {
        let auth = FUIAuth.defaultAuthUI()!
        guard let user = auth.auth?.currentUser, let userID = user.uid as String? else {
            return self.userUUID
        }
        
        self.userUUID =  userID
        self.userObj.uuid = userID
        return self.userUUID
    }

    func getUserDetails() -> (uuid: String, points: Int, exchangeRate: Double,name: String, email: String,url:String) {
        let uuid = self.userUUID
        let points = self.userObj.points
        let exchangeRate = self.userObj.exchangeRate
        let email = self.userObj.email
        let name = self.userObj.name
        let url = self.userObj.avatar_url

        return (uuid,points,Double(exchangeRate),name,email,url)
    }

    func getUserDefaultActions() -> [MFActionType:MFActionItem] {
        return self.userObj.defaultActions
    }
    
    func getUserTotalPoints() -> Int {
        return self.userObj.points
    }
    
    func shouldDoubleTapToSelect() -> Bool {
        return true
    }

    // MARK: - Server Methods
    
    func isUserLoggedIn () -> Bool {
        let current_user = Auth.auth().currentUser
        let logged_in = current_user != nil && !current_user!.isAnonymous
        return logged_in
    }

    func doAnonymousLogin() {
        Auth.auth().signInAnonymously() { (authResult, error) in
            // Check anonymous user
            if (error != nil) {
                print("Authentication error:", error!.localizedDescription)
            } else if (authResult != nil) {
                let user = authResult!.user
                let isAnonymous = user.isAnonymous  // true
                let uid = user.uid
                self.userUUID = uid
                
                self.userObj.uuid = uid
                self.userObj.name = user.displayName ?? ""
                self.userObj.email = user.email ?? ""
                self.userObj.avatar_url = user.photoURL != nil ? user.photoURL!.absoluteString : ""

                print("Authenticated anonymous:", uid, isAnonymous)
            }
            else {
                print("Authentication error: authResult nil")
            }
        }

    }
    
    func doAccountLogin( _ email: String, password: String, completionHandler: @escaping (MFUser?, Error?) -> () ) {
//        DEBUG_LOG("login", details: "password")
        
        Auth.auth().signIn(withEmail: email, password: password) { (auth, error) in
            
            guard error == nil else { completionHandler(nil,error); return }
            guard auth != nil, let user = auth?.user else { completionHandler(nil,error); return }

            let uid = user.uid
            self.userUUID = uid
        
            self.userObj.uuid = uid
            self.userObj.name = user.displayName ?? ""
            self.userObj.email = user.email ?? ""
            self.userObj.avatar_url = user.photoURL != nil ? user.photoURL!.absoluteString : ""

            completionHandler(self.userObj,error)
            
                
        }
    }

    func doAccountPasswordReminder(_ email: String, completionHandler: @escaping (Error?) -> () ) {
        // User password reset method
        
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                // An error happened
                completionHandler(error)
                
            } else {
                // Password reset email sent
                completionHandler(nil)
                
            }
        }
        
    }

    func doResetAccount() {
        // Method to log out of previous Firebase account
        let authUI = FUIAuth.defaultAuthUI()
        try! authUI?.signOut()
        
    }

//    func updatePointsTotal(_ points: Int) {
//        let uuid = self.getUUID()
//        let existing_points = self.userObj.points
//
//        // Update Firebase user details
//        let db = Firestore.firestore()
//        db.collection("users").document(uuid).updateData([
//            "points": FieldValue.increment(points)
//            ])
//
//        self.userObj.points = existing_points + points
//    }
    

    func updateUserDetails(uuid: String, points: Int, completionHandler: ((Error?) -> () )! = nil ) {
        
        self.userObj.uuid = uuid
        self.userObj.points = self.userObj.points + points
        self.userObj.lifetimePoints = self.userObj.lifetimePoints + points
        //        self.synchronize()
        
        // Update Firebase user details
        let db = Firestore.firestore()
        db.collection("users").document(uuid).setData(userObj.dictionary, merge: true) { err in
            if let err = err {
                print("Error writing document: \(err)")
                if completionHandler != nil {
                    completionHandler(err)
                }
            } else {
                print("Document successfully written!")
                if completionHandler != nil {
                    completionHandler(nil)
                }
            }
        }
        

    }

    
    func refreshUserData( _ completionHandler: @escaping (Error?) -> () ) {
        let auth = FUIAuth.defaultAuthUI()!
        guard let user = auth.auth?.currentUser, let userID = user.uid as String? else {
            let error = NSError(domain: "Error user ID not set", code: -101, userInfo: nil)
            completionHandler(error)
            return
        }
        
        self.refreshUserData(userID, completionHandler: completionHandler)
    }
    
    func refreshUserData( _ userID: String, completionHandler: @escaping (Error?) -> () ) {

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userID)
        
        userRef.getDocument { (document, error) in
//            print("GetUser: ",document?.data())
            if document?.data() == nil && error == nil { completionHandler(nil) }
            if let user = document.flatMap({
                $0.data().flatMap({ (data) in
                    return MFUser(dictionary: data)
                })
            }) {
                self.userObj = user
                self.userUUID = user.uuid

                completionHandler(nil)
            } else {
                let error = NSError(domain: "Error refreshing users data", code: -102, userInfo: nil)
                completionHandler(error)
            }
        }
        
        
    }
    
}


