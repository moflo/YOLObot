//
//  DataSetManager.swift
//  feedthebot
//
//  Created by d. nye on 4/12/19.
//  Copyright © 2019 Mobile Flow LLC. All rights reserved.
//

import UIKit
//import Firebase
//import FirebaseFirestore

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
    var responseCount :Int = 0
    var updatedAt :Date = Date()
    
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
    
    func postTraining(_ data:MFDataSet?, duration: Int, categoryArray: [String]?) {
        guard data != nil, categoryArray != nil else { return }
        
    }
}

