//
//  RideData.swift
//  Stunt Monkey
//
//  Created by Daniël du Preez on 3/2/21.
//

import Foundation

let tempRideData = [RideData(id: 0, date: Date(), rideTime: 15, pitchData: [], rollData: []), RideData(id: 1, date: Date(timeIntervalSince1970: 1000000000), rideTime: 27, pitchData: [], rollData: [])]

struct RideData: Identifiable, Codable {
    
    var id: Int
    var date: Date
    var rideTime: Int
    var pitchData: [Double]
    var rollData: [Double]
    
    static let smallestWheelieAngle: Double = 45
    static let timePerMeasurement: Double = 1
    
    var maxWheelieTime: Double {
        var maxTime = 0
        var currentTime = 0
        for pitch in pitchData {
            if pitch >= RideData.smallestWheelieAngle {
                currentTime += 1
            } else {
                if currentTime > maxTime {
                    maxTime = currentTime
                }
                currentTime = 0
            }
        }
        return Double(maxTime) * RideData.timePerMeasurement
    }
    
    var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        return dateFormatter.string(from: date)
    }
}
