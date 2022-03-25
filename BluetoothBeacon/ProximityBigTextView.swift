//
//  ProximityBigTextView.swift
//  BluetoothBeacon
//
//  Created by Aung Yee on 18/03/2022.
//

import SwiftUI

struct BigText: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(Font.system(size: 72))
            .foregroundColor(Color.white)
            .frame(minWidth:0, maxWidth: .infinity, minHeight: 0,maxHeight: .infinity)
            .edgesIgnoringSafeArea(.all)
    }
}

struct ProximityBigTextView: View {
    
    @ObservedObject var detector = BeaconDetector()
    
    var body: some View {
        if detector.lastDistance == .immediate {
            Text("Right Here")
                .modifier(BigText())
                .background(Color.green)
        } else if detector.lastDistance == .near {
            Text("Near")
                .modifier(BigText())
                .background(Color.orange)
        } else if detector.lastDistance == .far {
            Text("Far")
                .modifier(BigText())
                .background(Color.red)
        } else{
            Text("Unknown")
                .modifier(BigText())
                .background(Color.black)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ProximityBigTextView()
    }
}
