//
//  RideDataView.swift
//  Stunt Monkey
//
//  Created by Daniël du Preez on 3/2/21.
//

import SwiftUI

struct RideDataView: View {
    var rideData: RideData
    
    var body: some View {
        VStack {
            Text("Ride data from \(rideData.formattedDate)")
            Text("Max wheelie time \(rideData.maxWheelieTime)s!")
            Text("Test")
        }
        .navigationBarTitle(Text(rideData.formattedDate), displayMode: .inline)
    }
}

struct RideDataView_Previews: PreviewProvider {
    static var previews: some View {
        RideDataView(rideData: tempRideData[0])
    }
}
