//
//  PersistenceService.swift
//  TDM
//
//  Created by Hussian Ali Al-Amri on 11/2/16.
//  Copyright © 2016 IM. All rights reserved.
//

import Foundation
import DATAStack
import DATASource
import SwiftyJSON

final class PersistenceService {

    static let shared = PersistenceService()
    private init() {}

    let dataStack = DATAStack(modelName: "JnJCCA")

    // MARK: - Device CRUD

    /// Adds a new device (used by AddDevicePage).
    func addDevice(name: String, os: String, manufacturer: String, isSynced: Bool) {
        guard let entity = NSEntityDescription.entity(forEntityName: "Device", in: dataStack.mainContext) else {
            return
        }
        let object = NSManagedObject(entity: entity, insertInto: dataStack.mainContext)
        object.setValue(name, forKey: "name")
        object.setValue(os, forKey: "os")
        object.setValue(manufacturer, forKey: "manufacturer")
        object.setValue(false, forKey: "isCheckedOut")
        object.setValue(isSynced, forKey: "isSynced")

        // Assign unique id for local tracking (mock API returns fixed id).
        var nextId: Int16 = 5
        while deviceExists(id: nextId) != nil {
            nextId += 1
        }
        object.setValue(nextId, forKey: "id")

        do {
            try dataStack.mainContext.save()
        } catch {
            print("PersistenceService addDevice save error: \(error)")
        }
    }

    /// Bulk add devices from API response (initial load).
    func addDevices(from json: JSON, completion: () -> Void) {
        guard let entity = NSEntityDescription.entity(forEntityName: "Device", in: dataStack.mainContext),
              let items = json.array else {
            completion()
            return
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"

        for item in items {
            let id = Int16(item["id"].intValue)
            if deviceExists(id: id) != nil {
                continue
            }
            let object = NSManagedObject(entity: entity, insertInto: dataStack.mainContext)
            object.setValue(item["device"].string, forKey: "name")
            object.setValue(item["os"].string, forKey: "os")
            object.setValue(item["manufacturer"].string, forKey: "manufacturer")
            if item["isCheckedOut"].exists() {
                object.setValue(item["isCheckedOut"].boolValue, forKey: "isCheckedOut")
            }
            if let lastCheckedOutBy = item["lastCheckedOutBy"].string {
                object.setValue(lastCheckedOutBy, forKey: "lastCheckedOutBy")
            }
            if let dateString = item["lastCheckedOutDate"].string,
               let date = dateFormatter.date(from: dateString) {
                object.setValue(date, forKey: "lastCheckedOutDate")
            }
            object.setValue(id, forKey: "id")
            object.setValue(true, forKey: "isSynced")
        }

        do {
            try dataStack.mainContext.save()
        } catch {
            print("PersistenceService addDevices save error: \(error)")
        }
        completion()
    }

    /// Updates device checkout state (used by DeviceDetailPage).
    func updateDevice(id: NSManagedObjectID, isCheckedOut: Bool, lastCheckedOutBy: String?, lastCheckedOutDate: Date?) {
        guard let object = fetchDevice(id: id) else { return }
        object.setValue(isCheckedOut, forKey: "isCheckedOut")
        if isCheckedOut {
            object.setValue(lastCheckedOutBy, forKey: "lastCheckedOutBy")
            object.setValue(lastCheckedOutDate, forKey: "lastCheckedOutDate")
        }
        do {
            try dataStack.mainContext.save()
        } catch {
            print("PersistenceService updateDevice save error: \(error)")
        }
    }

    func markSynced(id: NSManagedObjectID) {
        guard let object = fetchDevice(id: id) else { return }
        object.setValue(true, forKey: "isSynced")
        do {
            try dataStack.mainContext.save()
        } catch {
            print("PersistenceService markSynced save error: \(error)")
        }
    }

    func deviceExists(id: Int16) -> Device? {
        fetchDevice(id: id)
    }

    func fetchDevice(id: NSManagedObjectID) -> Device? {
        let object = dataStack.mainContext.object(with: id)
        return object as? Device
    }

    /// Returns one unsynced device, or nil.
    func fetchUnsyncedDevices() -> Device? {
        fetchDevice(id: nil)
    }

    func fetchDevice(id: Int16?) -> Device? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Device")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        fetchRequest.fetchBatchSize = 1
        fetchRequest.fetchLimit = 1

        if let id = id {
            fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        } else {
            fetchRequest.predicate = NSPredicate(format: "isSynced == NO")
        }

        do {
            let result = try dataStack.mainContext.fetch(fetchRequest)
            return result.first as? Device
        } catch {
            print("PersistenceService fetchDevice error: \(error)")
            return nil
        }
    }

    func deleteDevice(id: NSManagedObjectID) {
        let object = dataStack.mainContext.object(with: id)
        dataStack.mainContext.delete(object)
        do {
            try dataStack.mainContext.save()
        } catch {
            print("PersistenceService deleteDevice save error: \(error)")
        }
    }

    // MARK: - UserDefaults (Int16 arrays)

    func write(array: [Int16], name: String) {
        UserDefaults.standard.set(array.map { Int($0) }, forKey: name)
    }

    func readInt16Array(name: String) -> [Int16] {
        guard let raw = UserDefaults.standard.array(forKey: name) as? [Int] else {
            return []
        }
        return raw.map { Int16($0) }
    }

    /// Generic read for backward compatibility; prefer readInt16Array for Int16 arrays.
    func read(name: String) -> [Any]? {
        UserDefaults.standard.array(forKey: name)
    }

    func remove(key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
