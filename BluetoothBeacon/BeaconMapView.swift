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
    
    @State var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0.0, longitude: -0.0), span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001))
    
    @State var trackingMode = MapUserTrackingMode.follow
    
    @State var showAlert = false
    
    @State var showCurrentLocation = true
    
    @State var showShareSheet = false
    
    @State var isLoading = false
    
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
            Map(coordinateRegion: $region,showsUserLocation: showCurrentLocation, userTrackingMode: $trackingMode, annotationItems: beaconDetector.beaconSignalLevels[0..<min(beaconDetector.beaconSignalLevels.count,50)]){ beaconLevel in
                    MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(beaconLevel.latitude), longitude: CLLocationDegrees(beaconLevel.longitude))) {
                        LazyView(Circle()
                            .fill(getColor(rssi: beaconLevel.rssi))
                            .opacity(0.4)
                            .frame(width: 14.0, height: 14.0)
                            .drawingGroup()
                        )
                        .zIndex(-1)
                    }
            }
                .ignoresSafeArea()
                .accentColor(accentColor)
            VStack(alignment:.center) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(UIColor.systemBackground))
                        .opacity(0.7)
                        .frame(width: nil, height: 60, alignment: .center)
                        .blur(radius: 0.5)
                    Toggle(isOn: $showCurrentLocation) {
                        Text("Show My Location")
                            
                    }
                    .padding()
                }
                Spacer()
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(UIColor.systemBackground))
                        .opacity(0.7)
                        .frame(width: nil, height: 120, alignment: .center)
                        .blur(radius: 0.5)
                    VStack {
                        Text("Proximity: " + String(beaconDetector.lastDistance.rawValue) + "m")
                            .padding(.bottom,1)
                        Text("Accuracy: " + String(beaconDetector.lastBeaconSignal?.accuracy.magnitude.rounded(.toNearestOrAwayFromZero) ?? 0.0) + "m")
                            .padding(.bottom,1)
                        Text("RSSI: " + String(beaconDetector.lastBeaconSignal?.rssi ?? 0))
                            .padding(.bottom,1)
                    }
                }
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(UIColor.systemBackground))
                        .opacity(0.7)
                        .frame(width: nil, height: 100, alignment: .center)
                        .blur(radius: 0.5)
                    VStack {
                        Button("Clear Data") {
                            showAlert = true
                        }.alert("Are you sure you want to clear all data point?", isPresented: $showAlert){
                            Button("Yes", role: .destructive) { beaconDetector.deleteRecords()}
                        }.padding(.bottom, 5)
                        Button("Export Data",action: shareButton).padding(.bottom, 1)
                    }
                }
            }
            .padding()
        }
    }
    
    func shareButton() {
        let fileName = "export.csv"
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        var csvText = "timestamp,latitude,longitude,speed,course,proximity(m),beacon_accuracy(m),rssi\n"

        for beaconlevel in beaconDetector.beaconSignalLevels {
        csvText += "\(beaconlevel.timestamp!),\(beaconlevel.latitude),\(beaconlevel.longitude),\(beaconlevel.speed),\(beaconlevel.course),\(beaconlevel.proximity),\(beaconlevel.beacon_accuracy),\(beaconlevel.rssi)\n"
        }

        do {
            try csvText.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print("Failed to create file")
            print("\(error)")
        }
        print(path ?? "not found")

        var filesToShare = [Any]()
        filesToShare.append(path!)

        let av = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)

        UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: nil)

        showShareSheet.toggle()
        isLoading.toggle()
        }
}

struct LazyView<Content: View>: View {
    
    let build: () -> Content
    
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    
    var body: Content {
        build()
    }

}

struct BeaconMapView_Previews: PreviewProvider {
    static var previews: some View {
        BeaconMapView()
    }
}
