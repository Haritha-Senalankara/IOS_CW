//
//  Customer Profile.swift
//  searchly
//
//  Created by cobsccompy4231p-007 on 2024-10-27.
//

import SwiftUI

struct Customer_Profile: View {
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
            
//            Spacer()
            
            // Profile Picture and Name Section
            VStack(spacing: 15) {
                // Profile Image
                Image(systemName: "person.circle.fill") // Placeholder image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(Color(hexValue: "#F2A213"))
                    .background(Color(hexValue: "#F9F0DC"))
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color(hexValue: "#F2A213"), lineWidth: 2))
                
                // Name and Edit Icon
                HStack(spacing: 8) {
                    Text("K H P SENALANKARA")
                        .font(.custom("Heebo-Bold", size: 18))
                        .foregroundColor(Color(hexValue: "#102A36"))
                    
                    Button(action: {
                        // Edit profile name action
                    }) {
                        Image(systemName: "pencil")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                            .foregroundColor(Color(hexValue: "#606084"))
                    }
                }
            }
            .padding(.bottom, 40)
            
            Spacer()
            
            // Logout Button
            Button(action: {
                // Logout action
            }) {
                Text("Logout")
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

// Utility to create a color from hex value
//extension Color {
//    init(hexValue: String) {
//        let scanner = Scanner(string: hexValue)
//        _ = scanner.scanString("#")
//        
//        var rgb: UInt64 = 0
//        scanner.scanHexInt64(&rgb)
//        
//        let red = Double((rgb >> 16) & 0xFF) / 255.0
//        let green = Double((rgb >> 8) & 0xFF) / 255.0
//        let blue = Double(rgb & 0xFF) / 255.0
//        
//        self.init(red: red, green: green, blue: blue)
//    }
//}

#Preview {
    Customer_Profile()
}
