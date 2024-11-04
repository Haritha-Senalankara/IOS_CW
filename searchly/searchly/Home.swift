//
//  Home.swift
//  searchly
//
//  Created by cobsccompy4231p-007 on 2024-10-27.
//

import SwiftUI

struct Home: View {
    @State private var showPriceFilter = false
    @State private var selectedPrice: Double = 350000 // Default value
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Navigation Bar with padding to avoid camera area
            HStack {
                HStack {
                    Image("search")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                        .padding(.leading, 8)
                    
                    TextField("Search", text: .constant(""))
                        .padding(10)
                }
                .background(Color(hex: "#F7F7F7"))
                .cornerRadius(8)
                .padding(.leading, 20)
                .frame(height: 40)
                
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
            .padding(.top, 50) // Padding to avoid the camera area
            .padding(.bottom, 10)
            
            // Filter Buttons (3 Columns)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                FilterButton(iconName: "location-icon", title: "Location")
                FilterButton(iconName: "price-icon", title: "Price") {
                    showPriceFilter = true
                }
                FilterButton(iconName: "rating-icon", title: "Rating")
                FilterButton(iconName: "like-icon", title: "Likes")
                FilterButton(iconName: "app-icon-filter", title: "APP")
                FilterButton(iconName: "contact-icon", title: "Contact")
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            
            Divider()
            
            // Product Listings (2 Columns)
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ProductCard(imageName: "img-1", name: "Apple iPhone 15 Pro 128GB", siteName: "Doctormobile.lk", price: "Rs.328,200.00", likes: "1.1k", rating: "5")
                    ProductCard(imageName: "img-3", name: "Apple iPhone 15 Pro 128GB", siteName: "Appleasia.lk", price: "Rs.329,000.00", likes: "1.0k", rating: "5")
                    ProductCard(imageName: "img-1", name: "Apple iPhone 15 Pro 128GB", siteName: "Doctormobile.lk", price: "Rs.328,200.00", likes: "1.1k", rating: "5")
                    ProductCard(imageName: "img-3", name: "Apple iPhone 15 Pro 128GB", siteName: "Appleasia.lk", price: "Rs.329,000.00", likes: "1.0k", rating: "5")
                    // Add more products as needed
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
            
            // Bottom Navigation Bar
            Divider()
            HStack {
                BottomNavItem(iconName: "home-icon", title: "Home", isActive: true)
                Spacer()
                BottomNavItem(iconName: "heart-icon", title: "Favorites", isActive: false)
                Spacer()
                BottomNavItem(iconName: "settings-icon", title: "Settings", isActive: false)
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 10)
            .background(Color(hex: "#102A36")) // Dark color as per style guide
            .foregroundColor(.white)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 0)
            .padding(.bottom, 30) // Padding to ensure it doesn't overlap with the home indicator area
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
        .sheet(isPresented: $showPriceFilter) {
            PriceFilterView(selectedPrice: $selectedPrice, isPresented: $showPriceFilter)
        }
    }
}

struct PriceFilterView: View {
    @Binding var selectedPrice: Double
    @Binding var isPresented: Bool
    
    var body: some View {

        VStack(spacing: 20) {
            Text("Price \(Int(selectedPrice))")
                .font(.custom("Heebo-Regular", size: 18))
                .padding(.top, 20)
            
            Slider(value: $selectedPrice, in: 0...1000000, step: 10000)
                .accentColor(Color(hex: "#F2A213"))
                .padding(.horizontal, 20)
            
            Button(action: {
                // Apply action
                isPresented = false
            }) {
                Text("Apply")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "#F2A213"))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .padding(.bottom, 30)
        .background(Color.white)
        .cornerRadius(12)
        
    }
}

/**
 
 // Reusable Filter Button Component
 struct FilterButton: View {
     var iconName: String
     var title: String
     var action: (() -> Void)? = nil

     var body: some View {
         Button(action: {
             action?()
         }) {
             HStack {
                 Image(iconName)
                     .resizable()
                     .scaledToFit()
                     .frame(width: 16, height: 16)
                 Text(title)
                     .font(.custom("Heebo-Regular", size: 12))
             }
             .padding(10)
             .frame(maxWidth: .infinity)
             .background(Color(hex: "#F7F7F7"))
             .cornerRadius(8)
         }
     }
 }

 */

// Reusable Filter Button Component
struct FilterButton: View {
    var iconName: String
    var title: String
    var action: (() -> Void)? = nil
    var body: some View {
        Button(action:{action?()})
        
        {
        HStack {
            Image(iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)
            Text(title)
                .font(.custom("Heebo-Regular", size: 12))
                .foregroundStyle(.black)
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .background(Color(hex: "#F7F7F7"))
        .cornerRadius(8)
    }}
}

// Reusable Product Card Component
struct ProductCard: View {
    var imageName: String
    var name: String
    var siteName: String
    var price: String
    var likes: String
    var rating: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 120)
                .cornerRadius(8)
            
            Text(name)
                .font(.custom("Heebo-Bold", size: 14))
                .foregroundColor(.black)
                .lineLimit(2)
            
            HStack(){
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height:20)
                Text(siteName)
                    .font(.custom("Heebo-Regular", size: 12))
                    .foregroundColor(.gray)
            }
            
            Text(price)
                .font(.custom("Heebo-Bold", size: 14))
                .foregroundColor(Color(hex: "#F2A213"))
            
            HStack() {
                HStack(spacing: 5) {
                    Image("like-icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12.9, height: 15)
                    Text(likes)
                        .font(.custom("Heebo-Regular", size: 12))
                }
                .frame(width: 60,height: 30)
                .background(Color.white)
                .cornerRadius(8)
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                
                HStack(spacing: 5) {
                    Image("rating-icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12.9, height: 15)
                        
                    Text(rating)
                        .font(.custom("Heebo-Regular", size: 12))
                }
                .frame(width: 60,height: 30)
                .background(Color.white)
                .cornerRadius(8)
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// Reusable Bottom Navigation Item Component
struct BottomNavItem: View {
    var iconName: String
    var title: String
    var isActive: Bool
    
    var body: some View {
        VStack {
            Image(iconName)
                .resizable()
                .scaledToFit()
                .frame(width: isActive ? 24 : 20, height: isActive ? 24 : 20) // Adjusted size for active/inactive state
                .foregroundColor(isActive ? Color(hex: "#F2A213") : .white)
            Text(title)
                .font(.custom("Heebo-Regular", size: 10))
                .padding(.top, 2)
                .foregroundColor(isActive ? Color(hex: "#F2A213") : .white)
        }
    }
}

// Utility to create a color from hex value
//extension Color {
//    init(hexValue: String) {
//        let scanner = Scanner(string: hex)
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
    Home()
}
