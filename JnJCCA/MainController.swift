//
//  MainController.swift
//  JnJCCA
//
//  Created by Hussian Ali Al-Amri on 11/4/16.
//  Copyright © 2016 IM. All rights reserved.
//

import Foundation
import CoreData

class MainController {

    public static let shared = MainController()
    private init() {}
    
    func getDevices(completion: @escaping ()->()) {
        if WebService.shared.isConnectedToNetwork() {
            WebService.shared.getDevices(completion: {
                completion()
            })
        }
    }
    
    func addDevice(name: String, os: String, manufacturer: String) {
        if WebService.shared.isConnectedToNetwork() {
            // pass data to Core Data, isSyneced is true
            PersistenceService.shared.addDevice(name: name, os: os, manufacturer: manufacturer, isSynced: true)
            // and to web
            WebService.shared.addDevice(name: name, os: os, manufacturer: manufacturer)
        } else {
            // pass data to Core Data and set isSynced to false
            PersistenceService.shared.addDevice(name: name, os: os, manufacturer: manufacturer, isSynced: false)
        }
    }
    
    func checkInDevice(device: Device) {
        if WebService.shared.isConnectedToNetwork() {
            // pass the information to Core Data
            PersistenceService.shared.updateDevice(id: device.objectID, isCheckedOut: false, lastCheckedOutBy: nil, lastCheckedOutDate: nil)
            WebService.shared.updateDevice(id: device.id, isCheckedOut: false, lastCheckedOutBy: nil, lastCheckedOutDate: nil)
        } else {
            print("Not connected to network. Take note of device.")
        }
    }
    
    func checkOutDevice(device: Device) {
        if WebService.shared.isConnectedToNetwork() {
            // pass the information to Core Data
            PersistenceService.shared.updateDevice(id: device.objectID, isCheckedOut: device.isCheckedOut, lastCheckedOutBy: device.lastCheckedOutBy, lastCheckedOutDate: device.lastCheckedOutDate as Date?)
            // and then web service
            WebService.shared.updateDevice(id: device.id, isCheckedOut: true, lastCheckedOutBy: device.lastCheckedOutBy, lastCheckedOutDate: device.lastCheckedOutDate as Date?)
        } else {
            // pass the information to Core Data
            PersistenceService.shared.updateDevice(id: device.objectID, isCheckedOut: device.isCheckedOut, lastCheckedOutBy: device.lastCheckedOutBy, lastCheckedOutDate: device.lastCheckedOutDate as Date?)
            // and take note of the device
            var array = PersistenceService.shared.read(name: "UpdatedDevices")
            array?.append(device.objectID)
            PersistenceService.shared.write(array: array!, name: "UpdatedDevices")
        }
    }
    
    func deleteDevice(userData: [Any]) {
        if WebService.shared.isConnectedToNetwork() {
            // Delete the row from the data source
            PersistenceService.shared.deleteDevice(id: userData[0] as! NSManagedObjectID)
            // and web service
            WebService.shared.deleteDevice(id: userData[1] as! Int16)
        } else {
            // Delete the row from the data source
            PersistenceService.shared.deleteDevice(id: userData[0] as! NSManagedObjectID)
            // and take note of the device
            var array = PersistenceService.shared.read(name: "DeletedDevices")
            array?.append(userData[1] as! Int16)
            PersistenceService.shared.write(array: array!, name: "DeletedDevices")
        }
    }
    
    func syncOfflineChanges() {
        if WebService.shared.isConnectedToNetwork() {
            // find all added devices
            while let device = PersistenceService.shared.fetchUnsyncedDevices() as Device? {
                WebService.shared.addDevice(name: device.name!, os: device.os!, manufacturer: device.manufacturer!)
            }
            
            // find all updated devices in userdefaults
            let unsyncedUpdates = PersistenceService.shared.read(name: "UpdatedDevices") as! [NSManagedObjectID]? ?? [NSManagedObjectID]()
            for objectID in unsyncedUpdates {
                let device = PersistenceService.shared.fetchDevice(id: objectID)
                WebService.shared.updateDevice(id: (device?.id)!, isCheckedOut: (device?.isCheckedOut)!, lastCheckedOutBy: device?.lastCheckedOutBy, lastCheckedOutDate: device?.lastCheckedOutDate as Date?)
            }
            
            // find all deleted devices
            // we only care about devices with id as they are the only ones that will be on the web service
            let unsyncedDeletes = PersistenceService.shared.read(name: "DeletedDevices") as! [Int16]? ?? [Int16]()
            for id in unsyncedDeletes {
                WebService.shared.deleteDevice(id: id)
            }
        }
    }
}
