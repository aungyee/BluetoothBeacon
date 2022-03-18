//
//  ContentView.swift
//  BluetoothBeacon
//
//  Created by Aung Yee on 18/03/2022.
//

import CoreLocation
import SwiftUI

class BeaconDectector: NSObject, ObservableObject, CLLocationManagerDelegate {
    var locationManager: CLLocationManager?
    var lastDistance = CLProximity.unknown
    
    override init() {
        super.init()
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self){
                if CLLocationManager.isRangingAvailable(){
                    startScanning()
                }
            }
        }
    }
    
    func startScanning() {
        let uuid = UUID(uuidString: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5")!
        let constraint = CLBeaconIdentityConstraint(uuid: uuid, major: 6298, minor: 39450)
        let beconRegion = CLBeaconRegion(beaconIdentityConstraint: constraint, identifier: "MyBeacon")
        locationManager?.startMonitoring(for: beconRegion)
        locationManager?.startRangingBeacons(satisfying: constraint)
        print("starting scanning")
    }
    
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        if let beacon = beacons.first {
            print(beacon)
            update(distance: beacon.proximity)
        } else {
            update(distance: .unknown)
        }
    }
    
    func update(distance: CLProximity) {
        lastDistance = distance
        objectWillChange.send()
    }
}

struct BigText: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(Font.system(size: 72))
            .foregroundColor(Color.white)
            .frame(minWidth:0, maxWidth: .infinity, minHeight: 0,maxHeight: .infinity)
    }
}

struct ContentView: View {
    
    @ObservedObject var detector = BeaconDectector()
    
    var body: some View {
        if detector.lastDistance == .immediate {
            return Text("Right Here")
                .modifier(BigText())
                .background(Color.green)
                .edgesIgnoringSafeArea(.all)
        } else if detector.lastDistance == .near {
            return Text("Near")
                .modifier(BigText())
                .background(Color.orange)
                .edgesIgnoringSafeArea(.all)
        }else if detector.lastDistance == .far {
            return Text("Far")
                .modifier(BigText())
                .background(Color.red)
                .edgesIgnoringSafeArea(.all)
        }else{
            return Text("Unknown")
                .modifier(BigText())
                .background(Color.black)
                .edgesIgnoringSafeArea(.all)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
