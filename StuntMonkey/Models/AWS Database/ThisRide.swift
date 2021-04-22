//
//  ThisRide.swift
//  StuntMonkey
//
//  Created by Daniël du Preez on 4/15/21.
//

import Foundation

struct ThisRide {
    let rideId: String
    var rideLength: String
    var rideDate: String
    var userEmail: String
    
    init(rideId: String, rideLength: String, rideDate: String, userEmail: String) {
        self.rideId = rideId
        self.rideLength = rideLength
        self.rideDate = rideDate
        self.userEmail = userEmail
    }
    
    init(listRide: ListRidesQuery.Data.ListRide) {
        self.rideId = listRide.rideId
        self.rideLength = listRide.rideLength
        self.rideDate = listRide.rideDate
        self.userEmail = listRide.userEmail
    }
    
    init(createRide: CreateRideMutation.Data.CreateRide) {
        self.rideId = createRide.rideId
        self.rideLength = createRide.rideLength
        self.rideDate = createRide.rideDate
        self.userEmail = createRide.userEmail
    }
    
    func createRideInput() -> CreateRideInput {
        return CreateRideInput(rideId: rideId, rideDate: rideDate, rideLength: rideLength, userEmail: userEmail)
    }
}
