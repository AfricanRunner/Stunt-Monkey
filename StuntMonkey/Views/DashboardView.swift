//
//  DashboardView.swift
//  StuntMonkey
//
//  Created by Daniël du Preez on 4/17/21.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var settings: AppSettings
    @EnvironmentObject var dataStore: AWSAppSyncDataStore
    @State var ip = ""
    @State var connected = false
    
    
    var body: some View {
        if connected {
            RaspberryPiView(ip: (ip.count == 0 ? "pizero.local" : ip))
        } else {
            VStack {
                Text("To connect to you Stunt Monkey deivce enter your device's IP address. Leave blank for the default address.")
                TextField("IP", text: $ip).textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    print("Connecting!")
                    connected = true
                }) {
                    SMButton(text: "Connect")
                }
            }.frame(width: 300)
        }
    }
}

struct RaspberryPiView: View {
    @ObservedObject var pi: RaspberryPi
    @EnvironmentObject var settings: AppSettings
    @EnvironmentObject var dataStore: AWSAppSyncDataStore
    
    init(ip: String) {
        self.pi = RaspberryPi(ip: ip)
        self.pi.start()
    }
    
    var body: some View {
        switch pi.state {
        case .connecting:
            Text("Connecting...")
        case .ready:
            VStack {
                Text("Status: Ready").font(.title).multilineTextAlignment(.leading)
                Text("Your device is connected and ready to begin recording a ride!")
                Divider()
                Button("Refresh on device rides.") {
                    pi.refreshRideData()
                }
                Divider()
                ForEach(pi.rideData, id: \.id) { ride in
                    RideUploadView(ride: ride, pi: pi)
                }
                Divider()
                Button(action: {
                    pi.startRide()
                }) {
                    SMButton(text: "Start Ride")
                }
            }.frame(width: 300)
            .padding()
        case .recording:
            VStack {
                Text("Status: Recording").font(.title).multilineTextAlignment(.leading)
                Divider()
                HStack {
                    Text("Current pitch: \(String(format: "%.2f", pi.pitch))")
                    Spacer()
                    Text("Max Pitch: \(String(format: "%.2f", pi.maxPitch))")
                }
                HStack {
                    Text("Current roll: \(String(format: "%.2f", pi.roll))")
                    Spacer()
                    Text("Max roll: \(String(format: "%.2f", pi.maxRoll))")
                }
                Divider()
                HStack {
                    VStack {
                        DialView(maxAngle: Angle(degrees: pi.maxPitch), minAngle: Angle(degrees:pi.minPitch), currentAngle: Angle(degrees: pi.pitch))
                        Text("Roll")
                    }
                    VStack {
                        DialView(maxAngle: Angle(degrees: pi.maxRoll), minAngle: Angle(degrees: pi.minRoll), currentAngle: Angle(degrees: pi.roll))
                        Text("Pitch")
                    }
                }.frame(height: 400)
                
                Divider()
                Button(action: {
                    pi.stopRide()
                }) {
                    SMButton(text: "Stop Ride")
                }
            }.frame(width: 325)
            .padding()
        }
    }
}

struct RideUploadView: View {
    @EnvironmentObject var dataStore: AWSAppSyncDataStore
    @EnvironmentObject var settings: AppSettings
    
    let ride: RideData
    let pi: RaspberryPi
    
    var body: some View {
        HStack {
            VStack {
                Text("\(ride.formattedDate)")
                Text("\(ride.formattedTime)")
            }
            Spacer()
            Button("Delete") {
                pi.removeRide(ride: ride)
            }
            Button("Upload") {
                pi.removeRide(ride: ride)
                DispatchQueue.global(qos: .userInitiated).async {
                    dataStore.process(rideData: ride, for: settings.username)
                }
            }
        }
    }
}

