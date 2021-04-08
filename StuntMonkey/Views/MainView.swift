//
//  MainView.swift
//  StuntMonkey
//
//  Created by Daniël du Preez on 3/30/21.
//

import SwiftUI
import AWSMobileClient

struct MainView: View {
    @ObservedObject var settings = AppSettings()
    let signInVC: SignInViewController
    
    var body: some View {
        TabView {
            Text("Live!")
                .tabItem { Image(systemName: "gauge")
                    Text("Dashboard")
                }
            RideDataListView(rideData: tempRideData)
                .tabItem { Image(systemName: "archivebox")
                    Text("History")
                }
            Text("Social!")
                .tabItem { Image(systemName: "person.2")
                    Text("Social")
                }
            Button("Sign Out!") {
                AWSMobileClient.default().signOut()
                self.settings.username = ""
            }.tabItem { Image(systemName: "ellipsis")
                Text("Other")
            }
        }
    }
}
