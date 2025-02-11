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
    
    func testBoundBoxPoly() {
        
        var boxPoly = BoundingBoxPoly()
        boxPoly.category = .block
        boxPoly.points = [CGPoint(x: 1, y: 2)]
        
        let encoder = JSONEncoder()
        let data = try! encoder.encode(boxPoly)
        let str = String(data: data, encoding: .utf8)!
        
        print("Encode: ",str)

        let decoder = JSONDecoder()
        let data2 = str.data(using: .utf8)
        let result = try! decoder.decode(BoundingBoxPoly.self, from: data2!)
        
        print("Decode: ",result)
        
        expect(result.category) == .block
        expect(result.points).notTo(beNil())
        expect(result.points!.count) == 1
        expect(result.points![0].x) == 1.0
        expect(result.points![0].y) == 2.0

        var boxPoly2 = BoundingBoxPoly()
        boxPoly2.category = .goal
        boxPoly2.points = [CGPoint(x: 3, y: 4)]

        let polyArray = [boxPoly,boxPoly2]
        let data3 = try! encoder.encode(polyArray)
        let str3 = String(data: data3, encoding: .utf8)!

        print("Encode: ",str3)

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
        var boxPoly = BoundingBoxPoly()
        boxPoly.category = .block
        boxPoly.points = [CGPoint(x: 1, y: 2)]
        dataSet.polyArray.append(boxPoly)
        
        DataSetManager.sharedInstance.postTraining(dataSet, completionHandler: { (url, error) in

            expect(url).notTo(beNil())
            expect(error).to(beNil())
            
            expectation1.fulfill()

        }, progressHandler: { (progress, msg) in
            print(progress,msg)
            
        })
        
        wait(for: [expectation1], timeout: 10.0)
        
        
        
    }

    func testActionManager() {
        
        // Phone number testing
        
        let a1 = ActionManager.sharedInstance.estimateAction(text: "100 202 1234", objectLabel: nil)
        
        expect(a1.type) == .phone
        expect(a1.prompt) == "1-100-202-1234"
        
        let a2 = ActionManager.sharedInstance.estimateAction(text: "(100 202 1234", objectLabel: nil)
        
        expect(a2.type) == .phone
        expect(a2.prompt) == "1-100-202-1234"

        let a3 = ActionManager.sharedInstance.estimateAction(text: "(100) 202 1234", objectLabel: nil)
        
        expect(a3.type) == .phone
        expect(a3.prompt) == "1-100-202-1234"

        let a4 = ActionManager.sharedInstance.estimateAction(text: "100-202-1234", objectLabel: nil)
        
        expect(a4.type) == .phone
        expect(a4.prompt) == "1-100-202-1234"

        let a5 = ActionManager.sharedInstance.estimateAction(text: "100.202.1234", objectLabel: nil)
        
        expect(a5.type) == .phone
        expect(a5.prompt) == "1-100-202-1234"
        
        let a6 = ActionManager.sharedInstance.estimateAction(text: "100  202  1234", objectLabel: nil)
        
        expect(a6.type) == .phone
        expect(a6.prompt) == "1-100-202-1234"

        let a7 = ActionManager.sharedInstance.estimateAction(text: "  100  202  1234", objectLabel: nil)
        
        expect(a7.type) == .phone
        expect(a7.prompt) == "1-100-202-1234"

        
        // Address testing
        
        let text1 = """
        123 Main St.\n \
        P.O. Box 101 \n \
        Anytown Again ca 90010
        """

        let a8 = ActionManager.sharedInstance.estimateAction(text: text1, objectLabel: nil)
        
        expect(a8.type) == .map
        expect(a8.prompt) == "123 Main St.  P.O. Box 101   Anytown Again ca 90010"

        
        // Email testing
        
        let e1 = ActionManager.sharedInstance.estimateAction(text: "test@testing.com", objectLabel: nil)
        
        expect(e1.type) == .email
        expect(e1.prompt) == "test@testing.com"
        
        
        let emails = ["test@testing.com","test2@testing2.co","test@testing.co",
                      "TEST@test.org","test.one@testing.com","test.two@test-one.com"]
        
        for email in emails {
            let e = ActionManager.sharedInstance.estimateAction(text: email, objectLabel: nil)
            
            if e.type != .email {
                print("Error: ",email)
                abort()
            }
            
            expect(e.type) == .email
            expect(e.prompt) == email

            print(e.prompt)
        }
        
        
        // Web testing
        
        let w1 = ActionManager.sharedInstance.estimateAction(text: "www.testing.com", objectLabel: nil)
        
        expect(w1.type) == .web
        expect(w1.prompt) == "http://www.testing.com"
        
        
        let websites = ["www.testing.com","testing.com","info.testing.com","TESTING.COM"]
        
        for web in websites {
            let w = ActionManager.sharedInstance.estimateAction(text: web, objectLabel: nil)
            
            if w.type != .web {
                print("Error: ",web, w.type)
                abort()
            }
            
            expect(w.type) == .web
            expect(w.prompt) == "http://" + web
            
            print(w.prompt)
            
        }


    }
}
