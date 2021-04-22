//
//  RideDataListView.swift
//  Stunt Monkey
//
//  Created by Daniël du Preez on 3/2/21.
//

import SwiftUI

struct RideDataListView: View {
    @EnvironmentObject var dataStore: AWSAppSyncDataStore
    @ObservedObject var settings: AppSettings
    
    var body: some View {
        NavigationView {
            List(dataStore.rides.filter {$0.userEmail == settings.username}, id: \.rideId) { ride in
                NavigationLink( destination: RideDataView(rideData: dataStore.getRideData(rideId: ride.rideId))) {
                    RideDataRow(rideData: ride)
                }
            }.navigationBarTitle("Ride History", displayMode: .inline)
        }
    }
}

struct RideDataRow: View {
    @EnvironmentObject var dataStore: AWSAppSyncDataStore
    
    var rideData: ThisRide
    
    var body: some View {
        let data = dataStore.getRideData(rideId: rideData.rideId)
        Text("\(data.formattedDate) at \(data.formattedTime)")
    }
}
