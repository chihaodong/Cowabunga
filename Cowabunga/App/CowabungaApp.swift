//
//  CowabungaApp.swift
//  Cowabunga
//
//  Created by lemin on 1/3/23.
//

import SwiftUI

@main
struct CowabungaApp: App {
    //let locationManager = LocationManager()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var sourceRepoFetcher = SourcedRepoFetcher()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(sourceRepoFetcher)
                .onAppear {
                    if #available(iOS 16.2, *) {
                        #if targetEnvironment(simulator)
                        #else
                        UIApplication.shared.alert(title: "Not Supported", body: "This version of iOS is not supported.")
                        #endif
                    } else {
                        do {
                            // TrollStore method
                            try FileManager.default.contentsOfDirectory(at: URL(fileURLWithPath: "/var/mobile/Library/Caches"), includingPropertiesForKeys: nil)
                        } catch {
                            // MDC method
                            // grant r/w access
                            if #available(iOS 15, *) {
                                grant_full_disk_access() { error in
                                    if (error != nil) {
                                        UIApplication.shared.alert(title: "Access Error", body: "Error: \(String(describing: error?.localizedDescription))\nPlease close the app and retry.")
                                    }
                                }
                            } else {
                                UIApplication.shared.alert(title: "MDC Not Supported", body: "Please install via TrollStore")
                            }
                        }
                    }
                    // credit: TrollTools
                    if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, let url = URL(string: "https://api.github.com/repos/leminlimez/Cowabunga/releases/latest") {
                        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
                            guard let data = data else { return }
                            
                            if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                                if (json["tag_name"] as? String)?.replacingOccurrences(of: "v", with: "").compare(version, options: .numeric) == .orderedDescending {
                                    UIApplication.shared.confirmAlert(title: "Update available", body: "A new Cowabunga update is available, do you want to visit releases page?", onOK: {
                                        UIApplication.shared.open(URL(string: "https://github.com/leminlimez/Cowabunga/releases/latest")!)
                                    }, noCancel: false)
                                }
                            }
                        }
                        task.resume()
                    }
                    AudioFiles.setup(fetchingNewAudio: UserDefaults.standard.bool(forKey: "AutoFetchAudio"))
                    //LockManager.setup(fetchingNewLocks: UserDefaults.standard.bool(forKey: "AutoFetchLocks"))
                    if UserDefaults.standard.bool(forKey: "BackgroundApply") == true {
                        ApplicationMonitor.shared.start()
                    }
                }
        }
    }
}
