//
//  Home.swift
//  searchly
//
//  Created by cobsccompy4231p-007 on 2024-10-27.
//

import SwiftUI
import FirebaseFirestore
import MapKit

// MARK: - Product Model
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
    var location: CLLocationCoordinate2D?
}

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
    var searchText: String?
    
    private var allProducts: [Products] = []
    
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
                        location: sellerLocation
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

// MARK: - Home View
struct Home: View {
    @StateObject private var viewModel = ProductViewModel()
    @State private var showPriceFilter = false
    @State private var selectedPrice: Double = 350000 // Default value
    
    @State private var showLocationFilter = false // State to control location filter visibility
    @State private var selectedLocation: CLLocationCoordinate2D? // Selected location
    @State private var selectedRadius: Double = 1000 // Default radius (1 km)
    
    @State private var showRatingFilter = false
    @State private var selectedRating: Double = 0.0 // Default rating
    
    @State private var showLikesFilter = false
    @State private var selectedLikes: Int = 0 // Default likes
    
    @State private var searchText: String = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Top Navigation Bar
                HStack {
                    HStack {
                        Image("search")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                            .padding(.leading, 8)
                        
                        TextField("Search", text: $searchText)
                            .padding(10)
                            .onChange(of: searchText) { newValue in
                                viewModel.searchText = newValue
                                viewModel.applyFilters()
                            }
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
                    FilterButton(iconName: "location-icon", title: "Location") {
                        showLocationFilter = true
                    }
                    FilterButton(iconName: "price-icon", title: "Price") {
                        showPriceFilter = true
                    }
                    FilterButton(iconName: "rating-icon", title: "Rating") {
                        showRatingFilter = true
                    }
                    FilterButton(iconName: "like-icon", title: "Likes") {
                        showLikesFilter = true
                    }
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
            .sheet(isPresented: $showLocationFilter) {
                LocationFilterView(
                    selectedLocation: $selectedLocation,
                    selectedRadius: $selectedRadius,
                    isPresented: $showLocationFilter
                ) {
                    viewModel.selectedLocation = selectedLocation
                    viewModel.selectedRadius = selectedRadius
                    viewModel.applyFilters()
                }
            }
            .sheet(isPresented: $showPriceFilter) {
                PriceFilterView(selectedPrice: $selectedPrice, isPresented: $showPriceFilter) {
                    viewModel.selectedPrice = selectedPrice
                    viewModel.applyFilters()
                }
            }
            .sheet(isPresented: $showRatingFilter) {
                RatingFilterView(selectedRating: $selectedRating, isPresented: $showRatingFilter) {
                    viewModel.selectedRating = selectedRating
                    viewModel.applyFilters()
                }
            }
            .sheet(isPresented: $showLikesFilter) {
                LikesFilterView(selectedLikes: $selectedLikes, isPresented: $showLikesFilter) {
                    viewModel.selectedLikes = selectedLikes
                    viewModel.applyFilters()
                }
            }
            .onAppear {
                viewModel.fetchProducts()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - LocationFilterView
struct LocationFilterView: View {
    @Binding var selectedLocation: CLLocationCoordinate2D?
    @Binding var selectedRadius: Double
    @Binding var isPresented: Bool
    var onApply: () -> Void // Closure to execute when 'Apply' is tapped

    @State private var centerCoordinate: CLLocationCoordinate2D?
    @State private var searchQuery: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                TextField("Search for a location", text: $searchQuery, onCommit: {
                    performGeocoding()
                })
                .padding(10)
                .background(Color(hex: "#F7F7F7"))
                .cornerRadius(8)
//                .overlay(
//                    Image(systemName: "magnifyingglass")
//                        .padding(.leading, 10),
//                    alignment: .leading
//                )
                .overlay(
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark")
                            .padding(.trailing, 10)
                    },
                    alignment: .trailing
                )
            }
            .padding(.horizontal, 20)

            MapViewRepresentable(centerCoordinate: $centerCoordinate, selectedRadius: $selectedRadius)
                .frame(height: 300)
                .cornerRadius(12)
                .padding(.horizontal, 20)

            VStack(spacing: 10) {
                Text("Radius: \(Int(selectedRadius)) meters")
                    .font(.custom("Heebo-Regular", size: 16))

                Slider(value: $selectedRadius, in: 100...5000, step: 50) // Adjust the range as needed
                    .accentColor(Color(hex: "#F2A213"))
                    .padding(.horizontal, 20)
            }

            Button(action: {
                isPresented = false
                selectedLocation = centerCoordinate
                onApply()
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
        .onAppear {
            centerCoordinate = selectedLocation ?? CLLocationCoordinate2D(latitude: 7.8731, longitude: 80.7718)
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Location Not Found"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    func performGeocoding() {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(searchQuery) { placemarks, error in
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                alertMessage = "Unable to find location. Please try again."
                showAlert = true
            } else if let placemark = placemarks?.first, let location = placemark.location {
                centerCoordinate = location.coordinate
            } else {
                alertMessage = "Location not found. Please try a different query."
                showAlert = true
            }
        }
    }
}

// MARK: - MapViewRepresentable
struct MapViewRepresentable: UIViewRepresentable {
    @Binding var centerCoordinate: CLLocationCoordinate2D?
    @Binding var selectedRadius: Double

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator

        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.mapTapped))
        mapView.addGestureRecognizer(tapGesture)

        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        // Remove existing overlays and annotations
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)

        if let centerCoordinate = centerCoordinate {
            // Add annotation
            let annotation = MKPointAnnotation()
            annotation.coordinate = centerCoordinate
            mapView.addAnnotation(annotation)

            // Add circle overlay
            let circle = MKCircle(center: centerCoordinate, radius: selectedRadius)
            mapView.addOverlay(circle)

            // Set region
            let region = MKCoordinateRegion(center: centerCoordinate, latitudinalMeters: selectedRadius * 2.5, longitudinalMeters: selectedRadius * 2.5)
            mapView.setRegion(region, animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewRepresentable

        init(_ parent: MapViewRepresentable) {
            self.parent = parent
        }

        @objc func mapTapped(_ sender: UITapGestureRecognizer) {
            let mapView = sender.view as! MKMapView
            let location = sender.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)

            parent.centerCoordinate = coordinate
        }

        // MKMapViewDelegate method to render overlays
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let circleOverlay = overlay as? MKCircle {
                let renderer = MKCircleRenderer(circle: circleOverlay)
                renderer.strokeColor = UIColor.orange
                renderer.fillColor = UIColor.orange.withAlphaComponent(0.3)
                renderer.lineWidth = 2
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}

// MARK: - PriceFilterView
struct PriceFilterView: View {
    @Binding var selectedPrice: Double
    @Binding var isPresented: Bool
    var onApply: () -> Void // Closure to execute when 'Apply' is tapped
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Price: Rs.\(Int(selectedPrice))")
                .font(.custom("Heebo-Regular", size: 18))
                .padding(.top, 20)
            
            Slider(value: $selectedPrice, in: 0...1000000, step: 10000)
                .accentColor(Color(hex: "#F2A213"))
                .padding(.horizontal, 20)
            
            Button(action: {
                isPresented = false
                onApply()
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

// MARK: - RatingFilterView
struct RatingFilterView: View {
    @Binding var selectedRating: Double
    @Binding var isPresented: Bool
    var onApply: () -> Void // Closure to execute when 'Apply' is tapped
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Minimum Rating: \(String(format: "%.1f", selectedRating))")
                .font(.custom("Heebo-Regular", size: 18))
                .padding(.top, 20)
            
            Slider(value: $selectedRating, in: 0...5, step: 0.1)
                .accentColor(Color(hex: "#F2A213"))
                .padding(.horizontal, 20)
            
            Button(action: {
                isPresented = false
                onApply()
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

// MARK: - LikesFilterView
struct LikesFilterView: View {
    @Binding var selectedLikes: Int
    @Binding var isPresented: Bool
    var onApply: () -> Void // Closure to execute when 'Apply' is tapped
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Minimum Likes: \(selectedLikes)")
                .font(.custom("Heebo-Regular", size: 18))
                .padding(.top, 20)
            
            Slider(value: Binding(get: {
                Double(selectedLikes)
            }, set: {
                selectedLikes = Int($0)
            }), in: 0...1000, step: 10)
                .accentColor(Color(hex: "#F2A213"))
                .padding(.horizontal, 20)
            
            Button(action: {
                isPresented = false
                onApply()
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
                    .foregroundColor(.black)
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
            AsyncImage(url: URL(string: imageName)) { image in
                image
                    .resizable()
                    .scaledToFill() // Ensures the image covers the entire frame while maintaining aspect ratio
                    .frame(width: 120, height: 120) // Adjust the size as per your design
                    .clipped() // Clips the overflowing parts to fit the frame
                    .cornerRadius(8)
            } placeholder: {
                Color.gray // Placeholder while the image is loading
                    .frame(width: 120, height: 120) // Match the size of the image frame
                    .cornerRadius(8)
            }
            
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
                        .foregroundColor(.black)
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
                        .foregroundColor(.black)
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

// MARK: - Color Extension
//extension Color {
//    init(hex: String) {
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

