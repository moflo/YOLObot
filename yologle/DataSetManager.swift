//
//  DataSetManager.swift
//  feedthebot
//
//  Created by d. nye on 4/12/19.
//  Copyright © 2019 Mobile Flow LLC. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

struct MFResponse  {
    var user_id :String = UUID().uuidString
    var dataset_id :String = UUID().uuidString
    var trainingType :String
    
    var categoryArray :[String] = [String]()                            // For multiple choice category
    var boundingArray :[String:[Float]] = [String:[Float]]()            // For category bounding boxes
    var catPolyArray: [ [String:[Float]] ] = [ [String:[Float]] ]()     // For category polygons
    
    var duration :Int = 0   // Time (seconds) to complete response

    var updatedAt :Date = Date()

    var dictionary: [String: Any] {
        return [
            "user_id": self.user_id,
            "training_type": self.trainingType,
            "category_array": self.categoryArray,
            "bounding_array": self.boundingArray,
            "cat_poly_array": self.catPolyArray,
            "updatedAt": Date() // Timestamp()
        ]
    }

    init() {
        self.trainingType = "Text"
    }

    init(datasetID: String, trainingType: String, duration :Int, categoryArray :[String]) {
        self.init()
        self.dataset_id = datasetID
        self.trainingType = trainingType
        self.duration = duration
        self.categoryArray = categoryArray
    }
    
    init(datasetID: String, trainingType: String, duration :Int, boundingArray :[String:[Float]]) {
        self.init()
        self.dataset_id = datasetID
        self.trainingType = trainingType
        self.duration = duration
        self.boundingArray = boundingArray
    }
    
    init(datasetID: String, trainingType: String, duration :Int, catPolyArray :[[String:[Float]]]) {
        self.init()
        self.dataset_id = datasetID
        self.trainingType = trainingType
        self.duration = duration
        self.catPolyArray = catPolyArray
    }
    

    
}

enum MFTrainingType :String {
    case textOCR = "textOCR"
    case textSentiment = "textSentiment"
    case imageCategory = "imageCategory"
    case imageBBox = "imageBBox"
    case imageBBoxCategory = "imageBBoxCategory"
    case imagePolygon = "imagePolygon"
    case other = ""
    
    func detail() -> String {
        switch self {
        case .textOCR : return "Text Recognition"
        case .textSentiment : return "Text Sentiment"
        case .imageCategory : return "Image Category"
        case .imageBBox : return "Image Bounding Box"
        case .imageBBoxCategory : return "Image Bounding Categories"
        case .imagePolygon : return "Image Polygon"
        default : return "Training"
        }
    }
    
    func iconName() -> String {
        switch self {
        case .textOCR : return "icon_text"
        case .textSentiment : return "icon_text"
        case .imageCategory : return "icon_classify"
        case .imageBBox : return "icon_bounding"
        case .imageBBoxCategory : return "icon_classify"
        case .imagePolygon : return "icon_polygon"
        default : return "icon_text"
        }
    }
}

class MFDataSet {
    var uuid :String = UUID().uuidString
    var order_id :String
    var points :Int = 0
    var multiplier :Float = 1.0
    var trainingType :String
    var training_type :MFTrainingType
    var instruction :String = "Tap on the image once to start drawing a rectangle. Tap again to finish."
    var eventCount :Int = 10
    var limitSeconds :Int = 60*2
    var dataURLArray :[String] = [String]()
    var categoryArray :[String] = [String]()
    var responseArray :[MFResponse] = [MFResponse]()
    var polyArray :[BoundingBoxPoly] = [BoundingBoxPoly]()
    var responseCount :Int = 0
    var updatedAt :Date = Date()
    
    var currentImage: UIImage? = nil
    
    var dictionary: [String: Any] {
        return [
            "uuid": self.uuid,
            "order_id": self.order_id,
            "points": self.points,
            "multiplier": self.multiplier,
            "training_type": self.trainingType,
            "instruction": self.instruction,
            "eventCount": self.eventCount,
            "limitSeconds": self.limitSeconds,
            "dataURLArray": self.dataURLArray,
            "categoryArray": self.categoryArray,
//            "responseArray": self.responseArray,
            "responseCount": self.responseCount,
            "updatedAt": Date()     // Timestamp()
        ]
    }
    
    init() {
        self.uuid = ""; self.order_id = ""; self.trainingType = "textOCR"; self.training_type = .textOCR
    }
    
    convenience init(order_id: String, trainingType: String) {
        self.init()
        self.order_id = order_id
        self.trainingType = trainingType
        self.training_type = MFTrainingType(rawValue: trainingType) ?? .textOCR
    }
    
    convenience init(categoryArray: [String]) {
        self.init()
        self.categoryArray = categoryArray
    }
//    convenience init?(snapshot: DocumentSnapshot) {
//        guard let dict = snapshot.data() else { return nil }
//        self.init(dictionary: dict)
//        self.uuid = snapshot.documentID
//    }

