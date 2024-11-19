//
//  Seller_Profile.swift
//  searchly
//
//  Created by cobsccompy4231p-007 on 2024-10-27.
//

import SwiftUI
import FirebaseFirestore
import MapKit

struct Seller_Profile: View {
    @State private var sellerName: String = "Loading..."
    @State private var sellerLikes: String = "0 Likes"
    @State private var sellerDescription: String = "Loading seller description..."
    @State private var sellerEmail: String = "Loading email..."
    @State private var sellerLocation: CLLocationCoordinate2D? = nil
    @State private var sellerWebsite: String = ""
    @State private var contactMethods: [String] = []
    @State private var apps: [String] = []
    @State private var phoneNumber: String = "Unavailable"
    @State private var whatsappNumber: String = "Unavailable"
    @State private var seller_profile_img_link: String = "http://res.cloudinary.com/diiyqygjq/image/upload/v1731136795/ihkamxqdatbv8xkubxq.jpg"
    
    private let db = Firestore.firestore()
    let sellerID: String
    
    @State private var searchText: String = ""
    @State private var navigateToProfile = false
    @State private var navigateToNotification = false
    
    @StateObject private var viewModel = ProductViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            
            TopNavBar(
                searchText: $searchText,
                onProfileTap: {
                    navigateToProfile = true
                },
                onNotificationTap: {
                    navigateToNotification = true
                },
                showSearch: false
            )
            Spacer()
            ScrollView{
                // Seller Logo
                AsyncImage(url: URL(string: seller_profile_img_link)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipped()
                        .cornerRadius(100)
                } placeholder: {
                    Color.gray
                        .frame(width: 100, height: 100)
                        .cornerRadius(10)
                }
                // Seller Information
                Text(sellerName)
                    .font(.custom("Heebo-Bold", size: 20))
                    .foregroundColor(Color(hexValue: "#102A36"))
                    .padding(.top, 5)
                
                Text(sellerLikes)
                    .font(.custom("Heebo-Regular", size: 14))
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)
                
                // Contact Buttons
                VStack(spacing: 15) {
                    HStack(spacing: 20) {
                        ContactButton(iconName: "phone.fill", title: "Call") {
                            if let phoneURL = URL(string: "tel://\(phoneNumber)") {
                                if UIApplication.shared.canOpenURL(phoneURL) {
                                    UIApplication.shared.open(phoneURL)
                                } else {
                                    print("Device cannot make calls.")
                                }
                            }
                        }
                        ContactButton(iconName: "message.fill", title: "WhatsApp") {
                            if let whatsappURL = URL(string: "https://wa.me/\(whatsappNumber)") {
                                if UIApplication.shared.canOpenURL(whatsappURL) {
                                    UIApplication.shared.open(whatsappURL)
                                } else {
                                    print("WhatsApp is not installed.")
                                }
                            }
                        }
                    }
                    HStack(spacing: 20) {
                        ContactButton(iconName: "globe", title: "Website") {
                            if let url = URL(string: sellerWebsite) {
                                if UIApplication.shared.canOpenURL(url) {
                                    UIApplication.shared.open(url)
                                } else {
                                    print("Invalid URL.")
                                }
                            }
                        }
                        ContactButton(iconName: "square.and.arrow.up", title: "Share") {
                            // Share functionality can be added here if required
                            print("Share button tapped")
                        }
                    }
                }
                
                .padding(.horizontal, 20)
                
                // Seller Description
                VStack(alignment: .leading, spacing: 10) {
                    Text(sellerDescription)
                        .font(.custom("Heebo-Regular", size: 14))
                        .foregroundColor(.gray)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    
                }
                
                // Map
                if let location = sellerLocation {
                    VStack {
                        MapView(coordinate: location)
                            .frame(height: 200)
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                        
                        Button(action: {
                            openMaps(for: location)
                        }) {
                            Text("Get Directions")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(10)
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    }
                } else {
                    Text("Loading map...")
                        .font(.custom("Heebo-Regular", size: 14))
                        .foregroundColor(.gray)
                        .padding(.top, 20)
                }
                
                
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
            }
            
            Spacer()
            
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            fetchSellerData()
            viewModel.fetchProducts(sellerID: sellerID)
        }
        //        .navigationBarBackButtonHidden(true)
        
        // Sheets for Profile and Notifications
        .sheet(isPresented: $navigateToProfile) {
            Customer_Profile()
        }
        .sheet(isPresented: $navigateToNotification) {
            Notifications()
        }
    }
    
    private func openMaps(for location: CLLocationCoordinate2D) {
        let url = URL(string: "http://maps.apple.com/?daddr=\(location.latitude),\(location.longitude)")!
        UIApplication.shared.open(url)
    }
    
    // Fetch seller data from Firestore and parse as JSON
    private func fetchSellerData() {
        db.collection("sellers").document(sellerID).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching seller data: \(error)")
                return
            }
            
            guard let data = snapshot?.data() else {
                print("No seller data found for ID: \(sellerID)")
                return
            }
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                    parseSellerJSON(json: json)
                }
            } catch {
                print("Error serializing seller data: \(error)")
            }
        }
    }
    
    // Parse JSON data into variables
    private func parseSellerJSON(json: [String: Any]) {
        DispatchQueue.main.async {
            sellerName = json["name"] as? String ?? "Unknown Seller"
            sellerLikes = "\(json["total_likes"] as? String ?? "") Likes"
            sellerDescription = json["description"] as? String ?? "No description available."
            sellerEmail = json["email"] as? String ?? "No email available."
            sellerWebsite = json["website"] as? String ?? ""
            phoneNumber = json["phone_number"] as? String ?? "Unavailable"
            whatsappNumber = json["whatsapp_number"] as? String ?? "Unavailable"
            seller_profile_img_link = json["profile_image"] as? String ?? "Unavailable"
            
            if let location = json["location"] as? [String: Any],
               let lat = location["lat"] as? Double,
               let long = location["long"] as? Double {
                sellerLocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
            }
            
            contactMethods = json["contact_methods"] as? [String] ?? []
            apps = json["apps"] as? [String] ?? []
        }
    }
}

struct MapView: View {
    var coordinate: CLLocationCoordinate2D
    
    var body: some View {
        Map(
            coordinateRegion: .constant(MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )),
            annotationItems: [MapLocation(coordinate: coordinate)]
        ) { location in
            MapAnnotation(coordinate: location.coordinate) {
                Image(systemName: "mappin")
                    .foregroundColor(.red)
                    .font(.title)
            }
        }
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct MapLocation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

// Reusable Contact Button Component
struct ContactButton: View {
    var iconName: String
    var title: String
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button(action: {
            action?()
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


// Preview Provider
struct Seller_Profile_Previews: PreviewProvider {
    static var previews: some View {
        Seller_Profile(sellerID: "AmfnxUhi3E3sSZGQMgXp")
    }
}
