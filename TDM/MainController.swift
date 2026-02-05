//
//  MainController.swift
//  TDM
//
//  Created by Hussian Ali Al-Amri on 11/4/16.
//  Copyright © 2016 IM. All rights reserved.
//

import Foundation
import CoreData

final class MainController {

    var updatedDevices = [Int16]()
    var deletedDevices = [Int16]()

    private var syncTimer: Timer?
    private let syncInterval: TimeInterval = 1.0

    static let shared = MainController()
    private init() {
        setSyncTimer()
    }

    // MARK: - Devices

    func getDevices(completion: @escaping () -> Void) {
        if WebService.shared.isConnectedToNetwork() {
            WebService.shared.getDevices(completion: completion)
        }
    }

    func addDevice(name: String, os: String, manufacturer: String) {
        if WebService.shared.isConnectedToNetwork() {
            PersistenceService.shared.addDevice(name: name, os: os, manufacturer: manufacturer, isSynced: true)
            WebService.shared.addDevice(name: name, os: os, manufacturer: manufacturer, completion: nil)
        } else {
            PersistenceService.shared.addDevice(name: name, os: os, manufacturer: manufacturer, isSynced: false)
        }
    }

    func checkInDevice(device: Device) {
        if WebService.shared.isConnectedToNetwork() {
            PersistenceService.shared.updateDevice(id: device.objectID, isCheckedOut: false, lastCheckedOutBy: nil, lastCheckedOutDate: nil)
            WebService.shared.updateDevice(id: device.id, isCheckedOut: false, lastCheckedOutBy: nil, lastCheckedOutDate: nil)
        } else {
            PersistenceService.shared.updateDevice(id: device.objectID, isCheckedOut: device.isCheckedOut, lastCheckedOutBy: device.lastCheckedOutBy, lastCheckedOutDate: device.lastCheckedOutDate as Date?)
            writeUnsyncedUpdates(id: device.id)
        }
        noteUpdatedDevices(id: device.id)
    }

    func checkOutDevice(device: Device) {
        if WebService.shared.isConnectedToNetwork() {
            PersistenceService.shared.updateDevice(id: device.objectID, isCheckedOut: device.isCheckedOut, lastCheckedOutBy: device.lastCheckedOutBy, lastCheckedOutDate: device.lastCheckedOutDate as Date?)
            WebService.shared.updateDevice(id: device.id, isCheckedOut: true, lastCheckedOutBy: device.lastCheckedOutBy, lastCheckedOutDate: device.lastCheckedOutDate as Date?)
        } else {
            PersistenceService.shared.updateDevice(id: device.objectID, isCheckedOut: device.isCheckedOut, lastCheckedOutBy: device.lastCheckedOutBy, lastCheckedOutDate: device.lastCheckedOutDate as Date?)
            writeUnsyncedUpdates(id: device.id)
        }
        noteUpdatedDevices(id: device.id)
    }

    func noteUpdatedDevices(id: Int16) {
        var set = Set(updatedDevices)
        set.insert(id)
        updatedDevices = Array(set)
    }

    func noteDeletedDevices(id: Int16) {
        var set = Set(deletedDevices)
        set.insert(id)
        deletedDevices = Array(set)
    }

    func writeUnsyncedUpdates(id: Int16) {
        var set = Set(PersistenceService.shared.readInt16Array(name: "UnsyncedUpdates"))
        set.insert(id)
        PersistenceService.shared.write(array: Array(set), name: "UnsyncedUpdates")
    }

    func writeUnsyncedDeletes(id: Int16) {
        var dSet = Set(PersistenceService.shared.readInt16Array(name: "UnsyncedDeletes"))
        dSet.insert(id)
        PersistenceService.shared.write(array: Array(dSet), name: "UnsyncedDeletes")
        var uSet = Set(PersistenceService.shared.readInt16Array(name: "UnsyncedUpdates"))
        uSet.remove(id)
        PersistenceService.shared.write(array: Array(uSet), name: "UnsyncedUpdates")
    }

    func deleteDevice(device: Device?) {
        guard let device = device else { return }
        if WebService.shared.isConnectedToNetwork() {
            PersistenceService.shared.deleteDevice(id: device.objectID)
            WebService.shared.deleteDevice(id: device.id, completion: nil)
        } else {
            PersistenceService.shared.deleteDevice(id: device.objectID)
            writeUnsyncedDeletes(id: device.id)
        }
        noteDeletedDevices(id: device.id)
    }

    // MARK: - Offline sync

    func syncOfflineAdds() {
        while let device = PersistenceService.shared.fetchUnsyncedDevices() {
            guard WebService.shared.isConnectedToNetwork() else { break }
            WebService.shared.addDevice(name: device.name!, os: device.os!, manufacturer: device.manufacturer!, completion: nil)
            PersistenceService.shared.markSynced(id: device.objectID)
        }
    }

    func syncOfflineUpdates() -> Int {
        let unsyncedUpdates = PersistenceService.shared.readInt16Array(name: "UnsyncedUpdates")
        var syncedUpdates = [Int16]()
        for id in unsyncedUpdates {
            guard let device = PersistenceService.shared.fetchDevice(id: id), WebService.shared.isConnectedToNetwork() else {
                continue
            }
            WebService.shared.updateDevice(id: device.id, isCheckedOut: device.isCheckedOut, lastCheckedOutBy: device.lastCheckedOutBy, lastCheckedOutDate: device.lastCheckedOutDate as Date?)
            syncedUpdates.append(id)
        }
        if syncedUpdates.count == unsyncedUpdates.count {
            PersistenceService.shared.remove(key: "UnsyncedUpdates")
        } else {
            let diff = Set(unsyncedUpdates).subtracting(Set(syncedUpdates))
            PersistenceService.shared.write(array: Array(diff), name: "UnsyncedUpdates")
        }
        return syncedUpdates.count
    }

    func syncOfflineDeletes() -> Int {
        let unsyncedDeletes = PersistenceService.shared.readInt16Array(name: "UnsyncedDeletes")
        var syncedDeletes = [Int16]()
        for id in unsyncedDeletes {
            if WebService.shared.isConnectedToNetwork() {
                WebService.shared.deleteDevice(id: id, completion: nil)
                syncedDeletes.append(id)
            }
        }
        if syncedDeletes.count == unsyncedDeletes.count {
            PersistenceService.shared.remove(key: "UnsyncedDeletes")
        } else {
            let diff = Set(unsyncedDeletes).subtracting(Set(syncedDeletes))
            PersistenceService.shared.write(array: Array(diff), name: "UnsyncedDeletes")
        }
        return syncedDeletes.count
    }

    @objc private func syncOfflineChanges() {
        syncOfflineAdds()
        _ = syncOfflineUpdates()
        _ = syncOfflineDeletes()
    }

    func readUpdatedAndDeleted() -> Set<Int16>? {
        var set = Set<Int16>()
        for id1 in updatedDevices {
            for id2 in deletedDevices where id1 == id2 {
                set.insert(id2)
            }
        }
        return set.isEmpty ? nil : set
    }

    func remove(key: String) {
        PersistenceService.shared.remove(key: key)
    }

    // MARK: - Sync timer

    private func setSyncTimer() {
        guard syncTimer == nil else { return }
        syncTimer = Timer.scheduledTimer(withTimeInterval: syncInterval, repeats: true) { [weak self] _ in
            self?.syncOfflineChanges()
        }
        RunLoop.main.add(syncTimer!, forMode: .common)
    }
}
