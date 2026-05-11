//
//  LifeCounterFromScratchT1App.swift
//  LifeCounterFromScratchT1
//
//  Created by Alex Russello on 12/3/23.
//

import SwiftUI
import GoogleMobileAds

@main
struct LifeCounterFromScratchT1App: App {
    init() {
        MobileAds.shared.start()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
