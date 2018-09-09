//
//  NutritionixAPI.swift
//  SugarCube
//
//  Created by Jesse Friedman on 9/8/18.
//  Copyright © 2018 Jesse Friedman. All rights reserved.
//

import Foundation
import StitchCore
import libbson

enum MessageParsingError: Error {
    case missingData
    case noFoodsFound
}

/*struct NutritionixFood: Document {
    var food_name: String
    
    var nf_sugars: Float
    var nf_sodium: Float
}*/

class NutritionixAPI {
    static var stitchClient = Stitch.defaultAppClient!
    
    static func getNutritionData(upc: String, testMode: Bool = false, callback: @escaping (_ err: Error?, _ data: Document?) -> ()) {
        print("is logged in: " + String(stitchClient.auth.isLoggedIn))
        if stitchClient.auth.isLoggedIn {
            requestNutritionData(upc: upc, testMode: testMode) { (error, data) in
                if error != nil {
                    callback(error, nil)
                } else {
                    callback(nil, data)
                }
            }
        } else {
            stitchClient.auth.login(withCredential: AnonymousCredential()) { result in
                switch result {
                case .success(let user):
                    print("logged in anonymous as user \(user.id)")
                    requestNutritionData(upc: upc, testMode: testMode) { (error, data) in
                        if error != nil {
                            callback(error, nil)
                        } else {
                            callback(nil, data)
                        }
                    }
                case .failure(let error):
                    print("Failed to log in: \(error)")
                    callback(error, nil)
                }
            }
        }
    }
    
    static private func requestNutritionData(upc: String, testMode: Bool = false, callback: @escaping (_ err: Error?, _ result: Document?) -> ()) {
        stitchClient.callFunction(
            withName: "proxyNutritionix", withArgs: [upc, testMode], withRequestTimeout: 5.0
        ) { (data: StitchResult<Document>) in
            switch data {
            case .success(let data):
                guard let result = data["result"] as? Document else {
                    callback(MessageParsingError.missingData, nil)
                    return
                }
                guard let food = (result["foods"] as! Array<Document?>)[0] else {
                    callback(MessageParsingError.noFoodsFound, nil)
                    return
                }
                callback(nil, food)
            case .failure(let error):
                print("Error retrieving document: \(String(describing: error))")
                callback(error, nil)
            }
        }
    }
}
