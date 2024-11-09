//
//  Wishlist.swift
//  searchly
//
//  Created by cobsccompy4231p-007 on 2024-10-27.
//

import SwiftUI

struct Wishlist: View {
    // Sample data for the wishlist
    var products = [
        Product(image: "img-1", name: "Apple iPhone 15 Pro 128GB", storeName: "Doctormobile.lk", price: "Rs.328,200.00", likes: "1.1k", rating: "5"),
        Product(image: "img-2", name: "Apple iPhone 15 Pro 128GB", storeName: "Appleasia.lk", price: "Rs.329,000.00", likes: "1.0k", rating: "5")
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
            
            Spacer()
            
            // Product Listings (2 Columns)
//            ScrollView {
//                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
//                    ProductCard(imageName: "img-1", name: "Apple iPhone 15 Pro 128GB", siteName: "Doctormobile.lk", price: "Rs.328,200.00", likes: "1.1k", rating: "5")
//                    ProductCard(imageName: "img-3", name: "Apple iPhone 15 Pro 128GB", siteName: "Appleasia.lk", price: "Rs.329,000.00", likes: "1.0k", rating: "5")
//                    ProductCard(imageName: "img-1", name: "Apple iPhone 15 Pro 128GB", siteName: "Doctormobile.lk", price: "Rs.328,200.00", likes: "1.1k", rating: "5")
//                    ProductCard(imageName: "img-3", name: "Apple iPhone 15 Pro 128GB", siteName: "Appleasia.lk", price: "Rs.329,000.00", likes: "1.0k", rating: "5")
//                    // Add more products as needed
//                }
//                .padding(.horizontal, 20)
//                .padding(.top, 10)
//            }
            
            Spacer()
            
            // Bottom Navigation Bar
            Divider()
            HStack {
                BottomNavItem(iconName: "home-icon", title: "Home", isActive: false)
                Spacer()
                BottomNavItem(iconName: "heart-icon", title: "Favorites", isActive: true)
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

// Product model
struct Product: Identifiable {
    var id = UUID()
    var image: String
    var name: String
    var storeName: String
    var price: String
    var likes: String
    var rating: String
}



// Reusable component for icons with info (like and rating)
struct IconInfoView: View {
    var iconName: String
    var text: String
    
    var body: some View {
        HStack(spacing: 5) {
            Image(iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 14, height: 14)
            Text(text)
                .font(.custom("Heebo-Regular", size: 12))
                .foregroundColor(.gray)
        }
    }
}



#Preview {
    Wishlist()
}
