//
//  Product Page.swift
//  searchly
//
//  Created by cobsccompy4231p-007 on 2024-10-27.
//

import SwiftUI
import FirebaseFirestore

struct Product_Page: View {
    @State private var isLoading: Bool = true // Show loading indicator
    let productID: String // Accept product ID as a parameter
    @State private var isExpanded: Bool = false
    private let db = Firestore.firestore() // Firestore reference

    // Variables for product details
    @State private var product_name: String = "Apple iPhone 15 Pro 128GB"
    @State private var seller_name: String = "Appleasia.lk"
    @State private var seller_likes: String = "1"
    @State private var product_likes: Int = 652
    @State private var product_dislikes: Int = 1
    @State private var product_ratings: Int = 5
    @State private var product_desc: String = "iPhone 15 Pro is the first iPhone to feature an aerospace-grade titanium design, using the same alloy that spacecraft use for missions to Mars.\n\nTitanium has one of the best strength-to-weight ratios of any metal, making these our lightest Pro models ever."
    @State private var product_img: String = "http://res.cloudinary.com/diiyqygjq/image/upload/v1731136795/ihkamxqdatbv8xkubxq.jpg"
    @State private var seller_profile_img_link: String = "http://res.cloudinary.com/diiyqygjq/image/upload/v1731136795/ihkamxqdatbv8xkubxq.jpg"
    @State private var product_price: Int = 120000

    
    @State private var otherProducts: [Products] = []
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Top Navigation Bar
                    HStack {
//                        Button(action: {
//                            // Back action
//                        }) {
//                            Image(systemName: "arrow.left")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 20, height: 20)
//                                .foregroundColor(.black)
//                        }
//                        .padding(.leading, 20)
                        
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
                    AsyncImage(url: URL(string: product_img)) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(height: 250)
                            .padding(.horizontal, 20)
                    } placeholder: {
                        Color.gray
                            .frame(height: 250)
                            .padding(.horizontal, 20)
                    }
                    
                    // Product Info Section
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text(product_name)
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
                                AsyncImage(url: URL(string: seller_profile_img_link)) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 20, height: 20)
                                        .clipped()
                                        .cornerRadius(10)
                                } placeholder: {
                                    Color.gray
                                        .frame(width: 20, height: 20)
                                        .cornerRadius(10)
                                }
                                
                                Text(seller_name)
                                    .font(.custom("Heebo-Regular", size: 12))
                                    .foregroundColor(.gray)
                                
                                Text(seller_likes)
                                    .font(.custom("Heebo-Regular", size: 12))
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Text("Rs." + String(product_price))
                                .font(.custom("Heebo-Bold", size: 16))
                                .foregroundColor(Color(hexValue: "#F2A213"))
                        }
                        
                        // Horizontal Scroll for Action Buttons
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                IconActionButton(iconName: "like-icon-product", label: String(product_likes))
                                IconActionButton(iconName: "dislike-icon-product", label: String(product_dislikes))
                                IconActionButton(iconName: "share-icon-product", label: "Share")
                                IconActionButton(iconName: "star-icon-product", label: String(product_ratings))
                                IconActionButton(iconName: "calander-icon-product", label: "Remind")
                            }
                            .padding(.top, 5)
                        }
                        
                        // Product Description (Expandable)
                        Text(product_desc)
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
                    
                    Spacer()
                    
                    Divider()
                    
                    // Other Product Listings
                    VStack(alignment: .leading, spacing: 10) {
//                        Text("Other Products")
//                            .font(.custom("Heebo-Bold", size: 18))
//                            .padding(.horizontal, 20)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHGrid(rows: [GridItem(.fixed(180))], spacing: 20) {
                                ForEach(otherProducts, id: \.id) { product in
                                    ProductCard(
                                        imageName: product.imageName,
                                        name: product.name,
                                        siteName: product.siteName,
                                        price: "Rs.\(product.price)",
                                        likes: "\(product.likes)",
                                        rating: "\(product.rating)"
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }
            }
            .background(Color.white)
            .edgesIgnoringSafeArea(.all)
        }
        .onAppear {
            fetchProductDetails()
            fetchOtherProducts()
        }
    }
    
    // Fetch product details from Firestore
    private func fetchProductDetails() {
        db.collection("products").document(productID).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching product details: \(error)")
                return
            }
            
            guard let data = snapshot?.data() else {
                print("No product data found for ID: \(productID)")
                return
            }
            
            DispatchQueue.main.async {
                product_name = data["name"] as? String ?? "Unknown Product"
                seller_name = data["siteName"] as? String ?? "Unknown Seller"
//                seller_likes = Int(data["seller_likes"] as? String ?? "0") ?? ""
                product_likes = Int(data["likes"] as? String ?? "0") ?? 0
                product_dislikes = Int(data["dislikes"] as? String ?? "0") ?? 0
                product_ratings = Int(data["rating"] as? String ?? "0") ?? 0
                product_desc = data["description"] as? String ?? "No description available."
                product_img = data["product_image"] as? String ?? "http://res.cloudinary.com/diiyqygjq/image/upload/v1731136795/ihkamxqdatbv8xkubxq.jpg"
                product_price = Int(data["price"] as? String ?? "0") ?? 0
                
                if let sellerID = data["seller_id"] as? String {
                                    fetchSellerProfile(sellerID: sellerID)
                                }
            }
        }
    }
    
    // Fetch other products from Firestore
        private func fetchOtherProducts() {
            db.collection("products").limit(to: 10).getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching other products: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No other products found")
                    return
                }
                
                DispatchQueue.main.async {
                    self.otherProducts = documents.compactMap { doc in
                        let data = doc.data()
                        return Products(
                            id: doc.documentID,
                            name: data["name"] as? String ?? "Unknown Product",
                            price: Double(data["price"] as? String ?? "0") ?? 0.0,
                            siteName: data["siteName"] as? String ?? "Unknown Seller",
                            likes: Int(data["likes"] as? String ?? "0") ?? 0,
                            dislikes: Int(data["dislikes"] as? String ?? "0") ?? 0,
                            rating: Double(data["rating"] as? String ?? "0") ?? 0.0,
                            categories: [],
                            imageName: data["product_image"] as? String ?? "http://res.cloudinary.com/diiyqygjq/image/upload/v1731136795/ihkamxqdatbv8xkubxq.jpg"
                        )
                    }
                }
            }
        }
    
    private func fetchSellerProfile(sellerID: String) {
            db.collection("sellers").document(sellerID).getDocument { snapshot, error in
                if let error = error {
                    print("Error fetching seller profile: \(error)")
                    return
                }
                
                guard let data = snapshot?.data() else {
                    print("No seller data found for ID: \(sellerID)")
                    return
                }
                
                DispatchQueue.main.async {
                    seller_profile_img_link = data["profile_image"] as? String ?? "http://res.cloudinary.com/diiyqygjq/image/upload/v1731136795/ihkamxqdatbv8xkubxq.jpg"
                    seller_name = data["name"] as? String ?? "Unknown"
                    seller_likes = data["total_likes"] as? String ?? ""
                    seller_likes = seller_likes + " Likes"
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
    Product_Page(productID: "AqLHYVv64EVezlPHmyQ6")
}
