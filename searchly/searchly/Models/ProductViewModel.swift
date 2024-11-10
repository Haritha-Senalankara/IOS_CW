//
//  ProductViewModel.swift
//  searchly
//
//  Created by cobsccompy4231p-007 on 2024-11-10.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import MapKit

// MARK: - Product ViewModel
class ProductViewModel: ObservableObject {
    @Published var products: [Products] = []
    
    private let db = Firestore.firestore()
    
    // Add properties for filters
    var selectedPrice: Double?
    var selectedLocation: CLLocationCoordinate2D?
    var selectedRadius: Double?
    var selectedRating: Double?
    var selectedLikes: Int?
    var selectedAppFilters: [String]? // Selected app filter IDs
    var selectedContactMethodFilters: [String]? // Selected contact method filter IDs
    var searchText: String?
    
    private var allProducts: [Products] = []
    
    // New properties to store all available app filters and contact method filters
    @Published var allAppFilters: [AppFilter] = []
    @Published var allContactMethodFilters: [ContactMethodFilter] = []
    
    // Fetch products from Firestore
    func fetchProducts() {
        let query = db.collection("products")
        
        query.getDocuments { [weak self] snapshot, error in
            guard let self = self else { return } // Avoid strong reference to self

            if let error = error {
                print("Error fetching products: \(error)")
                return
            }

            // Temporary array to store products
            var fetchedProducts: [Products] = []

            let group = DispatchGroup() // Use DispatchGroup to handle asynchronous queries

            snapshot?.documents.forEach { document in
                let data = document.data()

                // Parse fields with proper type handling
                let name = data["name"] as? String ?? "Unknown Product"
                
                // Parse price
                let price: Double
                if let priceString = data["price"] as? String {
                    price = Double(priceString) ?? 0.0
                } else if let priceDouble = data["price"] as? Double {
                    price = priceDouble
                } else {
                    price = 0.0
                }
                
                // Parse likes
                let likes: Int
                if let likesString = data["likes"] as? String {
                    likes = Int(likesString) ?? 0
                } else if let likesInt = data["likes"] as? Int {
                    likes = likesInt
                } else {
                    likes = 0
                }
                
                // Parse dislikes
                let dislikes: Int
                if let dislikesString = data["dislikes"] as? String {
                    dislikes = Int(dislikesString) ?? 0
                } else if let dislikesInt = data["dislikes"] as? Int {
                    dislikes = dislikesInt
                } else {
                    dislikes = 0
                }
                
                // Parse rating
                let rating: Double
                if let ratingString = data["rating"] as? String {
                    rating = Double(ratingString) ?? 0.0
                } else if let ratingDouble = data["rating"] as? Double {
                    rating = ratingDouble
                } else {
                    rating = 0.0
                }
                
                let sellerID = data["seller_id"] as? String ?? "Unknown Seller"
                let categories = data["categories"] as? [String] ?? ["Default Category"]
                let imageName = data["product_image"] as? String ?? "img-1"
                
                // Remove parsing location from product data since it's not stored there
                let location: CLLocationCoordinate2D? = nil // Will be set from seller's data

                group.enter() // Enter the group for the seller query
                self.db.collection("sellers").document(sellerID).getDocument { sellerSnapshot, error in
                    var sellerName = "Unknown Seller"
                    var sellerLocation: CLLocationCoordinate2D? = nil
                    var sellerApps: [AppFilter] = []
                    var sellerContacts: [ContactMethodFilter] = []
                    
                    if let sellerData = sellerSnapshot?.data() {
                        if let fetchedSellerName = sellerData["name"] as? String {
                            sellerName = fetchedSellerName
                        }
                        // Parse seller location
                        if let locationData = sellerData["location"] as? [String: Any],
                           let lat = locationData["lat"] as? Double,
                           let long = locationData["long"] as? Double {
                            sellerLocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
                        }
                        // Parse seller apps
                        if let apps = sellerData["apps"] as? [String] {
                            for appID in apps {
                                if let appFilter = self.allAppFilters.first(where: { $0.id == appID }) {
                                    sellerApps.append(appFilter)
                                }
                            }
                        }
                        // Parse seller contact methods
                        if let contacts = sellerData["contact_methods"] as? [String] {
                            for contactID in contacts {
                                if let contactMethodFilter = self.allContactMethodFilters.first(where: { $0.id == contactID }) {
                                    sellerContacts.append(contactMethodFilter)
                                }
                            }
                        }
                    }

                    // Create the product object with the seller's name and location
                    let product = Products(
                        id: document.documentID,
                        name: name,
                        price: price,
                        siteName: sellerName,
                        likes: likes,
                        dislikes: dislikes,
                        rating: rating,
                        categories: categories,
                        imageName: imageName,
                        location: sellerLocation,
                        sellerApps: sellerApps,
                        sellerContacts: sellerContacts
                    )

                    fetchedProducts.append(product)
                    group.leave() // Leave the group after completing the seller query
                }
            }

            group.notify(queue: .main) {
                // Update the products array once all seller queries are complete
                self.allProducts = fetchedProducts
                self.applyFilters()
            }
        }
    }
    
