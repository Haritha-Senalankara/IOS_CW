//
//  Home.swift
//  searchly
//
//  Created by cobsccompy4231p-007 on 2024-10-27.
//

import SwiftUI
import FirebaseFirestore

struct Products: Identifiable {
    var id: String
    var name: String
    var price: Double
    var siteName: String
    var likes: Int
    var dislikes: Int
    var rating: Double
    var categories: [String]
    var imageName: String // Includes fallback for missing images
}

// MARK: - Product ViewModel
class ProductViewModel: ObservableObject {
    @Published var products: [Products] = []
    
    private let db = Firestore.firestore()
    
    func fetchProducts() {
        db.collection("products").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching products: \(error)")
                return
            }

            self.products = snapshot?.documents.compactMap { document in
                let data = document.data()
                guard let name = data["name"] as? String,
                      let price = data["price"] as? Double,
                      let likes = data["likes"] as? Int,
                      let dislikes = data["dislikes"] as? Int,
                      let rating = data["rating"] as? Double,
                      let categories = data["categories"] as? [String] else {
                    return nil
                }

                let imageName = data["imageName"] as? String ?? "img-1" // Fallback to default image

                return Products(
                    id: document.documentID,
                    name: name,
                    price: price,
                    siteName: "Doctormobile.lk", // Placeholder for missing siteName
                    likes: likes,
                    dislikes: dislikes,
                    rating: rating,
                    categories: categories,
                    imageName: imageName
                )
            } ?? []
        }
    }
}

struct Home: View {
    @StateObject private var viewModel = ProductViewModel()
    @State private var showPriceFilter = false
    @State private var selectedPrice: Double = 350000 // Default value
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Navigation Bar
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
            .padding(.top, 50)
            .padding(.bottom, 10)
            
            // Filter Buttons
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
            
            // Product Listings
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(viewModel.products) { product in
                        ProductCard(
                            imageName: product.imageName,
                            name: product.name,
                            siteName: product.siteName,
                            price: "Rs.\(Int(product.price))",
                            likes: "\(product.likes)",
                            rating: "\(product.rating)"
                        )
                    }
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
            .background(Color(hex: "#102A36"))
            .foregroundColor(.white)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 0)
            .padding(.bottom, 30)
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
        .sheet(isPresented: $showPriceFilter) {
            PriceFilterView(selectedPrice: $selectedPrice, isPresented: $showPriceFilter)
        }
        .onAppear {
            viewModel.fetchProducts()
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

// MARK: - FilterButton
struct FilterButton: View {
    var iconName: String
    var title: String
    var action: (() -> Void)? = nil
    var body: some View {
        Button(action: { action?() }) {
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
        }
    }
}

// MARK: - ProductCard
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
            
            Text(siteName)
                .font(.custom("Heebo-Regular", size: 12))
                .foregroundColor(.gray)
            
            Text(price)
                .font(.custom("Heebo-Bold", size: 14))
                .foregroundColor(Color(hex: "#F2A213"))
            
            HStack {
                HStack(spacing: 5) {
                    Image("like-icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12.9, height: 15)
                    Text(likes)
                        .font(.custom("Heebo-Regular", size: 12))
                }
                .frame(width: 60, height: 30)
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
                .frame(width: 60, height: 30)
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

// MARK: - BottomNavItem
struct BottomNavItem: View {
    var iconName: String
    var title: String
    var isActive: Bool
    
    var body: some View {
        VStack {
            Image(iconName)
                .resizable()
                .scaledToFit()
                .frame(width: isActive ? 24 : 20, height: isActive ? 24 : 20)
                .foregroundColor(isActive ? Color(hex: "#F2A213") : .white)
            Text(title)
                .font(.custom("Heebo-Regular", size: 10))
                .padding(.top, 2)
                .foregroundColor(isActive ? Color(hex: "#F2A213") : .white)
        }
    }
}

#Preview {
    Home()
}
