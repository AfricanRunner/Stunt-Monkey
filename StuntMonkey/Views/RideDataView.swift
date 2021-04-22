//
//  RideDataView.swift
//  Stunt Monkey
//
//  Created by Daniël du Preez on 3/2/21.
//

import SwiftUI

struct RideDataView: View {
    @EnvironmentObject var dataStore: AWSAppSyncDataStore
    
    var rideData: RideData
    
    var body: some View {
        VStack {
//            Text("Ride data from \(rideData.formattedDate) at \(rideData.formattedTime)")
            Text("Ride length: \(rideData.formattedLength)")
            Divider()
            Group {
                Text("Roll")
                LineGraph(dataPoints: rideData.pitchData).rotation(Angle(degrees: -180))
            }
            Divider()
            Spacer()
            Group {
                Text("Pitch")
                LineGraph(dataPoints: rideData.rollData).rotation(Angle(degrees: -180))
            }
        }
        .navigationBarTitle(Text("\(rideData.formattedDate)"), displayMode: .inline)
        .padding()
    }
}


struct LineGraph: Shape {
    var dataPoints: [Double]
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
//        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        
        let xScale = Double(rect.width) / Double(dataPoints.count)
        let yScale = Double(rect.height) / 360
        
        for i in 0..<dataPoints.count {
            path.addLine(to: CGPoint(x: Double(i) * xScale, y: Double(rect.midY) + dataPoints[dataPoints.count - i - 1] * yScale))
        }
        
        
//        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
//        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        
        return path
      }
}
