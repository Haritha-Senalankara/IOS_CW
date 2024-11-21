//
//  Wishlist.swift
//  searchly
//
//  Created by cobsccompy4231p-007 on 2024-10-27.
//

import SwiftUI
import FirebaseFirestore

struct Wishlist: View {
    @StateObject private var viewModel = WishlistViewModel()
    @State private var navigateToProfile = false
    
    var body: some View {
        VStack(spacing: 0) {
            
            
            Text("My Wishlist")
                .font(.custom("Heebo-Bold", size: 24))
                .padding(.vertical, 10)
            
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            } else if viewModel.products.isEmpty {
                // Show a message if the wishlist is empty
                Text("Your wishlist is empty.")
                    .font(.custom("Heebo-Regular", size: 16))
                    .foregroundColor(.gray)
                    .padding()
                Spacer()
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(viewModel.products) { product in
                            NavigationLink(destination: Product_Page(productID: product.id)) {
                                ProductCard(
                                    imageName: product.imageName,
                                    name: product.name,
                                    siteName: product.siteName,
                                    price: "Rs.\(Int(product.price))",
                                    likes: "\(product.likes)",
                                    rating: String(format: "%.1f", product.rating)
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
            }
            
            Spacer()
            
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            viewModel.fetchWishlistProducts()
        }
        .background(
            NavigationLink(
                destination: Customer_Profile(),
                isActive: $navigateToProfile
            ) {
                EmptyView()
            }
                .hidden()
        )
    }
}

// MARK: - Wishlist ViewModel
class WishlistViewModel: ObservableObject {
    @Published var products: [Products] = []
    @Published var isLoading: Bool = false
    
    private let db = Firestore.firestore()
    private var userID: String = ""
    
    func fetchWishlistProducts() {
        guard let uid = UserDefaults.standard.string(forKey: "userID") else {
            print("User ID not found in UserDefaults")
            return
        }
        self.userID = uid
        isLoading = true
        
        // Fetch favorite list from customer's document
        db.collection("customers").document(userID).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching customer data: \(error)")
                self.isLoading = false
                return
            }
            
            guard let data = snapshot?.data(), let favList = data["fav_list"] as? [String] else {
                print("No fav_list found for user \(self.userID)")
                self.isLoading = false
                return
            }
            
            if favList.isEmpty {
                DispatchQueue.main.async {
                    self.products = []
                    self.isLoading = false
                }
            } else {
                self.fetchProducts(productIDs: favList)
            }
        }
    }
    
    private func fetchProducts(productIDs: [String]) {
        var fetchedProducts: [Products] = []
        let group = DispatchGroup()
        
        for productID in productIDs {
            group.enter()
            db.collection("products").document(productID).getDocument { [weak self] snapshot, error in
                defer { group.leave() }
                guard let self = self else { return }
                if let error = error {
                    print("Error fetching product \(productID): \(error)")
                    return
                }
                
                guard let data = snapshot?.data() else {
                    print("No data found for product \(productID)")
                    return
                }
                
                let name = data["name"] as? String ?? "Unknown Product"
                let price = Double(data["price"] as? String ?? "0") ?? 0.0
                let siteName = data["siteName"] as? String ?? "Unknown Seller"
                let likes = Int(data["likes"] as? String ?? "0") ?? 0
                let dislikes = Int(data["dislikes"] as? String ?? "0") ?? 0
                let rating = Double(data["rating"] as? String ?? "0") ?? 0.0
                let categories = data["categories"] as? [String] ?? []
                let imageName = data["product_image"] as? String ?? ""
                
                let product = Products(
                    id: productID,
                    name: name,
                    price: price,
                    siteName: siteName,
                    likes: likes,
                    dislikes: dislikes,
                    rating: rating,
                    categories: categories,
                    imageName: imageName,
                    location: nil
                )
                
                fetchedProducts.append(product)
            }
        }
        
        group.notify(queue: .main) {
            self.products = fetchedProducts
            self.isLoading = false
        }
    }
}

// Preview Provider
struct Wishlist_Previews: PreviewProvider {
    static var previews: some View {
        Wishlist()
    }
}