    convenience init?(dictionary: [String: Any] ) {
        guard let dict = dictionary as [String: Any]? else { return nil }
        guard let order_id = dict["order_id"] as? String else { return nil }
        guard let training_type = dict["training_type"] as? String else { return nil }
        
        self.init(order_id: order_id, trainingType: training_type)
        
        if let points = dict["points"] as? Int { self.points = points }
        if let multiplier = dict["multiplier"] as? Double { self.multiplier = Float(multiplier) }
        if let eventCount = dict["eventCount"] as? Int { self.eventCount = eventCount }
        if let limitSeconds = dict["limitSeconds"] as? Int { self.limitSeconds = limitSeconds }
        if let responseCount = dict["responseCount"] as? Int { self.responseCount = responseCount }
        if let instruction = dict["instruction"] as? String { self.instruction = instruction }

        if let dataURLArray = dict["dataURLArray"] as? [String] {
            dataURLArray.forEach { self.dataURLArray.append($0) }
        }
        if let categoryArray = dict["categoryArray"] as? [String] {
            categoryArray.forEach { self.categoryArray.append($0) }
        }
        
        if let timestamp = dict["updatedAt"] as? Date {  //Timestamp {
            self.updatedAt = timestamp  //.dateValue()
        }
        
    }
    
    func getImage() -> UIImage {
        let imageName = self.training_type.iconName()
        return UIImage(named: imageName)!
    }
}


class DataSetManager : NSObject {
    static let sharedInstance = DataSetManager()


    
    // MARK: - Server Methods
    
    func postTraining(_ data:MFDataSet?, completionHandler: @escaping (String?, Error?) -> (), progressHandler: @escaping (Float, String) -> ()) {
        guard data != nil, data?.currentImage != nil else {
            progressHandler(0,"No image found!")
            let err = NSError.init(domain: "PostData", code: 0, userInfo: nil)
            completionHandler(nil,err)
            return
        }
        
        progressHandler(5,"Starting…")
        
        let image = data?.currentImage
        var category_string = "Other"
        if let catArray = data?.categoryArray, catArray.count > 0  {
            category_string = catArray[0]
        }
        
        self.uploadUserImage(image, completionHandler: { (image_url, error) in
            guard image_url != nil, error == nil  else {
                progressHandler(0,"Problem saving the image.")
                completionHandler(image_url,error)
                return
            }
            
            // Save feedback dataset
            var poly_array = "[]"
            let encoder = JSONEncoder()
            if let data = try? encoder.encode(data!.polyArray) {
                poly_array = String(data: data, encoding: .utf8)!
            }

            let feedback = [
                "image_url": image_url!,
                "user_id": UserManager.sharedInstance.getUUID(),
                "category": category_string,
                "poly": poly_array,
                "createdAt": Timestamp()
                ] as [String : Any]
            
            // Update Firebase user details
            let db = Firestore.firestore()
            db.collection("feedback").document().setData(feedback, merge: true) { err in
                guard err == nil  else {
                    print("Error writing feedback: \(err!)")
                    progressHandler(100,"Problem saving the data.")
                    completionHandler(nil,err)
                    return
                }
                
                progressHandler(100,"Thank you. We have saved your feedback.")
                completionHandler(image_url,err)

            }

        }, progressHandler: progressHandler)
        
    }
    
    func uploadUserImage(_ userImageImage:UIImage?, completionHandler: @escaping (String?, Error?) -> (), progressHandler: @escaping (Float, String) -> () ) {
        // Method to update the current user's information
        
        guard
            let user = Auth.auth().currentUser,
            userImageImage != nil,
            let imageData = userImageImage!.pngData()
            else {
                
                completionHandler(nil,NSError(domain: "Upload user image", code: -110, userInfo: nil))
                return
        }
        
        let storage = Storage.storage().reference()
        let uuid = UUID().uuidString
        let userImageRef = storage.child("userImage/\(user.uid)/\(uuid)/image.png")
        
        progressHandler(15,"Uploading…")
        
        // Upload the file to with proper metadata
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"
        
        let uploadTask = userImageRef.putData(imageData, metadata: metadata) { metadata, error in
            guard error == nil else {
                // Uh-oh, an error occurred!
                progressHandler(1.0, "Error")
                completionHandler(nil,error)
                return
            }
            
            // Metadata contains file metadata such as size, content-type, and download URL.
            userImageRef.downloadURL { (url, error) in
                guard let userImageURL = url else {
                    progressHandler(1.0, "Error.")
                    completionHandler(nil,error)
                    return
                }
                let imageURL_string = userImageURL.absoluteString
                
                
                // Update imageURL
                progressHandler(1.0, "Done.")
                completionHandler(imageURL_string,error)
                
            }
            
        }
        
        // Add observer
        uploadTask.observe(.progress) { snapshot in
            // A progress event occurred
            let progress = snapshot.progress!.fractionCompleted
            let progress_float = Float ( progress )
            progressHandler( progress_float, "Uploading…")
            
        }
        
        // Remove observer
        uploadTask.observe(.success) { snapshot in
            // Remove observers...
            uploadTask.removeAllObservers()
            progressHandler(1.0, "Done.")
            
        }
        
        // Remove observer
        uploadTask.observe(.failure) { snapshot in
            // Remove observers...
            uploadTask.removeAllObservers()
            progressHandler(1.0, "Error.")
            completionHandler(nil,NSError(domain: "Update image task error", code: -1, userInfo: ["message":"Upload error."]))
            
        }
        
    }

}

