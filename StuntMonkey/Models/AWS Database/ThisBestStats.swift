//
//  ThisBestStats.swift
//  StuntMonkey
//
//  Created by Daniël du Preez on 4/15/21.
//

import Foundation

struct ThisBestStats {
    var longestRide: String
    var maxWheelieAngle: String
    var maxWheelieTime: String
    var statUserEmail: String
    
    init(longestRide: String, maxWheelieAngle: String, maxWheelieTime: String, statUserEmail: String) {
        self.longestRide = longestRide
        self.maxWheelieAngle = maxWheelieAngle
        self.maxWheelieTime = maxWheelieTime
        self.statUserEmail = statUserEmail
    }
    
    init(listBestStats: ListBestStatssQuery.Data.ListBestStatss) {
        self.longestRide = listBestStats.longestRide
        self.maxWheelieAngle = listBestStats.maxWheelieAngle
        self.maxWheelieTime = listBestStats.maxWheelieTime
        self.statUserEmail = listBestStats.statUserEmail
    }
    
    init(createBestStats: CreateBestStatsMutation.Data.CreateBestStat) {
        self.longestRide = createBestStats.longestRide
        self.maxWheelieAngle = createBestStats.maxWheelieAngle
        self.maxWheelieTime = createBestStats.maxWheelieTime
        self.statUserEmail = createBestStats.statUserEmail
    }
    
    func createBestStatsInput() -> CreateBestStatsInput {
        return CreateBestStatsInput(longestRide: longestRide, maxWheelieAngle: maxWheelieAngle, maxWheelieTime: maxWheelieTime, statUserEmail: statUserEmail)
    }
}
