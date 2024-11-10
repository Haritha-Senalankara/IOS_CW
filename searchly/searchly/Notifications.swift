//
//  Notifications.swift
//  searchly
//
//  Created by cobsccompy4231p-007 on 2024-10-27.
//

import SwiftUI

struct Notifications: View {
    // Sample notifications data
    @State private var notifications = [
        "Price Drop Alert! Get the Apple AirPods Pro for just $199.99, down from $249.99! Limited time only.",
        "New Deal! Samsung Galaxy Watch 5 is now available at $249.99, previously $279.99. Don’t miss out!",
        "Special Offer: Save 10% on Dyson V11 Cordless Vacuum, now priced at $599.99!"
    ]
    
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
            
            // Notification List
            VStack(spacing: 0) {
                ForEach(notifications.indices, id: \.self) { index in
                    HStack {
                        Text(notifications[index])
                            .font(.custom("Heebo-Regular", size: 14))
                            .foregroundColor(Color(hexValue: "#102A36"))
                            .lineLimit(nil)
                        
                        Spacer()
                        
                        Button(action: {
                            // Remove individual notification
                            notifications.remove(at: index)
                        }) {
                            Image("tick-squrae-icon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                        }
                        .padding(.leading, 10)
                    }
                    .padding(.vertical, 15)
                    .padding(.horizontal, 20)
                    
                    Divider()
                        .background(Color.gray.opacity(0.3))
                        .padding(.leading, 20)
                }
            }
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            Spacer()
            
            // Clear All Button
            Button(action: {
                // Clear all notifications action
                notifications.removeAll()
            }) {
                Text("Clear")
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
                BottomNavItem(iconName: "home-icon", title: "Home", isActive: false)
                Spacer()
                BottomNavItem(iconName: "heart-icon", title: "Favorites", isActive: false)
                Spacer()
                BottomNavItem(iconName: "settings-icon", title: "Settings", isActive: false)
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
    Notifications()
}
