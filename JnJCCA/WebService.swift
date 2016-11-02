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
    
    // get devices
    func getDevices() -> Bool {
        var isSuccessful = false
        
        // To-Do: set isSuccessful based on HTTP response
        
        return isSuccessful
    }
    
    // adds a new device
    func add(device: Device) -> Bool {
        var isSuccessful = false
        
        // To-Do: set isSuccessful based on HTTP response
        
        return isSuccessful
    }
    
    
    // updates existing device
    // can be used to check out device
    func update(id: Int) -> Bool {
        var isSuccessful = false
        
        // To-Do: set isSuccessful based on HTTP response
        
        return isSuccessful
    }
    
    // delete device
    func delete(id: Int) -> Bool {
        var isSuccessful = false
        
        // To-Do: set isSuccessful based on HTTP response
        
        return isSuccessful
    }
}
