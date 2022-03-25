//
//  BeaconSignalLevel+CoreDataProperties.swift
//  BluetoothBeacon
//
//  Created by Aung Yee on 25/03/2022.
//
//

import Foundation
import CoreData


extension BeaconSignalLevel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BeaconSignalLevel> {
        return NSFetchRequest<BeaconSignalLevel>(entityName: "BeaconSignalLevel")
    }

    @NSManaged public var beacon_accuracy: Double
    @NSManaged public var course: Double
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var proximity: Int16
    @NSManaged public var speed: Double
    @NSManaged public var timestamp: Date?
    @NSManaged public var rssi: Int16

}

extension BeaconSignalLevel : Identifiable {

}
