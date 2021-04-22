//
//  RaspberryPi.swift
//  StuntMonkey
//
//  Created by Daniël du Preez on 4/18/21.
//

import Foundation
import Network
import SwiftUI
import Combine

class InputStream {
    private var connection: NWConnection?
    private var listener: NWListener?
    private static let port: NWEndpoint.Port = 8046
    private var inputHandler: (String) -> Void
    
    init(handler: @escaping (String) -> Void) {
        self.inputHandler = handler
    }
    
    func start() {
        self.listener = try? NWListener(using: .tcp, on: InputStream.port)
        if listener == nil {
            print("failed to make lisenter!")
        }
        listener?.newConnectionHandler = self.setupConnection
        listener?.start(queue: .global())
    }
    
    func stop() {
        self.connection?.cancel()
        self.listener?.cancel()
    }
    
    private func setupConnection(connection: NWConnection) {
        connection.receiveMessage { data, context, bool, error in
            if let data = data {
                self.inputHandler(String(decoding: data, as: UTF8.self))
            } else {
                print("Error handling input data")
            }
        }
        connection.start(queue: .global())
    }
    
    var status: String {
        if let connection = connection {
            return "\(connection.state)"
        }
        return "Connection not started!"
    }
}

class UDPInputStream {
    private var connection: NWConnection?
    private var listener: NWListener?
    private static let port: NWEndpoint.Port = 8047
    private var inputHandler: (String) -> Void
    
    init(handler: @escaping (String) -> Void) {
        self.inputHandler = handler
    }
    
    func start() {
        self.listener = try? NWListener(using: .udp, on: UDPInputStream.port)
        listener?.newConnectionHandler = self.setupConnection
        listener?.start(queue: .global())
    }
    
    func stop() {
        self.connection?.cancel()
        self.listener?.cancel()
    }
    
    private func setupConnection(connection: NWConnection) {
        connection.receiveMessage { data, context, bool, error in
            if let data = data {
                self.inputHandler(String(decoding: data, as: UTF8.self))
            } else {
                print("Error handling input data")
            }
        }
        connection.start(queue: .global())
    }
    
    var status: String {
        if let connection = connection {
            return "\(connection.state)"
        }
        return "Connection not started!"
    }
}

class OutputStream {
    private var connection: NWConnection?
    private let host: NWEndpoint.Host
    private static let port: NWEndpoint.Port = 8045
    
    init(ip: String) {
        host = NWEndpoint.Host(ip)
    }
    
    func sendData(data: String) {
        connection = NWConnection(host: host, port: OutputStream.port, using: .tcp)
        connection?.start(queue: .global())
        connection?.send(content: data.data(using: .utf8), completion: .contentProcessed( { error in
            self.connection?.cancel()
        }))
    }
    
    var status: String {
        if let connection = connection {
            return "\(connection.state)"
        }
        return "Nil"
    }
}

enum piStatus {
    case connecting
    case ready
    case recording
}

class RaspberryPi: ObservableObject {
//    let objectWillChange = ObservableObjectPublisher()
    lazy private var input = InputStream(handler: self.handle)
    lazy private var udpInput = UDPInputStream(handler: self.udpHandle)
    private var output: OutputStream
    private var outputHandler: (String) -> Void
    @Published private(set) var state: piStatus = .connecting
    @Published private(set) var rideData: [RideData]
    @Published private(set) var pitch: Double = 0 {
        didSet {
            if pitch > maxPitch {
                maxPitch = pitch
            }
            if pitch < minPitch {
                minPitch = pitch
            }
        }
    }
    @Published private(set) var roll: Double = 0 {
        didSet {
            if roll > maxRoll {
                maxRoll = roll
            }
            if roll < minRoll {
                minRoll = roll
            }
        }
    }
    @Published private(set) var maxPitch: Double = 0
    @Published private(set) var minPitch: Double = 0
    @Published private(set) var maxRoll: Double = 0
    @Published private(set) var minRoll: Double = 0
    
    init(ip: String) {
        rideData = [RideData]()
        output = OutputStream(ip: ip)
        outputHandler = { str in

        }
    }
    
    func start() {
//        DispatchQueue.global(qos: .userInitiated).async {
            self.input.start()
            self.udpInput.start()
            self.output.sendData(data: "ping")
//        }
    }
    
    func popRide() -> RideData? {
        if rideData.count == 0 {
            return nil
        } else {
            return rideData.removeLast()
        }
    }
    
    func hasRides() -> Bool {
        return rideData.count != 0
    }
    
    func startRide() {
        self.run(command: "start_ride") { output in
            if output == "Starting ride..." {
                DispatchQueue.main.async {
                    self.state = .recording
                }
            }
            
        }
    }
    
    func stopRide() {
        self.run(command: "stop_ride") { output in
            if output == "Stopped ride." {
                DispatchQueue.main.async {
                    self.state = .ready
                }
            }
        }
    }
    
    func refreshRideData() {
//        DispatchQueue.global(qos: .userInitiated).async {
        print("Refreshing ride data!")
        self.run(command: "list_rides") { output in
            print("Got result \(output)")
            var rideList = [String]()
            for ride in output.split(separator: ",") {
                rideList.append(ride.replacingOccurrences(of: "[", with: "")
                                    .replacingOccurrences(of: "]", with: "")
                                    .replacingOccurrences(of: "\'", with: ""))
            }
            if rideList[0] != "" {
                for ride in rideList {
                    print("Getting ride \(ride)")
                    self.run(command: "get_ride \(ride)") { output in
                        print("Got ride data \(output)")
                        DispatchQueue.main.async {
                            self.rideData += [RideData.getFromJSON(output)]
                        }
                        print("Deleting ride \(ride)")
                        self.run(command: "delete_ride \(ride)") { output in
                            if output != "Deleted file." {
                                print("Error deleting file!")
                            }
                        }
                    }
                }
            }
//        }
        }
    }
    
    func end() {
        input.stop()
    }
    
    func removeRide(ride: RideData) {
        var index = 0
        for i in 0..<rideData.count {
            if rideData[i].id == ride.id {
                index = i
            }
        }
        rideData.remove(at: index)
    }
    
    private func handle(data: String) {
        if data == "pong" {
            DispatchQueue.main.async {
                self.state = .ready
            }
        }
        let handler = self.outputHandler
        self.outputHandler = { str in
            
        }
        handler(data)
    }
    
    private func udpHandle(data: String) {
        let list = data.split(separator: " ")
        DispatchQueue.main.async {
            self.pitch = Double(list[0])!
            self.roll = Double(list[1])!
        }
    }
    
    private func run(command: String, handler: @escaping (String) -> Void) {
        outputHandler = handler
        output.sendData(data: command)
    }
}
