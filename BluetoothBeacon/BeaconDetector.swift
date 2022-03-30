//
//  LocationManager.swift
//  BluetoothBeacon
//
//  Created by Aung Yee on 23/03/2022.
//

import CoreData
import CoreLocation
import UserNotifications


class BeaconDetector: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager: CLLocationManager?
    private var center = UNUserNotificationCenter.current()
    private let container = NSPersistentContainer(name: "BeaconSignalLevel")
    private var count = 0
    
    @Published private(set) var lastBeaconSignal: CLBeacon?
    @Published private(set) var lastLocation: CLLocation?
    @Published private(set) var lastDistance = CLProximity.unknown
    @Published private(set) var beaconSignalLevels: [BeaconSignalLevel] = []
    
    
    
    override init() {
        super.init()
        print(container)
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        locationManager?.allowsBackgroundLocationUpdates = true
        
        initialiseDataStore()
        
        let content = UNMutableNotificationContent()
        content.title = "Beacon"
        content.body = "iBeacon detected around you"
        content.categoryIdentifier = "alarm"
        content.userInfo = ["customData": "fizzbuzz"]
        content.sound = UNNotificationSound.default
        
        let uuid = UUID(uuidString: "5a4bcfce-174e-4bac-a814-092e77f6b7e5")!
        let constraint = CLBeaconIdentityConstraint(uuid: uuid)
        let beaconRegion = CLBeaconRegion(beaconIdentityConstraint: constraint, identifier: "MyBeacon")
        
        let trigger = UNLocationNotificationTrigger(region: beaconRegion, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
        center.requestAuthorization(options: [.alert,.sound,.badge]) {
            granted, error in
            if let error = error {
                print(error)
            }
        }
    }
    
    func initialiseDataStore () {
        container.loadPersistentStores(){ description, error in
            if let error = error {
                print("error \(error)")
            } else {
                print("datastore loaded")
                self.fetchBeaconSignalLevel()
            }
        }
    }
    
    func fetchBeaconSignalLevel(){
        let request = NSFetchRequest<BeaconSignalLevel>(entityName: "BeaconSignalLevel")
        do {
            let fetchResult = try container.viewContext.fetch(request).sorted {
                $0.timestamp! > $1.timestamp!
            }
            beaconSignalLevels = fetchResult
            print("fetching")
        } catch let error {
            print("error fetching: \(error)")
        }
    }
    
    func deleteRecords(){
        do {
            for store in container.persistentStoreCoordinator.persistentStores {
                try container.persistentStoreCoordinator.destroyPersistentStore(at: store.url!, ofType: store.type, options: nil)
            }
            beaconSignalLevels = []
            initialiseDataStore()
        } catch let error {
            print("error fetching: \(error)")
        }
    }
    
    func saveBeaconSignalLevel(beacon: CLBeacon, location: CLLocation){
        let newBeaconSignalLevel = BeaconSignalLevel(context: container.viewContext)
        newBeaconSignalLevel.longitude = location.coordinate.longitude
        newBeaconSignalLevel.latitude = location.coordinate.latitude
        newBeaconSignalLevel.proximity = Int16(beacon.proximity.rawValue)
        newBeaconSignalLevel.beacon_accuracy = beacon.accuracy.magnitude
        newBeaconSignalLevel.rssi = Int16(beacon.rssi)
        newBeaconSignalLevel.timestamp = beacon.timestamp
        newBeaconSignalLevel.speed = location.speed.magnitude
        newBeaconSignalLevel.coordinate_accuracy = location.horizontalAccuracy.magnitude
        
        do {
            try container.viewContext.save()
            print("saving")
        } catch let error {
            print("error saving: \(error)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self){
                if CLLocationManager.isRangingAvailable(){
                    startScanning()
                }
            }
        }
    }
    
    func startScanning() {
        let uuid = UUID(uuidString: "5a4bcfce-174e-4bac-a814-092e77f6b7e5")!
        let constraint = CLBeaconIdentityConstraint(uuid: uuid)
        let beaconRegion = CLBeaconRegion(beaconIdentityConstraint: constraint, identifier: "MyBeacon")
        locationManager?.startMonitoring(for: beaconRegion)
        locationManager?.startRangingBeacons(satisfying: constraint)
        locationManager?.startUpdatingLocation()
        locationManager?.startUpdatingHeading()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            lastLocation = location
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
//            print(newHeading)
    }
    
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        if let beacon = beacons.first {
            print(lastBeaconSignal ?? "No Beacon Signal")
            lastBeaconSignal = beacon
            lastDistance = beacon.proximity
            
            if let lastLocation = lastLocation {
                if beacon.rssi != 0 {
                    saveBeaconSignalLevel(beacon: beacon, location: lastLocation)
                    count = count + 1
                }
                if count % 1 == 0 {
                    fetchBeaconSignalLevel()
                }
                
            }
        }
    }
}
