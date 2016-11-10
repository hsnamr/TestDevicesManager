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
import SwiftyJSON

class PersistenceService {
    public static let shared = PersistenceService()
    private init() {}
    
    let dataStack = DATAStack(modelName: "JnJCCA")
    
    // used by AddDevicePage
    func addDevice(name: String, os: String, manufacturer: String, isSynced: Bool) {
        let entity = NSEntityDescription.entity(forEntityName: "Device", in: self.dataStack.mainContext)!
        let object = NSManagedObject(entity: entity, insertInto: self.dataStack.mainContext)
        object.setValue(name, forKey: "name")
        object.setValue(os, forKey: "os")
        object.setValue(manufacturer, forKey: "manufacturer")
        object.setValue(false, forKey: "isCheckedOut")
        object.setValue(isSynced, forKey: "isSynced")
        
        // hack since web service always returns id = 5 for added devices and we need id to be unique to keep track of updates and deletions
        // ideally we would have a callback that takes the JSON response and uses it to add the device to Core Data
        // In other words if online upload to webservice and then store response to Core Data
        // if offline store in Core Data and then once online update with id from JSON response
        // though for now since the web service is mock we just do this
        struct Hack {
            static var idc:Int16 = 5
        }
        while deviceExists(id: Hack.idc) != nil {
            Hack.idc += 1
        }
        
        object.setValue(Hack.idc, forKey: "id")
        try! self.dataStack.mainContext.save()
    }
    
    // used for intial load
    func addDevices(from json:JSON, completion: ()->()) {
        let entity = NSEntityDescription.entity(forEntityName: "Device", in: self.dataStack.mainContext)!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        for item in json.array! {
            if (deviceExists(id: Int16(item["id"].intValue)) != nil) {
                // device is already in Core Data
                continue
            }
            let object = NSManagedObject(entity: entity, insertInto: self.dataStack.mainContext)
            object.setValue(item["device"].string!, forKey: "name")
            object.setValue(item["os"].string!, forKey: "os")
            object.setValue(item["manufacturer"].string!, forKey: "manufacturer")
            if let _ = item["isCheckedOut"].bool {
                object.setValue(item["isCheckedOut"].boolValue, forKey: "isCheckedOut")
            }
            if let _ = item["lastCheckedOutBy"].string {
                object.setValue(item["lastCheckedOutBy"].string!, forKey: "lastCheckedOutBy")
            }
            if let _ = item["lastCheckedOutDate"].string {
                object.setValue(dateFormatter.date(from: item["lastCheckedOutDate"].string!), forKey: "lastCheckedOutDate")
            }
            object.setValue(Int16(item["id"].intValue), forKey: "id")
            object.setValue(true, forKey: "isSynced")
        }
        
        try! self.dataStack.mainContext.save()
        
        completion()
    }
    
    // used by DeviceDetailPage
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
    
    func deviceExists(id: Int16) -> Device? {
        return fetchDevice(id: id)
    }
    
    func fetchDevice(id: NSManagedObjectID) -> Device? {
        let object = self.dataStack.mainContext.object(with: id)
        
        if let device: Device = object as? Device {
            print("Fetched device with ID = \(id). The name of this device is '\(device.name)'")
            return device
        }
        return nil
    }
    
    // returns device if there are unsynced devices, else nil
    func fetchUnsyncedDevices() -> Device? {
        return fetchDevice(id: nil)
    }
    
    func fetchDevice(id: Int16?) -> Device? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Device")
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        
        var predicate:NSPredicate!
        if let _ = id {
            // fetching device by id to check if exists
            predicate = NSPredicate(format: "id == \(id!)", argumentArray: nil)
        } else {
            // fetching unsynced devices
            predicate = NSPredicate(format: "isSynced == \(false)", argumentArray: nil)
        }
        
        // Assign fetch request properties
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.fetchBatchSize = 1
        fetchRequest.fetchLimit = 1
        
        // Handle results
        let fetchedResult = try? self.dataStack.mainContext.fetch(fetchRequest)
        
        if fetchedResult?.count == 0 {
            return nil
        }
        
        if let fetchedDevice = fetchedResult?[0] as? Device {
            print("Fetched device with id = \(fetchedDevice.id), isSynced = \(fetchedDevice.isSynced), name '\(fetchedDevice.name)'")
            return fetchedDevice
        }
        
        return nil
    }
    
    func deleteDevice(id: NSManagedObjectID) {
        let object = self.dataStack.mainContext.object(with: id)
        self.dataStack.mainContext.delete(object)
        try! self.dataStack.mainContext.save()
    }
    
    func write(array: [Any], name: String) {
        let defaults = UserDefaults.standard
        defaults.set(array, forKey: name)
    }
    
    func read(name: String) -> [Any]? {
        let defaults = UserDefaults.standard
        return defaults.array(forKey: name)
    }
    
    func remove(key: String) {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: key)
    }
//    func clear() {
//        let appDomain = Bundle.main.bundleIdentifier!
//        UserDefaults.standard.removePersistentDomain(forName: appDomain)
//    }
}
