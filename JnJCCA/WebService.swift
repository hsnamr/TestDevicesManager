//
//  WebService.swift
//  JnJCCA
//
//  Created by Hussian Ali Al-Amri on 11/1/16.
//  Copyright © 2016 IM. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import SystemConfiguration

class WebService {
    let baseURL = "http://private-1cc0f-devicecheckout.apiary-mock.com"
    
    public static let shared = WebService()
    private init() {}
    
    // http://stackoverflow.com/a/39783037
    func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        let isReachable = flags == .reachable
        let needsConnection = flags == .connectionRequired
        
        return isReachable && !needsConnection
    }
    
    // get devices
    func getDevices(completion: @escaping ()->()) {
        request("\(baseURL)/devices", method: .get)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON(completionHandler: { (response) in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    PersistenceService.shared.addDevices(from: json, completion: completion)
                case .failure(let error):
                    print(error)
                }
        })
    }
    
    // adds a new device
    func addDevice(name: String, os: String, manufacturer: String) {
        let parameters = ["device":name, "os":os, "manufacturer":manufacturer]
        request("\(baseURL)/devices", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON(completionHandler: { (response) in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    print(json)
                case .failure(let error):
                    print(error)
                }
        })
    }
    
    // updates existing device
    // used to check in/out device
    func updateDevice(id: Int16, isCheckedOut: Bool, lastCheckedOutBy: String?, lastCheckedOutDate: Date?) {
        var parameters:[String : Any]!
        if isCheckedOut == true {
            // crashes here because of the date format: pass dummy date string for now
            parameters = ["lastCheckedOutDate":"2016-11-04T10:33:00-05:00", "lastCheckedOutBy":lastCheckedOutBy!, "isCheckedOut":true] as [String : Any]
        } else if isCheckedOut == false {
            parameters = ["isCheckedOut":false]
        }
        request("\(baseURL)/devices/\(id)", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON(completionHandler: { (response) in
                if let JSON = response.result.value {
                    print("JSON: \(JSON)")
                }
            })
    }
    
    // deletes device
    func deleteDevice(id: Int16, completion:((String)->())?) {
        request("\(baseURL)/devices/\(id)", method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: nil)
            .validate(statusCode: 200..<300).responseJSON { response in
                switch response.result {
                case .success:
                    completion?("Success")
                case .failure(_):
                    completion?("Failure")
                }
        }
    }
}
