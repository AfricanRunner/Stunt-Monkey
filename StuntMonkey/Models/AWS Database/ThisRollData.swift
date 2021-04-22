//
//  ThisRollData.swift
//  StuntMonkey
//
//  Created by Daniël du Preez on 4/15/21.
//

import Foundation

struct ThisRollData {
    var rollRideId: String
    var rollTime: String
    var rollAngle: String
    
    init(rollRideId: String, rollTime: String, rollAngle: String) {
        self.rollRideId = rollRideId
        self.rollTime = rollTime
        self.rollAngle = rollAngle
    }
    
    init(listRollData: ListRollDatasQuery.Data.ListRollData) {
        self.rollRideId = listRollData.rollRideId
        self.rollTime = listRollData.rollTime
        self.rollAngle = listRollData.rollAngle
    }
    
    init(createRollData: CreateRollDataMutation.Data.CreateRollDatum) {
        self.rollRideId = createRollData.rollRideId
        self.rollTime = createRollData.rollTime
        self.rollAngle = createRollData.rollAngle
    }
    
    func createRollDataInput() -> CreateRollDataInput {
        return CreateRollDataInput(rollRideId: rollRideId, rollTime: rollTime, rollAngle: rollAngle)
    }
}
