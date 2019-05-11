//
//  yologleTests.swift
//  yologleTests
//
//  Created by d. nye on 5/6/19.
//  Copyright © 2019 Mobile Flow LLC. All rights reserved.
//

import XCTest
@testable import yologle
import Nimble
import Firebase

class yologleTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testMFUser() {
        
        var data1 = MFUser(uuid: "UUID1", points: 101)
        let updated = Date.init(timeIntervalSinceNow: -60*60*60*2)
        data1.updatedAt = Timestamp(date: updated)
        
        expect(data1).notTo(beNil())
        expect(data1.uuid) == "UUID1"
        expect(data1.points) == 101
        expect(data1.exchangeRate) == 0.013
        expect(data1.lifetimePoints) == 0
        
        expect(data1.name).notTo(beNil())
        expect(data1.email).notTo(beNil())
        expect(data1.avatar_url).notTo(beNil())
        
//        print("Dictionary: ",data1.dictionary)
        
        let data2 = MFUser(dictionary: data1.dictionary)
        
        expect(data2).notTo(beNil())
        expect(data2?.uuid) == data1.uuid
        expect(data2?.points) == data1.points
        expect(data2?.exchangeRate) == data1.exchangeRate
        expect(data2?.lifetimePoints) == data1.lifetimePoints
        //        expect(data2?.updatedAt) == Timestamp(date:Date())
        
        let data3 = MFUser(dictionary: ["nada":"nada"])
        
        expect(data3).to(beNil())
        
        let dict: [String:Any] = [
            "uuid": "TEST1",
            "email": "EMAIL",
            "name": "NAME",
            "avatar_url": "URL",
            "points": 102,
            "lifetime_points": 102,
            "exchange_rate": Float(10.0),
            "action_json" :
            "[\"emailAddress\",{\"activity\":\"emailAddress\",\"useDefault\":false,\"scriptName\":\"EMAIL\"},\"foodItem\",{\"activity\":\"foodItem\",\"useDefault\":true}]",
            "updatedAt": Timestamp()
        ]
        
        let data4 = MFUser(dictionary: dict)
        
        expect(data4).notTo(beNil())
        if (data4 != nil ) {
            expect(data4!).notTo(beNil())
            expect(data4!.uuid) == "TEST1"
            expect(data4!.points) == 102
            expect(data4!.exchangeRate) == 10.0
            expect(data4!.lifetimePoints) == 102
            
            expect(data4!.name).notTo(beNil())
            expect(data4!.name) == "NAME"
            expect(data4!.email).notTo(beNil())
            expect(data4!.email) == "EMAIL"
            expect(data4!.avatar_url).notTo(beNil())
            expect(data4!.avatar_url) == "URL"
            
            expect(data4!.defaultActions[.email]?.scriptName) == "EMAIL"

        }
        
    }
    
    
    func testMFUserArchive() {
        
        let dict: [String:Any] = [
            "uuid": "TEST1",
            "email": "EMAIL",
            "name": "NAME",
            "avatar_url": "URL",
            "points": 102,
            "lifetime_points": 102,
            "exchange_rate": Float(10.0),
            "updatedAt": Timestamp()
        ]
        
        let data1 = MFUser(dictionary: dict)
        data1?.defaultActions[.phone]?.scriptName = "PHONE"
        data1?.defaultActions[.map]?.scriptName = "MAP"
        data1?.defaultActions[.email]?.scriptName = "EMAIL"
        data1?.defaultActions[.upc]?.scriptName = "UPC"
        data1?.defaultActions[.qr]?.scriptName = "QR"
        data1?.defaultActions[.food]?.scriptName = "FOOD"
        data1?.defaultActions[.meishi]?.scriptName = "MEISHI"

        /*
         // NOTE: conditional testing function on UserManager needs to be uncommented
         
        UserManager.sharedInstance.testing(testUser: data1!)
        
        UserManager.sharedInstance.synchronize()
        
        UserManager.sharedInstance.loadDefaults()

        let user = UserManager.sharedInstance.testingGetUser()
        
        expect(user.uuid) == user.uuid
        expect(user.uuid) == "TEST1"
        expect(user.points) == 102
        expect(user.exchangeRate) == 10.0
        expect(user.lifetimePoints) == 102

        expect(user.defaultActions[.phone]?.scriptName) == "PHONE"
        expect(user.defaultActions[.map]?.scriptName) == "MAP"
        expect(user.defaultActions[.email]?.scriptName) == "EMAIL"
        expect(user.defaultActions[.upc]?.scriptName) == "UPC"
        expect(user.defaultActions[.qr]?.scriptName) == "QR"
        expect(user.defaultActions[.food]?.scriptName) == "FOOD"
        expect(user.defaultActions[.meishi]?.scriptName) == "MEISHI"

        */
    }
    

    func testMFActivity() {
        
        let activity = MFActionItem()
        
        let encoder = JSONEncoder()
        let data = try! encoder.encode(activity)
        let str = String(data: data, encoding: .utf8)!

        print("Encode: ",str)
        
        let decoder = JSONDecoder()
        let data2 = str.data(using: .utf8)
        let result = try! decoder.decode(MFActionItem.self, from: data2!)

        print("Decode: ",result)
    }
    
    func testMFActivity2() {
        
        let activity = MFActionItem()
        let array :[MFActionType:MFActionItem] = [
            .food : activity
        ]
        
        
        let encoder = JSONEncoder()
        let data = try! encoder.encode(array)
        let str = String(data: data, encoding: .utf8)!
        
        print("Encode: ",str)
        
        let decoder = JSONDecoder()
        let data2 = str.data(using: .utf8)
        let result = try! decoder.decode([MFActionType:MFActionItem].self, from: data2!)
        
        print("Decode: ",result)
    }

    func testServerDataSetLoad() {
        
        let expectation1 = XCTestExpectation(description: "Load Datasets, error")
        
        let dataSet = MFDataSet()
        dataSet.currentImage = UIImage(named: "bot_small_white")
        
        DataSetManager.sharedInstance.postTraining(dataSet, completionHandler: { (url, error) in

            expect(url).notTo(beNil())
            expect(error).to(beNil())
            
            expectation1.fulfill()

        }, progressHandler: { (progress, msg) in
            print(progress,msg)
            
        })
        
        wait(for: [expectation1], timeout: 10.0)
        
        
        
    }

}
