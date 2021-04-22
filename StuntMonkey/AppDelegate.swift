//
//  AppDelegate.swift
//  StuntMonkey
//
//  Created by Daniël du Preez on 3/28/21.
//

import UIKit
import AWSMobileClient
import AWSAppSync

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    public var appSyncClient: AWSAppSyncClient!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        initializeAWSMobileClient()
        initializeAWSAppSync()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // MARK: Initialize the AWS AppSync client
    func initializeAWSAppSync(){
        do {
            // Create a URL to pass to cache config below
            let offlineMutationsCacheUrl = self.getDocumentsDirectory().appendingPathComponent("offlineMutationsCache")
            let queriesCacheUrl = self.getDocumentsDirectory().appendingPathComponent("queriesCache")
            
            // Need to create a cache configuration to save offline mutations
            let cacheConfig = AWSAppSyncCacheConfiguration(offlineMutations: offlineMutationsCacheUrl, queries: queriesCacheUrl, subscriptionMetadataCache: nil)
            let appSyncConfig = try AWSAppSyncClientConfiguration(appSyncServiceConfig: AWSAppSyncServiceConfig(), cacheConfiguration: cacheConfig)
            
            appSyncClient = try AWSAppSyncClient(appSyncConfig: appSyncConfig)
            
            // Check if we have any queued mutations in the case we were offline
            print("appSyncClient.queuedMutationCount \(appSyncClient.queuedMutationCount)")
            
            
        } catch {
            print("Error initializing AppSync client. \(error)")
            appSyncClient = nil
        }
    }
    
    // MARK: Getting documents directory from File Manager
    func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        // just send back the first one, which ought to be the only one
        return paths[0]
    }
    
    func initializeAWSMobileClient(){
        AWSMobileClient.default().initialize { (userState, error) in
            if let error = error {
                print("Error initializing AWSMobileClient: \(error.localizedDescription)")
            } else if let userState = userState {
                print("AWSMobileClient initialized. Current UserState: \(userState.rawValue)")
            }
        }
     }


}

