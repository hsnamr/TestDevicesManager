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
    
    var updatedDevices = [Int16]()
    var deletedDevices = [Int16]()
    
    var syncTimer:Timer?
    var syncInterval = 1.0

    public static let shared = MainController()
    private init() {
        setSyncTimer()
    }
    
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
            WebService.shared.addDevice(name: name, os: os, manufacturer: manufacturer, completion: nil)
        } else {
            // pass data to Core Data and set isSynced to false
            PersistenceService.shared.addDevice(name: name, os: os, manufacturer: manufacturer, isSynced: false)
        }
    }
    
    func checkInDevice(device: Device) {
        if WebService.shared.isConnectedToNetwork() {
            // pass the information to Core Data
            PersistenceService.shared.updateDevice(id: device.objectID, isCheckedOut: false, lastCheckedOutBy: nil, lastCheckedOutDate: nil)
            // and then web service
            WebService.shared.updateDevice(id: device.id, isCheckedOut: false, lastCheckedOutBy: nil, lastCheckedOutDate: nil)
        } else {
            // pass the information to Core Data
            PersistenceService.shared.updateDevice(id: device.objectID, isCheckedOut: device.isCheckedOut, lastCheckedOutBy: device.lastCheckedOutBy, lastCheckedOutDate: device.lastCheckedOutDate as Date?)
            // write unsynced device
            writeUnsyncedUpdates(id: device.id)
        }
        // and take note of the device -- this is because if a device is updated, it won't be deleted from Core Data until the app is restarted
        noteUpdatedDevices(id: device.id)
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
            // write unsynced device
            writeUnsyncedUpdates(id: device.id)
        }
        // and take note of the device -- this is because if a device is updated, it won't be deleted from Core Data until the app is restarted
        noteUpdatedDevices(id: device.id)
    }
    
    func noteUpdatedDevices(id: Int16) {
        var set = Set<Int16>(updatedDevices)
        set.insert(id)
        updatedDevices = Array(set)
    }
    
    func noteDeletedDevices(id: Int16) {
        var set = Set<Int16>(deletedDevices)
        set.insert(id)
        deletedDevices = Array(set)
    }
    
    func writeUnsyncedUpdates(id: Int16) {
        var set = Set<Int16>(PersistenceService.shared.read(name: "UnsyncedUpdates") as! [Int16]? ?? [Int16]())
        set.insert(id)
        PersistenceService.shared.write(array: Array(set), name: "UnsyncedUpdates")
    }
    
    func writeUnsyncedDeletes(id: Int16) {
        var set = Set<Int16>(PersistenceService.shared.read(name: "UnsyncedDeletes") as! [Int16]? ?? [Int16]())
        set.insert(id)
        PersistenceService.shared.write(array: Array(set), name: "UnsyncedDeletes")
    }
    
    func deleteDevice(device: Device?) {

        guard device != nil else {
            return
        }
        if WebService.shared.isConnectedToNetwork() {
            // Delete the row from the data source
            PersistenceService.shared.deleteDevice(id: (device?.objectID)!)
            // and web service
            WebService.shared.deleteDevice(id: (device?.id)!, completion: nil)
        } else {
            // Delete the row from the data source
            PersistenceService.shared.deleteDevice(id: (device?.objectID)!)
            // write unsynced device
            writeUnsyncedDeletes(id: (device?.id)!)
        }
        // and take note of the device -- this is because if a device is updated, it won't be deleted from Core Data until the app is restarted
        noteDeletedDevices(id: (device?.id)!)
    }
    
    func syncOfflineAdds() {
        // find all added devices
        while let device = PersistenceService.shared.fetchUnsyncedDevices() as Device? {
            WebService.shared.addDevice(name: device.name!, os: device.os!, manufacturer: device.manufacturer!, completion: nil)
            // set isSynced true
            PersistenceService.shared.markSynced(id: device.objectID)
        }
    }
    
    func syncOfflineUpdates() {
        // find all updated devices in userdefaults
        let unsyncedUpdates = PersistenceService.shared.read(name: "UnsyncedUpdates") as! [Int16]? ?? [Int16]()
        for id in unsyncedUpdates {
            let device = PersistenceService.shared.fetchDevice(id: id)
            if let _ = device {
                // the device has not been deleted, retrieve its data from Core Data and call the web service
                WebService.shared.updateDevice(id: (device?.id)!, isCheckedOut: (device?.isCheckedOut)!, lastCheckedOutBy: device?.lastCheckedOutBy, lastCheckedOutDate: device?.lastCheckedOutDate as Date?)
            }
        }
        
        // delete UnsyncedUpdates array now that it is synced
        PersistenceService.shared.remove(key: "UnsyncedUpdates")
    }
    
    func syncOfflineDeletes() {
        // find all deleted devices
        // we only care about devices with id as they are the only ones that will be on the web service
        let unsyncedDeletes = PersistenceService.shared.read(name: "UnsyncedDeletes") as! [Int16]? ?? [Int16]()
        for id in unsyncedDeletes {
            WebService.shared.deleteDevice(id: id, completion: nil)
        }
        // delete UnsyncedDeletes array now that it is synced
        PersistenceService.shared.remove(key: "UnsyncedDeletes")
    }
    
    @objc func syncOfflineChanges() {
        if WebService.shared.isConnectedToNetwork() {
            syncOfflineAdds()
            syncOfflineUpdates()
            syncOfflineDeletes()
        }
    }
    
    func readUpdatedAndDeleted() -> Set<Int16>? {
        var set = Set<Int16>()
        for id1 in updatedDevices {
            for id2 in deletedDevices {
                if id1 == id2 {
                    set.insert(id2)
                }
            }
        }
        
        return set
    }
    
    func remove(key: String) {
        PersistenceService.shared.remove(key: key)
    }
    
    // MARK: - Sync timer
    func setSyncTimer() {
        if (syncTimer != nil) {
            return
        }
        
        syncTimer = Timer.scheduledTimer(timeInterval: syncInterval, target: self, selector: #selector(syncOfflineChanges), userInfo: nil, repeats: true)
    }
}
