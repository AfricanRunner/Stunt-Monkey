//
//  RideData.swift
//  Stunt Monkey
//
//  Created by Daniël du Preez on 3/2/21.
//

import Foundation

struct RideData: Identifiable, Codable {
    var id: String
    var date: String
    var rideTime: Int
    var pitchData: [Double]
    var rollData: [Double]
    
    static func getFromJSON(_ json: String) -> RideData {
        let jsonData = json.data(using: .utf8)!
        let rideData = try! JSONDecoder().decode(RideData.self, from: jsonData)
        return rideData
    }
    
    func getFormattedDate(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let pureDate = dateFormatter.date(from: date)!
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = format
        return dateFormatter2.string(from: pureDate)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let pureDate = formatter.date(from: String(date.split(separator: ".")[0])) {
            let outFormatter = DateFormatter()
            outFormatter.dateStyle = .medium
    //        outFormatter.timeStyle = .medium
            return outFormatter.string(from: pureDate)
        } else {
            print("Failed to format date")
            print(date)
            return date
        }
    }
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let pureDate = formatter.date(from: String(date.split(separator: ".")[0])) {
            let outFormatter = DateFormatter()
//            outFormatter.dateStyle = .medium
            outFormatter.timeStyle = .medium
            return outFormatter.string(from: pureDate)
        } else {
            print("Failed to format date")
            print(date)
            return date
        }
    }
    
    var formattedLength: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        formatter.maximumUnitCount = 1
        return formatter.string(from: TimeInterval(Double(rideTime) / 3.0))!
    }
}
