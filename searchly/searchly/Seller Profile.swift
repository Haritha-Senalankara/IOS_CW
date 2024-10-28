//
//  Seller Profile.swift
//  searchly
//
//  Created by cobsccompy4231p-007 on 2024-10-27.
//

import SwiftUI

struct Seller_Profile: View {
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
            
            // Seller Logo
            Image(systemName: "person.circle.fill") // Placeholder for seller logo
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .padding(.top, 10)
            
            // Seller Information
            Text("Appleasia.lk")
                .font(.custom("Heebo-Bold", size: 20))
                .foregroundColor(Color(hexValue: "#102A36"))
                .padding(.top, 5)
            
            Text("12.0K Likes")
                .font(.custom("Heebo-Regular", size: 14))
                .foregroundColor(.gray)
                .padding(.bottom, 20)
            
            // Contact Buttons
            VStack(spacing: 15) {
                HStack(spacing: 20) {
                    ContactButton(iconName: "phone.fill", title: "Direct Call")
                    ContactButton(iconName: "message.fill", title: "WhatsApp")
                }
                HStack(spacing: 20) {
                    ContactButton(iconName: "globe", title: "Website")
                    ContactButton(iconName: "square.and.arrow.up", title: "Share")
                }
            }
            .padding(.horizontal, 20)
            
            // Seller Description
            VStack(alignment: .leading, spacing: 10) {
                Text("Apple Asia is the largest Apple Products Seller in Sri Lanka and we strive to bring the Apple products you love closer to you.")
                    .font(.custom("Heebo-Regular", size: 14))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                
                Text("info@appleasia.lk")
                    .font(.custom("Heebo-Bold", size: 14))
                    .foregroundColor(Color(hexValue: "#102A36"))
                    .padding(.horizontal, 20)
                
                Text("Brand New Apple Devices…")
                    .font(.custom("Heebo-Regular", size: 14))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
            }
            
            // Placeholder for Map
            Image(systemName: "map.fill") // Placeholder map image
                .resizable()
                .scaledToFit()
                .frame(height: 200)
                .padding(.horizontal, 20)
                .padding(.top, 10)
            
            Spacer()
            
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

// Reusable Contact Button Component
struct ContactButton: View {
    var iconName: String
    var title: String
    
    var body: some View {
        Button(action: {
            // Contact button action
        }) {
            HStack {
                Image(systemName: iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                Text(title)
                    .font(.custom("Heebo-Regular", size: 14))
                    .foregroundColor(Color(hexValue: "#102A36"))
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
}

//// Utility to create a color from hex value
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
    Seller_Profile()
}
