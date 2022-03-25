//
//  BeaconMapView.swift
//  BluetoothBeacon
//
//  Created by Aung Yee on 23/03/2022.
//

import SwiftUI
import MapKit



struct BeaconMapView: View {
    @ObservedObject var beaconDetector = BeaconDetector()
    
    @State var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 50.80624829, longitude: -0.02234339), span: MKCoordinateSpan(latitudeDelta: 0.0001, longitudeDelta: 0.0001))
    
    @State var trackingMode = MapUserTrackingMode.follow
    
    var accentColor: Color {
        if let beacon = beaconDetector.lastBeaconSignal {
            if beacon.rssi != 0 && beacon.rssi > -40 {
                return Color.green
            } else if beacon.rssi > -60 && beacon.rssi < -40 {
                return Color.yellow
            } else if beacon.rssi == 0 {
                return Color.black
            } else if beacon.rssi > -80 && beacon.rssi < -60 {
                return Color.orange
            } else {
                return Color.red
            }
        } else {
            return Color.black
        }
    }
    
    func getColor(rssi: Int16) -> Color {
        if rssi != 0 && rssi > -40 {
            return Color.green
        } else if rssi > -60 && rssi < -40 {
            return Color.yellow
        } else if rssi == 0 {
            return Color.black
        } else if rssi > -80 && rssi < -60  {
            return Color.orange
        } else {
            return Color.red
        }
    }
    
    var body: some View {
        ZStack (alignment:.bottom) {
            Map(coordinateRegion: $region,showsUserLocation: true, userTrackingMode: $trackingMode, annotationItems: beaconDetector.beaconSignalLevels){ beaconLevel in
                MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(beaconLevel.latitude), longitude: CLLocationDegrees(beaconLevel.longitude))) {
                    Circle()
                        .fill(getColor(rssi: beaconLevel.rssi))
                        .opacity(0.4)
                        .frame(width: 15.0, height: 15.0)
                    
                }
            }
                .ignoresSafeArea()
                .accentColor(accentColor)
            VStack(alignment:.leading) {
                Text("Proximity: " + String(beaconDetector.lastDistance.rawValue) + "m")
                    .padding(.bottom,1)
                Text("Accuracy: " + String(beaconDetector.lastBeaconSignal?.accuracy.magnitude.rounded(.toNearestOrAwayFromZero) ?? 0.0) + "m")
                    .padding(.bottom,1)
                Text("RSSI: " + String(beaconDetector.lastBeaconSignal?.rssi ?? 0))
                    .padding(.bottom,1)
            }
            
        }
    }
}

struct BeaconMapView_Previews: PreviewProvider {
    static var previews: some View {
        BeaconMapView()
    }
}
