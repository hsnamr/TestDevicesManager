//
//  WebService.swift
//  JnJCCA
//
//  Created by Hussian Ali Al-Amri on 11/1/16.
//  Copyright © 2016 IM. All rights reserved.
//

import Foundation
import Alamofire

class WebService {
    let baseURL = "http://private-1cc0f-devicecheckout.apiary-mock.com"
    
    public static let shared = WebService()
    
    private init() {}
    
    
    // get devices
    func getDevices() {
        request("\(baseURL)/devices", method: .get)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON(completionHandler: { (response) in
            if let JSON = response.result.value {
                print("JSON: \(JSON)")
            }
        })
    }
    
    // adds a new device
    func add(device: Device) {
        let parameters = ["device":device.name, "os":device.os, "manufacturer":device.manufacturer]
        request("\(baseURL)/devices", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON(completionHandler: { (response) in
                if let JSON = response.result.value {
                    print("JSON: \(JSON)")
                }
        })
    }
    
    // updates existing device
    // can be used to check out device
    func update(device: Device) {
        var parameters:[String : Any]!
        if device.isCheckedOut {
            parameters = ["lastCheckedOutDate":device.lastCheckedOutDate!, "lastCheckedOutBy":device.lastCheckedOutBy!, "isCheckedOut":device.isCheckedOut] as [String : Any]
        } else {
            parameters = ["isCheckedOut":device.isCheckedOut]
        }
        request("\(baseURL)/devices/\(device.id)", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON(completionHandler: { (response) in
                if let JSON = response.result.value {
                    print("JSON: \(JSON)")
                }
            })
    }
    
    // delete device
    func delete(device: Device) {
        request("\(baseURL)/devices/\(device.id)", method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: nil)
            .validate(statusCode: 200..<300)
    }
}
