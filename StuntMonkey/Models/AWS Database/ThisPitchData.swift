//
//  ThisPitchData.swift
//  StuntMonkey
//
//  Created by Daniël du Preez on 4/15/21.
//

import Foundation

struct ThisPitchData {
    var pitchRideId: String
    var pitchTime: String
    var pitchAngle: String
    
    init(pitchRideId: String, pitchTime: String, pitchAngle: String) {
        self.pitchRideId = pitchRideId
        self.pitchTime = pitchTime
        self.pitchAngle = pitchAngle
    }
    
    init(listPitchData: ListPitchDatasQuery.Data.ListPitchData) {
        self.pitchRideId = listPitchData.pitchRideId
        self.pitchTime = listPitchData.pitchTime
        self.pitchAngle = listPitchData.pitchAngle
    }
    
    init(createPitchData: CreatePitchDataMutation.Data.CreatePitchDatum) {
        self.pitchRideId = createPitchData.pitchRideId
        self.pitchTime = createPitchData.pitchTime
        self.pitchAngle = createPitchData.pitchAngle
    }
    
    func createPitchDataInput() -> CreatePitchDataInput {
        return CreatePitchDataInput(pitchRideId: pitchRideId, pitchTime: pitchTime, pitchAngle: pitchAngle)
    }
}
