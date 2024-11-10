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
//            Image(systemName: "person.circle.fill") // Placeholder for seller logo
//                .resizable()
//                .scaledToFit()
//                .frame(width: 100, height: 100)
//                .padding(.top, 10)
//            
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
                            UIApplication.shared.open(phoneURL)
                        }
                    }
                    ContactButton(iconName: "message.fill", title: "WhatsApp") {
                        if let whatsappURL = URL(string: "https://wa.me/\(whatsappNumber)") {
                            UIApplication.shared.open(whatsappURL)
                        }
                    }
                }
                HStack(spacing: 20) {
                    ContactButton(iconName: "globe", title: "Website") {
                        if let url = URL(string: sellerWebsite) {
                            UIApplication.shared.open(url)
                        }
                    }
                    ContactButton(iconName: "square.and.arrow.up", title: "Share")
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
                
//                Text("Email: \(sellerEmail)")
//                    .font(.custom("Heebo-Bold", size: 14))
//                    .foregroundColor(Color(hexValue: "#102A36"))
//                    .padding(.horizontal, 20)
            }
            
            // Map
            if let location = sellerLocation {
                MapView(coordinate: location)
                    .frame(height: 200)
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
            } else {
                Text("Loading map...")
                    .font(.custom("Heebo-Regular", size: 14))
                    .foregroundColor(.gray)
                    .padding(.top, 20)
            }
            
            Spacer()
            
            // Bottom Navigation Bar
            Divider()
            HStack {
                BottomNavItem(iconName: "home-icon", title: "Home", isActive: false)
                Spacer()
                BottomNavItem(iconName: "heart-icon", title: "Favorites", isActive: false)
                Spacer()
                BottomNavItem(iconName: "settings-icon", title: "Settings", isActive: false)
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 10)
            .background(Color(hexValue: "#102A36")) // Dark color as per style guide
            .foregroundColor(.white)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 0)
            .padding(.bottom, 20)
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            fetchSellerData()
        }
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

// MapView Component
struct MapView: View {
    var coordinate: CLLocationCoordinate2D
    
    var body: some View {
        Map(coordinateRegion: .constant(MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
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