    // Fetch app filters from Firestore
    func fetchAppFilters(completion: @escaping () -> Void) {
        db.collection("apps").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching apps: \(error)")
                completion()
                return
            }

            var appFilters: [AppFilter] = []
            snapshot?.documents.forEach { document in
                let data = document.data()
                let id = document.documentID
                let name = data["name"] as? String ?? "Unknown App"
                let imageURL = data["app_image"] as? String ?? "" // Updated field name
                let appFilter = AppFilter(id: id, name: name, imageURL: imageURL)
                appFilters.append(appFilter)
            }
            DispatchQueue.main.async {
                self.allAppFilters = appFilters
                completion()
            }
        }
    }
    
    // Fetch contact method filters from Firestore
    func fetchContactMethodFilters(completion: @escaping () -> Void) {
        db.collection("contact_methods").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching contact methods: \(error)")
                completion()
                return
            }

            var contactMethodFilters: [ContactMethodFilter] = []
            snapshot?.documents.forEach { document in
                let data = document.data()
                let id = document.documentID
                let name = data["name"] as? String ?? "Unknown Contact"
                let imageURL = data["method_image"] as? String ?? "" // Updated field name
                let contactMethodFilter = ContactMethodFilter(id: id, name: name, imageURL: imageURL)
                contactMethodFilters.append(contactMethodFilter)
            }
            DispatchQueue.main.async {
                self.allContactMethodFilters = contactMethodFilters
                completion()
            }
        }
    }
    
    // Apply filters to products
    func applyFilters() {
        var filteredProducts = allProducts

        // Filter by price
        if let selectedPrice = self.selectedPrice {
            filteredProducts = filteredProducts.filter { product in
                product.price <= selectedPrice
            }
        }

        // Filter by location
        if let selectedLocation = self.selectedLocation, let selectedRadius = self.selectedRadius {
            filteredProducts = filteredProducts.filter { product in
                if let productLocation = product.location {
                    let productCoordinate = CLLocation(latitude: productLocation.latitude, longitude: productLocation.longitude)
                    let selectedCoordinate = CLLocation(latitude: selectedLocation.latitude, longitude: selectedLocation.longitude)
                    let distance = productCoordinate.distance(from: selectedCoordinate)
                    return distance <= selectedRadius
                } else {
                    return false
                }
            }
        }
        
        // Filter by rating
        if let selectedRating = self.selectedRating {
            filteredProducts = filteredProducts.filter { product in
                product.rating >= selectedRating
            }
        }
        
        // Filter by likes
        if let selectedLikes = self.selectedLikes {
            filteredProducts = filteredProducts.filter { product in
                product.likes >= selectedLikes
            }
        }
        
        // Filter by app filters
        if let selectedAppFilters = self.selectedAppFilters, !selectedAppFilters.isEmpty {
            filteredProducts = filteredProducts.filter { product in
                !product.sellerApps.isEmpty && product.sellerApps.contains(where: { selectedAppFilters.contains($0.id) })
            }
        }
        
        // Filter by contact method filters
        if let selectedContactMethodFilters = self.selectedContactMethodFilters, !selectedContactMethodFilters.isEmpty {
            filteredProducts = filteredProducts.filter { product in
                !product.sellerContacts.isEmpty && product.sellerContacts.contains(where: { selectedContactMethodFilters.contains($0.id) })
            }
        }

        // Filter by search text
        if let searchText = self.searchText, !searchText.isEmpty {
            filteredProducts = filteredProducts.filter { product in
                product.name.lowercased().contains(searchText.lowercased())
            }
        }

        DispatchQueue.main.async {
            self.products = filteredProducts
        }
    }
}
