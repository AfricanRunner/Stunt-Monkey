//
//  AWSAppSyncDataStore.swift
//  StuntMonkey
//
//  Created by Daniël du Preez on 4/15/21.
//

import Foundation
import Combine
import AWSAppSync

class AWSAppSyncDataStore: ObservableObject {
    let objectWillChange = ObservableObjectPublisher()
    
    @Published var users: [ThisUser] {
        didSet {
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
    }
    
    @Published var rides: [ThisRide] {
        didSet {
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
    }
    
    @Published var bestStats: [ThisBestStats] {
        didSet {
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
    }
    
    @Published var rollDatas: [ThisRollData] {
        didSet {
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
    }
    
    @Published var pitchDatas: [ThisPitchData] {
        didSet {
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
    }
    
    let appSyncClient: AWSAppSyncClient!
    
    init() {
        self.users = []
        self.rides = []
        self.bestStats = []
        self.pitchDatas = []
        self.rollDatas = []
        
        appSyncClient = (UIApplication.shared.delegate as! AppDelegate).appSyncClient
        
        fetchAll()
    }
    
    func fetchAll() {
        fetchUsers()
        fetchRides()
        fetchBestStats()
        fetchPitchDatas()
        fetchRollDatas()
    }
    
    func process(rideData: RideData, for email: String) {
        let thisRide = ThisRide(rideId: rideData.id, rideLength: "\(rideData.rideTime)", rideDate: rideData.date, userEmail: email)
        addRide(create: thisRide)
        for i in 0..<rideData.rideTime {
            let thisRollData = ThisRollData(rollRideId: rideData.id, rollTime: "\(i)", rollAngle: "\(rideData.rollData[i])")
            let thisPitchData = ThisPitchData(pitchRideId: rideData.id, pitchTime: "\(i)", pitchAngle: "\(rideData.pitchData[i])")
            addRollData(create: thisRollData)
            addPitchData(create: thisPitchData)
        }
    }
    
    func getRideData(rideId: String) -> RideData {
        print("Getting ride data for: \(rideId)")
        let thisRide = rides.filter {$0.rideId == rideId}[0]
        var pitchData = [Double]()
        var rollData = [Double]()
        let length = Int(thisRide.rideLength)!
        for _ in 0..<length {
            pitchData.append(0)
            rollData.append(0)
        }
        for thisPitch in pitchDatas {
            if thisPitch.pitchRideId == thisRide.rideId {
                pitchData[Int(thisPitch.pitchTime)!] = Double(thisPitch.pitchAngle)!
            }
        }
        for thisRoll in rollDatas {
            if thisRoll.rollRideId == thisRide.rideId {
                rollData[Int(thisRoll.rollTime)!] = Double(thisRoll.rollAngle)!
            }
        }
        
        return RideData(id: rideId, date: thisRide.rideDate, rideTime: length, pitchData: pitchData, rollData: rollData)
    }
    
    func fetchUsers() {
        appSyncClient.fetch(query: ListUsersQuery(), cachePolicy: .returnCacheDataAndFetch) { (result, error) in
            if (error != nil) {
//                print(error?.localizedDescription ?? "")
                return
            } else {
                guard let resultUsers = result?.data?.listUsers else {
                    print("No users")
                    return
                }
//                print("users \(resultUsers)")
                
                let listUsers = resultUsers as! [ListUsersQuery.Data.ListUser]
                self.users = listUsers.map { ThisUser(listUser: $0) }
            }
        }
    }
    
    func addUser(create user: ThisUser, completionHandler: @escaping (ThisUser?) -> Void) {
        let createUserMutation = CreateUserMutation(createUserInput: user.createUserInput())
        
        appSyncClient?.perform(mutation: createUserMutation, optimisticUpdate: { readWriteTransaction in
            print("Optimistic update")
            // Optimistically consider the operation won't fail, so add into our users array
            self.users.append(user)
        },  resultHandler: { (result, error) in
            if let error = error as? AWSAppSyncClientError {
//                print("Error occurred: \(error)")
//                print("Error occurred (localized): \(error.localizedDescription )")
                completionHandler(nil)
                return
            }
            if let resultError = result?.errors {
                print("Error saving user: \(resultError)")
                self.fetchUsers()
                completionHandler(nil)
                return
            }
//            print("result \(result)")
//            print("(result) type \(type(of: result))")
            
            if let resultData = result?.data, let createdUser = resultData.createUser {
                print("User created: \(String(describing: createdUser.email))")
                let newUser = ThisUser(createUser: createdUser)
                
                // Only add new user if it wasn't added by optimistic update
                if !self.users.contains(where: { (user) -> Bool in
                    user.email == newUser.email
                }) {
                    self.users.append(newUser)
                }
                
                completionHandler(newUser)
            } else {
                self.fetchUsers()
                completionHandler(nil)
            }
        })
    }
    
    func fetchRides() {
        appSyncClient.fetch(query: ListRidesQuery(), cachePolicy: .returnCacheDataAndFetch) { (result, error) in
            if (error != nil){
//                print(error?.localizedDescription ?? "")
                return
            } else {
                guard let resultRides = result?.data?.listRides else {
                    print("No rides")
                    return
                }
//                print("rides \(resultRides)")
                
                let listRides = resultRides as! [ListRidesQuery.Data.ListRide]
                self.rides = listRides.map { ThisRide(listRide: $0) }
            }
        }
    }
    
    func addRide(create ride: ThisRide) {
        let createRideMutation = CreateRideMutation(createRideInput: ride.createRideInput())

        appSyncClient?.perform(mutation: createRideMutation, optimisticUpdate: { readWriteTransaction in
            self.rides.append(ride)
        },  resultHandler: { (result, error) in
            if let error = error as? AWSAppSyncClientError {
//                print("Error occurred: \(error)")
//                print("Error occurred (localized): \(error.localizedDescription )")
                return
            }
            if let resultError = result?.errors {
//                print("Error saving user: \(resultError)")
                self.fetchRides()
                return
            }
//            print("result \(result)")
//            print("(result) type \(type(of: result))")
            
            if let resultData = result?.data, let createdRide = resultData.createRide {
                self.rides.append(ThisRide(createRide: createdRide))
                print("Ride created: \(String(describing: createdRide.rideId))")
            } else {
                self.fetchRides()
            }
        })
    }
    
    func fetchBestStats() {
        appSyncClient.fetch(query: ListBestStatssQuery(), cachePolicy: .returnCacheDataAndFetch) { (result, error) in
            if (error != nil){
//                print(error?.localizedDescription ?? "")
                return
            } else {
                guard let resultBestStats = result?.data?.listBestStatss else {
                    print("No best stats")
                    return
                }
//                print("stats \(resultBestStats)")
                
                let listBestStats = resultBestStats as! [ListBestStatssQuery.Data.ListBestStatss]
                self.bestStats = listBestStats.map { ThisBestStats(listBestStats: $0) }
            }
        }
    }
    
    func addBestStats(create bestStats: ThisBestStats) {
        let createBestStatsMutation = CreateBestStatsMutation(createBestStatsInput: bestStats.createBestStatsInput())

        appSyncClient?.perform(mutation: createBestStatsMutation, optimisticUpdate: { readWriteTransaction in
            self.bestStats.append(bestStats)
        },  resultHandler: { (result, error) in
            if let error = error as? AWSAppSyncClientError {
//                print("Error occurred: \(error)")
//                print("Error occurred (localized): \(error.localizedDescription )")
                return
            }
            if let resultError = result?.errors {
                print("Error saving user: \(resultError)")
                self.fetchBestStats()
                return
            }
//            print("result \(result)")
//            print("(result) type \(type(of: result))")
            
            if let resultBestStats = result?.data, let createBestStats = resultBestStats.createBestStats {
                self.bestStats.append(ThisBestStats(createBestStats: createBestStats))
                print("Best Stats created: \(String(describing: createBestStats.statUserEmail))")
            } else {
                self.fetchBestStats()
            }
        })
    }
    
    func fetchRollDatas() {
        appSyncClient.fetch(query: ListRollDatasQuery(), cachePolicy: .returnCacheDataAndFetch) { (result, error) in
            if (error != nil){
//                print(error?.localizedDescription ?? "")
                return
            } else {
                guard let resultRollDatas = result?.data?.listRollDatas else {
                    print("No roll data")
                    return
                }
//                print("stats \(resultRollDatas)")
                
                let listRollDatas = resultRollDatas as! [ListRollDatasQuery.Data.ListRollData]
                self.rollDatas = listRollDatas.map { ThisRollData(listRollData: $0) }
            }
        }
    }
    
    func addRollData(create rollData: ThisRollData) {
        let createRollDataMutation = CreateRollDataMutation(createRollDataInput: rollData.createRollDataInput())

        appSyncClient?.perform(mutation: createRollDataMutation, optimisticUpdate: { readWriteTransaction in
            self.rollDatas.append(rollData)
        },  resultHandler: { (result, error) in
            if let error = error as? AWSAppSyncClientError {
//                print("Error occurred: \(error)")
//                print("Error occurred (localized): \(error.localizedDescription )")
                return
            }
            if let resultError = result?.errors {
//                print("Error saving user: \(resultError)")
                self.fetchBestStats()
                return
            }
//            print("result \(result)")
//            print("(result) type \(type(of: result))")
            
            if let resultRollDatas = result?.data, let createRollData = resultRollDatas.createRollData {
                self.rollDatas.append(ThisRollData(createRollData: createRollData))
                print("roll data created: \(String(describing: createRollData.rollRideId))")
            } else {
                self.fetchRollDatas()
            }
        })
    }
    
    func fetchPitchDatas() {
        appSyncClient.fetch(query: ListPitchDatasQuery(), cachePolicy: .returnCacheDataAndFetch) { (result, error) in
            if (error != nil){
//                print(error?.localizedDescription ?? "")
                return
            } else {
                guard let resultPitchDatas = result?.data?.listPitchDatas else {
                    print("No Pitch data")
                    return
                }
//                print("stats \(resultPitchDatas)")
                
                let listPitchDatas = resultPitchDatas as! [ListPitchDatasQuery.Data.ListPitchData]
                self.pitchDatas = listPitchDatas.map { ThisPitchData(listPitchData: $0) }
            }
        }
    }
    
    func addPitchData(create pitchData: ThisPitchData) {
        let createPitchDataMutation = CreatePitchDataMutation(createPitchDataInput: pitchData.createPitchDataInput())

        appSyncClient?.perform(mutation: createPitchDataMutation, optimisticUpdate: { readWriteTransaction in
            self.pitchDatas.append(pitchData)
        },  resultHandler: { (result, error) in
            if let error = error as? AWSAppSyncClientError {
//                print("Error occurred: \(error)")
//                print("Error occurred (localized): \(error.localizedDescription )")
                return
            }
            if let resultError = result?.errors {
//                print("Error saving user: \(resultError)")
                self.fetchBestStats()
                return
            }
//            print("result \(result)")
//            print("(result) type \(type(of: result))")
            
            if let resultPitchDatas = result?.data, let createPitchData = resultPitchDatas.createPitchData {
                self.pitchDatas.append(ThisPitchData(createPitchData: createPitchData))
                print("Pitch data created: \(String(describing: createPitchData.pitchRideId))")
            } else {
                self.fetchPitchDatas()
            }
        })
    }
}
