//
//  Product Page.swift
//  searchly
//
//  Created by cobsccompy4231p-007 on 2024-10-27.
//

import SwiftUI

struct Product_Page: View {
    @State private var isExpanded: Bool = false

    var body: some View {
        ZStack {
            ScrollView {
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
                    
                    // Product Image
                    Image("img-1")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 250)
                        .padding(.horizontal, 20)
                    
                    // Product Info Section
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Apple iPhone 15 Pro 128GB")
                                .font(.custom("Heebo-Bold", size: 18))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            Image("heart-icon-only-border")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                        }
                        
                        HStack {
                            HStack {
                                Image("store-img-product") // Placeholder or your store image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                
                                Text("Appleasia.lk")
                                    .font(.custom("Heebo-Regular", size: 12))
                                    .foregroundColor(.gray)
                                
                                Text("12.0K")
                                    .font(.custom("Heebo-Regular", size: 12))
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Text("Rs.329,000.00")
                                .font(.custom("Heebo-Bold", size: 16))
                                .foregroundColor(Color(hexValue: "#F2A213"))
                        }
                        
                        // Horizontal Scroll for Action Buttons
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                IconActionButton(iconName: "like-icon-product", label: "652")
                                IconActionButton(iconName: "dislike-icon-product", label: "")
                                IconActionButton(iconName: "share-icon-product", label: "Share")
                                IconActionButton(iconName: "star-icon-product", label: "5.0")
                                IconActionButton(iconName: "calander-icon-product", label: "Remind")
                            }
                            .padding(.top, 5)
                        }
                        
                        // Product Description (Expandable)
                        Text("iPhone 15 Pro is the first iPhone to feature an aerospace-grade titanium design, using the same alloy that spacecraft use for missions to Mars.\n\nTitanium has one of the best strength-to-weight ratios of any metal, making these our lightest Pro models ever.")
                            .font(.custom("Heebo-Regular", size: 14))
                            .foregroundColor(.gray)
                            .lineLimit(isExpanded ? nil : 10)
                            .onTapGesture {
                                withAnimation {
                                    isExpanded.toggle()
                                }
                            }
                            .padding(.top, 10)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    
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
                }
            }
            .background(Color.white)
            .edgesIgnoringSafeArea(.all)
            
            // Fixed Bottom Navigation Bar
            VStack {
                Spacer()
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
                .edgesIgnoringSafeArea(.bottom)
            }
        }
    }
}

// Reusable Icon Button Component for Product Actions
struct IconActionButton: View {
    var iconName: String
    var label: String
    
    var body: some View {
        HStack(spacing: 5) {
            Image(iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18) // Adjust icon size for consistency
            if !label.isEmpty {
                Text(label)
                    .font(.custom("Heebo-Regular", size: 12))
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

//// Reusable Product Card for Related Products
//struct ProductCard: View {
//    var imageName: String
//    var productName: String
//    var price: String
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 5) {
//            Image(imageName)
//                .resizable()
//                .scaledToFit()
//                .frame(height: 150)
//                .cornerRadius(10)
//            
//            Text(productName)
//                .font(.custom("Heebo-Regular", size: 14))
//                .foregroundColor(.black)
//            
//            Text(price)
//                .font(.custom("Heebo-Bold", size: 14))
//                .foregroundColor(Color(hexValue: "#F2A213"))
//        }
//        .frame(width: 150)
//        .background(Color.white)
//        .cornerRadius(12)
//        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
//    }
//}

// Utility to create a color from hex value
extension Color {
    init(hexValue: String) {
        let scanner = Scanner(string: hexValue)
        _ = scanner.scanString("#")
        
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        
        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}


#Preview {
    Product_Page()
}
