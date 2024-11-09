//
//  searchlyApp.swift
//  searchly
//
//  Created by cobsccompy4231p-007 on 2024-10-27.
//

import SwiftUI
import Firebase

@main
struct searchlyApp: App {
    
    init(){
        FirebaseApp.configure()
        print("Config firebase")
    }
    var body: some Scene {
        WindowGroup {
            Splash_View()
            
        }
    }
}
