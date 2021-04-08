//
//  RideDataListView.swift
//  Stunt Monkey
//
//  Created by Daniël du Preez on 3/2/21.
//

import SwiftUI

struct RideDataListView: View {
    var rideData: [RideData]
    
    var body: some View {
        Group {
            List(rideData) { data in
                NavigationLink( destination: RideDataView(rideData: data)) {
                    RideDataRow(rideData: data)
                }
            }
        }.navigationBarTitle(Text("Ride Data"))
    }
}

struct RideDataRow: View {
    var rideData: RideData
    
    var body: some View {
        Text("\(rideData.formattedDate)")
    }
}

struct RideDataListView_Previews: PreviewProvider {
    static var previews: some View {
        RideDataListView(rideData: tempRideData)
    }
}
