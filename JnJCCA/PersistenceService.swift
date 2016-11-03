//
//  PresistenceService.swift
//  JnJCCA
//
//  Created by Hussian Ali Al-Amri on 11/2/16.
//  Copyright © 2016 IM. All rights reserved.
//

import Foundation
import DATAStack
import DATASource

class PersistenceService {
    public static let shared = PersistenceService()
    private init() {}
    
    let dataStack = DATAStack(modelName: "JnJCCA")
    
    func addDevice(name: String, os: String, manufacturer: String) {
        let entity = NSEntityDescription.entity(forEntityName: "Device", in: self.dataStack.mainContext)!
        let object = NSManagedObject(entity: entity, insertInto: self.dataStack.mainContext)
        object.setValue(name, forKey: "name")
        object.setValue(os, forKey: "os")
        object.setValue(manufacturer, forKey: "manufacturer")
        try! self.dataStack.mainContext.save()
    }
    
    func addDevices(from json:[String:Any]) {
        let entity = NSEntityDescription.entity(forEntityName: "Device", in: self.dataStack.mainContext)!
        let object = NSManagedObject(entity: entity, insertInto: self.dataStack.mainContext)
        
        for (key, value) in json {
            object.setValue(value, forKey: key)
        }
        
        try! self.dataStack.mainContext.save()
    }
    
    func updateDevice(id: NSManagedObjectID, isCheckedOut: Bool, lastCheckedOutBy: String?, lastCheckedOutDate: Date?) {
        if isCheckedOut == true {
            if let object = fetchDevice(id: id) {
                object.setValue(isCheckedOut, forKey: "isCheckedOut")
                object.setValue(lastCheckedOutBy, forKey: "lastCheckedOutBy")
                object.setValue(lastCheckedOutDate, forKey: "lastCheckedOutDate")
                try! self.dataStack.mainContext.save()
            }
        } else {
            if let object = fetchDevice(id: id) {
                object.setValue(isCheckedOut, forKey: "isCheckedOut")
                try! self.dataStack.mainContext.save()
            }
        }
    }
    
    func fetchDevice(id: NSManagedObjectID) -> Device? {
        let object = self.dataStack.mainContext.object(with: id)
        
        if let device: Device = object as? Device {
            print("Fetched device with ID = \(id). The name of this device is '\(device.name)'")
            return device
        }
        return nil
    }
    
    func deleteDevice(id: NSManagedObjectID) {
        let object = self.dataStack.mainContext.object(with: id)
        self.dataStack.mainContext.delete(object)
    }
}
