//
//  MainView.swift
//  StuntMonkey
//
//  Created by Daniël du Preez on 3/30/21.
//

import SwiftUI
import AWSMobileClient

struct MainView: View {
    @ObservedObject var settings: AppSettings
    @EnvironmentObject var dataStore: AWSAppSyncDataStore
    
    
    let signInVC: SignInViewController
    
    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Image(systemName: "gauge")
                    Text("Dashboard")
                }
            RideDataListView(settings: settings).navigationTitle("Ride Data")
                .tabItem { Image(systemName: "archivebox")
                    Text("History")
                }
//            Text("Social!")
//                .tabItem { Image(systemName: "person.2")
//                    Text("Social")
//                }
            Button(action: {
                AWSMobileClient.default().signOut()
                self.settings.username = ""
            }) {
                SMButton(text: "Sign Out")
            }.tabItem {
                //HStack{
                Image(systemName: "ellipsis")
                Text("Other")
                    //Text("Other")
//                }
            }
        }
    }
}
