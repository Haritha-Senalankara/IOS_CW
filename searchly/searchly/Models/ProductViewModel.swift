import Foundation
import SwiftUI
import FirebaseFirestore
import MapKit

class ProductViewModel: ObservableObject {
    @Published var products: [Products] = []
    private let db = Firestore.firestore()
    
    // Additional properties for filtering
    var selectedMinPrice: Double = 0 // Default minimum price
    var selectedMaxPrice: Double = 1000000 // Default maximum price
    var selectedLocation: CLLocationCoordinate2D?
    var selectedRadius: Double?
    var selectedRating: Double?
    var selectedLikes: Int?
    var selectedAppFilters: [String]?
    var selectedContactMethodFilters: [String]?
    var searchText: String?
    
    private var allProducts: [Products] = []
    @Published var allAppFilters: [AppFilter] = []
    @Published var allContactMethodFilters: [ContactMethodFilter] = []
    
    /// Fetch products from Firestore with optional seller filtering
    func fetchProducts(sellerID: String? = nil) {
        var query: Query = db.collection("products")
        
        // If a sellerID is provided, filter by it
        if let sellerID = sellerID {
            query = query.whereField("seller_id", isEqualTo: sellerID)
        }
        
        query.getDocuments { [weak self] snapshot, error in
            guard let self = self else { return } // Avoid strong reference to self
            
            if let error = error {
                print("Error fetching products: \(error)")
                return
            }
            
            var fetchedProducts: [Products] = []
            let group = DispatchGroup() // Handle asynchronous queries
            
            snapshot?.documents.forEach { document in
                let data = document.data()
                
                // Parse product fields
                let name = data["name"] as? String ?? "Unknown Product"
                let price: Double = {
                    if let priceString = data["price"] as? String {
                        return Double(priceString) ?? 0.0
                    } else if let priceDouble = data["price"] as? Double {
                        return priceDouble
                    }
                    return 0.0
                }()
                let likes: Int = {
                    if let likesString = data["likes"] as? String {
                        return Int(likesString) ?? 0
                    } else if let likesInt = data["likes"] as? Int {
                        return likesInt
                    }
                    return 0
                }()
                let dislikes: Int = {
                    if let dislikesString = data["dislikes"] as? String {
                        return Int(dislikesString) ?? 0
                    } else if let dislikesInt = data["dislikes"] as? Int {
                        return dislikesInt
                    }
                    return 0
                }()
                let rating: Double = {
                    if let ratingString = data["rating"] as? String {
                        return Double(ratingString) ?? 0.0
                    } else if let ratingDouble = data["rating"] as? Double {
                        return ratingDouble
                    }
                    return 0.0
                }()
                
                let sellerID = data["seller_id"] as? String ?? "Unknown Seller"
                let categories = data["categories"] as? [String] ?? []
                let imageName = data["product_image"] as? String ?? "placeholder"
                
                group.enter() // Enter group for seller query
                self.db.collection("sellers").document(sellerID).getDocument { sellerSnapshot, error in
                    var sellerName = "Unknown Seller"
                    var sellerLocation: CLLocationCoordinate2D? = nil
                    var sellerApps: [AppFilter] = []
                    var sellerContacts: [ContactMethodFilter] = []
                    
                    if let sellerData = sellerSnapshot?.data() {
                        sellerName = sellerData["name"] as? String ?? sellerName
                        
                        // Parse seller location
                        if let locationData = sellerData["location"] as? [String: Any],
                           let lat = locationData["lat"] as? Double,
                           let long = locationData["long"] as? Double {
                            sellerLocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
                        }
                        
                        // Parse seller apps
                        if let apps = sellerData["apps"] as? [String] {
                            sellerApps = apps.compactMap { appID in
                                self.allAppFilters.first(where: { $0.id == appID })
                            }
                        }
                        
                        // Parse seller contact methods
                        if let contacts = sellerData["contact_methods"] as? [String] {
                            sellerContacts = contacts.compactMap { contactID in
                                self.allContactMethodFilters.first(where: { $0.id == contactID })
                            }
                        }
                    }
                    
                    // Create product object
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
                    group.leave() // Leave group after query completes
                }
            }
            
            group.notify(queue: .main) {
                self.allProducts = fetchedProducts
                self.applyFilters()
            }
        }
    }
    
    // Fetch app filters
    func fetchAppFilters(completion: @escaping () -> Void) {
        db.collection("apps").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching app filters: \(error)")
                completion()
                return
            }
            
            let appFilters = snapshot?.documents.compactMap { document -> AppFilter? in
                let data = document.data()
                return AppFilter(
                    id: document.documentID,
                    name: data["name"] as? String ?? "Unknown App",
                    imageURL: data["app_image"] as? String ?? ""
                )
            } ?? []
            
            DispatchQueue.main.async {
                self.allAppFilters = appFilters
                completion()
            }
        }
    }
    
    // Fetch contact method filters
    func fetchContactMethodFilters(completion: @escaping () -> Void) {
        db.collection("contact_methods").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching contact method filters: \(error)")
                completion()
                return
            }
            
            let contactMethodFilters = snapshot?.documents.compactMap { document -> ContactMethodFilter? in
                let data = document.data()
                return ContactMethodFilter(
                    id: document.documentID,
                    name: data["name"] as? String ?? "Unknown Contact",
                    imageURL: data["method_image"] as? String ?? ""
                )
            } ?? []
            
            DispatchQueue.main.async {
                self.allContactMethodFilters = contactMethodFilters
                completion()
            }
        }
    }
    
    // Apply filters
    func applyFilters() {
        var filteredProducts = allProducts
        
        // Filter by price range
        filteredProducts = filteredProducts.filter {
            $0.price >= selectedMinPrice && $0.price <= selectedMaxPrice
        }
        
        // Filter by search text
        if let searchText = searchText, !searchText.isEmpty {
            filteredProducts = filteredProducts.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
        
        DispatchQueue.main.async {
            self.products = filteredProducts
        }
    }
}
