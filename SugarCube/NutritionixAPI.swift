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

class NutritionixAPI {
    static var stitchClient = Stitch.defaultAppClient!
    
    static func getNutritionData(upc: String, callback: @escaping (_ err: Error?, _ data: Document?) -> ()) {
        if stitchClient.auth.isLoggedIn {
            requestNutritionData(upc: upc) { (error, data) in
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
                    requestNutritionData(upc: upc) { (error, data) in
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
    
    static private func requestNutritionData(upc: String, callback: @escaping (_ err: Error?, _ data: Document?) -> ()) {
        stitchClient.callFunction(
            withName: "proxyNutritionix", withArgs: [upc], withRequestTimeout: 5.0
        ) { (result: StitchResult<Document>) in
            switch result {
            case .success(let result):
                callback(nil, result)
            case .failure(let error):
                print("Error retrieving document: \(String(describing: error))")
                callback(error, nil)
            }
        }
    }
}
