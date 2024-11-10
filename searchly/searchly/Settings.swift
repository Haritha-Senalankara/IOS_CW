//
//  Settings.swift
//  searchly
//
//  Created by cobsccompy4231p-007 on 2024-10-27.
//

import SwiftUI

struct Settings: View {
    @State private var isNotificationEnabled: Bool = true
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Navigation Bar
            HStack {
                Button(action: {
                    // Back action
                }) {
                    Image(systemName: "arrow.left")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.black)
                }
                .padding(.leading, 20)
                
                Spacer()
                
                Image("notification-icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .padding(.trailing, 15)
                
                Image("profile-icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .padding(.trailing, 20)
            }
            .padding(.top, 50)
            .padding(.bottom, 10)
            
            // Settings Title
            Text("Settings")
                .font(.custom("Heebo-Bold", size: 18))
                .foregroundColor(Color(hexValue: "#606084"))
                .padding(.top, 10)
                .padding(.bottom, 20)
            
            // Settings Options
            VStack(spacing: 0) {
                HStack {
                    Image("notification-normal")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    
                    Text("Notification")
                        .font(.custom("Heebo-Regular", size: 16))
                        .foregroundColor(.black)
                        .padding(.leading, 10)
                    
                    Spacer()
                    
                    if isNotificationEnabled {
                        Image("tick-squrae-icon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                    }
                }
                .padding(.vertical, 15)
                .padding(.horizontal, 20)
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                    .padding(.leading, 20)
                
                HStack {
                    Image("shield-icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    
                    Text("Privacy Policy")
                        .font(.custom("Heebo-Regular", size: 16))
                        .foregroundColor(.black)
                        .padding(.leading, 10)
                    
                    Spacer()
                }
                .padding(.vertical, 15)
                .padding(.horizontal, 20)
            }
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            Spacer()
            
            // Save Button
            Button(action: {
                // Save action
            }) {
                Text("Save")
                    .font(.custom("Heebo-Bold", size: 16))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hexValue: "#F2A213"))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
            
            // Bottom Navigation Bar
            Divider()
            HStack {
                NavigationLink(destination: Home()) {
                    BottomNavItem(iconName: "home-icon", title: "Home", isActive: false)
                    }
                
                    //add nav here
                Spacer()
                NavigationLink(destination: Wishlist()) {
                        BottomNavItem(iconName: "heart-icon", title: "Favorites", isActive: false)
                    }
                Spacer()
                NavigationLink(destination: Settings()) {
                        BottomNavItem(iconName: "settings-icon", title: "Settings", isActive: true)
                    }
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 10)
            .background(Color(hexValue: "#102A36")) // Dark color as per style guide
            .foregroundColor(.white)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 0)
            .padding(.bottom, 20) // Padding to ensure it doesn't overlap with the home indicator area
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
    }
}



#Preview {
    Settings()
}
