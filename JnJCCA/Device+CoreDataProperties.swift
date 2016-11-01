//
//  Device+CoreDataProperties.swift
//  JnJCCA
//
//  Created by Hussian Ali Al-Amri on 11/1/16.
//  Copyright © 2016 IM. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Device {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Device> {
        return NSFetchRequest<Device>(entityName: "Device");
    }

    @NSManaged public var name: String?
    @NSManaged public var id: Int16
    @NSManaged public var os: String?
    @NSManaged public var manufacturer: String?
    @NSManaged public var isCheckedOut: Bool
    @NSManaged public var lastCheckedOutDate: NSDate?
    @NSManaged public var lastCheckedOutBy: String?

}
