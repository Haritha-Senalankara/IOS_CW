//
//  Product_Page.swift
//  searchly
//
//  Created by cobsccompy4231p-007 on 2024-10-27.
//

import SwiftUI
import FirebaseFirestore
import EventKit

struct Product_Page: View {
    @State private var isLoading: Bool = true // Show loading indicator
    let productID: String // Accept product ID as a parameter
    @State private var isExpanded: Bool = false

    @State private var showRatingInput: Bool = false // Toggle for showing rating input
    @State private var userRating: Int = 5
    @State private var userComment: String = ""

    @State private var showReviews: Bool = false // Show all reviews
    @State private var reviews: [Review] = []

    @State private var showDatePicker: Bool = false // Show/Hide DatePicker
    @State private var reminderDate: Date = Date() // Selected reminder date and time

    private let db = Firestore.firestore() // Firestore reference
    private let eventStore = EKEventStore()

    // Variables for product details
    @State private var product_name: String = "Apple iPhone 15 Pro 128GB"
    @State private var seller_name: String = "Appleasia.lk"
    @State private var seller_likes: String = "1"
    @State private var seller_id: String = "" // Seller ID for navigation
    @State private var product_likes: Int = 652
    @State private var product_dislikes: Int = 1
    @State private var product_ratings: Double = 4.5 // Average rating
    @State private var product_desc: String = "..."
    @State private var product_img: String = "..."
    @State private var seller_profile_img_link: String = "..."
    @State private var product_price: Int = 120000

    @State private var otherProducts: [Products] = []

    // New state variables for favorite and like/dislike functionality
    @State private var isFavorite: Bool = false
    @State private var hasLiked: Bool = false
    @State private var hasDisliked: Bool = false
    @State private var userID: String = ""
    
    @State private var searchText: String = ""
    
    var body: some View {
        NavigationView{
            ZStack {
                ScrollView {
                    VStack(spacing: 0) {
                        // Top Navigation Bar
                        HStack {
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
                                
                                // Heart Icon with tap gesture
                                Image(isFavorite ? "heart-icon-filled" : "heart-icon-only-border")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                    .onTapGesture {
                                        toggleFavorite()
                                    }
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

                                    // NavigationLink for seller name
                                    NavigationLink(destination: Seller_Profile(sellerID: seller_id)) {
                                        Text(seller_name)
                                            .font(.custom("Heebo-Regular", size: 12))
                                            .foregroundColor(.black) // Make it look clickable
                                    }

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
                                    // Like Button with tap gesture
                                    IconActionButton(iconName: hasLiked ? "like-icon-product" : "like-icon-product", label: String(product_likes))
                                        .onTapGesture {
                                            toggleLike()
                                        }
                                    
                                    // Dislike Button with tap gesture
                                    IconActionButton(iconName: hasDisliked ? "dislike-icon-product" : "dislike-icon-product", label: String(product_dislikes))
                                        .onTapGesture {
                                            toggleDislike()
                                        }
                                    
                                    IconActionButton(iconName: "share-icon-product", label: "Share")
                                        .onTapGesture {
                                            shareProduct()
                                        }
                                    
                                    IconActionButton(iconName: "star-icon-product", label: String(format: "%.1f", product_ratings))
                                        .onTapGesture {
                                            withAnimation {
                                                showRatingInput.toggle() // Toggle the rating input modal
                                            }
                                        }
                                    
                                    IconActionButton(iconName: "calander-icon-product", label: "Remind")
                                        .onTapGesture {
                                            withAnimation {
                                                showDatePicker.toggle()
                                            }
                                        }
                                }
                                .padding(.top, 5)
                            }
                            
                            if showReviews {
                                VStack(alignment: .leading) {
                                    Text("Customer Reviews")
                                        .font(.headline)
                                        .padding()
                                    
                                    ForEach(reviews) { review in
                                        VStack(alignment: .leading) {
                                            HStack {
                                                Text("\(review.rating) ★")
                                                    .font(.subheadline)
                                                    .foregroundColor(.yellow)
                                                
                                                Spacer()
                                                
                                                Text("User: \(review.userID)")
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                            }
                                            
                                            Text(review.comment)
                                                .padding(.top, 5)
                                        }
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(8)
                                        .shadow(radius: 5)
                                        .padding(.horizontal)
                                        .padding(.bottom, 10)
                                    }
                                }
                            }
                            
                            
                            if showRatingInput {
                                VStack {
                                    Text("Rate the Product")
                                        .font(.headline)
                                    
                                    Picker("Rating", selection: $userRating) {
                                        ForEach(1...5, id: \.self) { rating in
                                            Text("\(rating) ★").tag(rating)
                                        }
                                    }
                                    .pickerStyle(SegmentedPickerStyle())
                                    .padding()
                                    
                                    TextField("Leave a comment", text: $userComment)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .padding()
                                    
                                    Button("Submit") {
                                        addReview() // Call the function to save the review
                                        showRatingInput = false
                                    }
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.green)
                                    .cornerRadius(8)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(radius: 10)
                            }
                            
                            
                            // Date Picker Section
                            if showDatePicker {
                                VStack(spacing: 10) {
                                    Text("Select Reminder Date & Time")
                                        .font(.custom("Heebo-Bold", size: 16))
                                        .foregroundColor(.gray)
                                    
                                    DatePicker("Reminder Date", selection: $reminderDate, displayedComponents: [.date, .hourAndMinute])
                                        .datePickerStyle(WheelDatePickerStyle())
                                        .labelsHidden()
                                        .frame(maxWidth: .infinity)
                                    
                                    Button(action: {
                                        withAnimation {
                                            showDatePicker = false
                                        }
                                        addReminder()
                                    }) {
                                        Text("Set Reminder")
                                            .font(.custom("Heebo-Bold", size: 16))
                                            .foregroundColor(.white)
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(Color(hexValue: "#F2A213"))
                                            .cornerRadius(8)
                                    }
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                                .padding(.horizontal, 20)
                                .padding(.top, 10)
                            }
                            
                            // Product Description (Expandable)
                            Text(product_desc)
                                .font(.custom("Heebo-Regular", size: 14))
                                .foregroundColor(.gray)
                                .lineLimit(isExpanded ? nil : 3)
                                .onTapGesture {
                                    withAnimation {
                                        isExpanded.toggle()
                                    }
                                }
                                .padding(.top, 10)

                            if !isExpanded {
                                Button(action: {
                                    withAnimation {
                                        isExpanded = true
                                    }
                                }) {
                                    Text("Read More")
                                        .font(.custom("Heebo-Regular", size: 14))
                                        .foregroundColor(.black)
                                }
                                .padding(.top, 5)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        
                        Spacer()
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Similar Products")
                                .font(.custom("Heebo-Bold", size: 16))
                                .padding(.horizontal, 20)
                                .padding(.top, 10)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHGrid(rows: [GridItem(.fixed(180))], spacing: 20) {
                                    ForEach(otherProducts, id: \.id) { product in
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
                            }
                        }
                    }
                }
                }
                .background(Color.white)
                .edgesIgnoringSafeArea(.all)
            }
            .onAppear {
                // Get user ID from UserDefaults
                if let uid = UserDefaults.standard.string(forKey: "userID") {
                    self.userID = uid
                    checkIfFavorite()
                    checkUserInteraction()
                } else {
                    print("User ID not found in UserDefaults")
                }

                fetchProductDetails()
                fetchOtherProducts()
            }
        }
    
    private func shareProduct() {
        let activityVC = UIActivityViewController(activityItems: [product_name, URL(string: product_img)!], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
    }

    private func addReview() {
        guard !userID.isEmpty else { return }

        let reviewID = UUID().uuidString
        let reviewData: [String: Any] = [
            "userID": userID,
            "rating": userRating,
            "comment": userComment
        ]

        db.collection("products").document(productID).collection("reviews").document(reviewID).setData(reviewData) { error in
            if let error = error {
                print("Error adding review: \(error.localizedDescription)")
                return
            }

            // Update the user's profile with the review
            db.collection("customers").document(userID).updateData([
                "reviews": FieldValue.arrayUnion([reviewID])
            ])

            // Fetch the updated reviews
            fetchReviews()
        }
    }

    private func fetchReviews() {
        db.collection("products").document(productID).collection("reviews").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching reviews: \(error)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("No reviews found")
                return
            }

            DispatchQueue.main.async {
                self.reviews = documents.map { doc -> Review in
                    let data = doc.data()
                    
                    // Convert rating to Double, then to Int if needed
                    let ratingString = data["rating"] as? String ?? "\(data["rating"] as? Double ?? 0.0)"
                    let ratingDouble = Double(ratingString) ?? 0.0
                    let rating = Int(ratingDouble) // Convert to Int if needed

                    return Review(
                        id: doc.documentID,
                        userID: data["userID"] as? String ?? "Unknown User",
                        rating: rating, // Ensure this matches the type in the Review struct
                        comment: data["comment"] as? String ?? "No comment"
                    )
                }
            }
        }
    }
    
    private func addReminder() {
        eventStore.requestAccess(to: .event) { granted, error in
            if let error = error {
                print("Error requesting calendar access: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    showAlert(title: "Error", message: "An error occurred while requesting access to your calendar.")
                }
                return
            }
            
            if granted {
                DispatchQueue.main.async { // Use .async to dispatch to the main thread
                    createEvent()
                }
            } else {
                DispatchQueue.main.async { // Use .async here as well
                    showAlert(
                        title: "Permission Denied",
                        message: "Calendar access is required to add a reminder. Please enable it in the Settings app."
                    )
                }
            }
        }
    }


    private func createEvent() {
            let event = EKEvent(eventStore: self.eventStore)
            event.title = self.product_name
            event.notes = self.product_desc
            event.startDate = self.reminderDate // Use selected date
            event.endDate = self.reminderDate.addingTimeInterval(3600) // 1-hour duration
            event.calendar = self.eventStore.defaultCalendarForNewEvents

            do {
                try self.eventStore.save(event, span: .thisEvent)
                print("Event added to calendar")
                showAlert(title: "Reminder Added", message: "A reminder for \(self.product_name) has been added to your calendar.")
            } catch {
                print("Error saving event to calendar: \(error.localizedDescription)")
                showAlert(title: "Error", message: "Failed to add the reminder. Please try again.")
            }
        }

    private func showAlert(title: String, message: String) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))

            if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
                rootViewController.present(alert, animated: true, completion: nil)
            }
        }
    
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
                seller_id = data["seller_id"] as? String ?? "Unknown seller"
                product_likes = data["likes"] as? Int ?? 0
                product_dislikes = data["dislikes"] as? Int ?? 0
                product_ratings = Double(data["rating"] as? String ?? "\(data["rating"] as? Double ?? 0.0)") ?? 0.0
                product_desc = data["description"] as? String ?? "No description available."
                product_img = data["product_image"] as? String ?? ""
                product_price = Int(data["price"] as? String ?? "\(data["price"] as? Int ?? 0)") ?? 0

                if let sellerID = data["seller_id"] as? String {
                    fetchSellerProfile(sellerID: sellerID)
                }
            }
        }
    }

    
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
                        price: Double(data["price"] as? String ?? "\(data["price"] as? Double ?? 0.0)") ?? 0.0,
                        siteName: data["siteName"] as? String ?? "Unknown Seller",
                        likes: data["likes"] as? Int ?? 0,
                        dislikes: data["dislikes"] as? Int ?? 0,
                        rating: Double(data["rating"] as? String ?? "\(data["rating"] as? Double ?? 0.0)") ?? 0.0,
                        categories: [], // Adjust as per your data structure
                        imageName: data["product_image"] as? String ?? ""
                    )
                }
            }
        }
    }

    
    // Fetch seller profile
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
    
    // Check if the product is already in favorites
    private func checkIfFavorite() {
        guard !userID.isEmpty else { return }
        
        db.collection("customers").document(userID).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching customer data: \(error)")
                return
            }
            
            guard let data = snapshot?.data() else {
                print("No customer data found for ID: \(userID)")
                return
            }
            
            if let favList = data["fav_list"] as? [String] {
                DispatchQueue.main.async {
                    self.isFavorite = favList.contains(self.productID)
                }
            } else {
                DispatchQueue.main.async {
                    self.isFavorite = false
                }
            }
        }
    }
    
    // Toggle favorite status
    private func toggleFavorite() {
        guard !userID.isEmpty else { return }
        
        let customerRef = db.collection("customers").document(userID)
        
        if isFavorite {
            // Remove from favorites
            customerRef.updateData([
                "fav_list": FieldValue.arrayRemove([productID])
            ]) { error in
                if let error = error {
                    print("Error removing favorite: \(error)")
                } else {
                    DispatchQueue.main.async {
                        self.isFavorite = false
                    }
                }
            }
        } else {
            // Add to favorites
            customerRef.updateData([
                "fav_list": FieldValue.arrayUnion([productID])
            ]) { error in
                if let error = error {
                    print("Error adding favorite: \(error)")
                } else {
                    DispatchQueue.main.async {
                        self.isFavorite = true
                    }
                }
            }
        }
    }
    
    // Check if the user has liked or disliked the product
    private func checkUserInteraction() {
        guard !userID.isEmpty else { return }
        
        let customerRef = db.collection("customers").document(userID)
        customerRef.getDocument { snapshot, error in
            if let error = error {
                print("Error fetching customer data: \(error)")
                return
            }
            
            guard let data = snapshot?.data() else {
                print("No customer data found for ID: \(userID)")
                return
            }
            
            if let likedProducts = data["liked_products"] as? [String] {
                DispatchQueue.main.async {
                    self.hasLiked = likedProducts.contains(self.productID)
                }
            }
            
            if let dislikedProducts = data["disliked_products"] as? [String] {
                DispatchQueue.main.async {
                    self.hasDisliked = dislikedProducts.contains(self.productID)
                }
            }
        }
    }
    
    private func toggleLike() {
        guard !userID.isEmpty else { return }

        let productRef = db.collection("products").document(productID)
        let customerRef = db.collection("customers").document(userID)

        if hasLiked {
            productRef.updateData(["likes": FieldValue.increment(Int64(-1))])
            customerRef.updateData(["liked_products": FieldValue.arrayRemove([productID])]) { error in
                if error == nil {
                    DispatchQueue.main.async {
                        self.product_likes -= 1
                        self.hasLiked = false
                    }
                }
            }
        } else {
            var updates: [String: Any] = ["likes": FieldValue.increment(Int64(1))]
            var customerUpdates: [String: Any] = ["liked_products": FieldValue.arrayUnion([productID])]

            if hasDisliked {
                updates["dislikes"] = FieldValue.increment(Int64(-1))
                customerUpdates["disliked_products"] = FieldValue.arrayRemove([productID])
            }

            productRef.updateData(updates)
            customerRef.updateData(customerUpdates) { error in
                if error == nil {
                    DispatchQueue.main.async {
                        self.product_likes += 1
                        self.hasLiked = true
                        if self.hasDisliked {
                            self.product_dislikes -= 1
                            self.hasDisliked = false
                        }
                    }
                }
            }
        }
    }

    
    // Toggle dislike status
    private func toggleDislike() {
        guard !userID.isEmpty else { return }
        
        let productRef = db.collection("products").document(productID)
        let customerRef = db.collection("customers").document(userID)
        
        if hasDisliked {
            // Remove dislike
            productRef.updateData([
                "dislikes": FieldValue.increment(Int64(-1))
            ])
            customerRef.updateData([
                "disliked_products": FieldValue.arrayRemove([productID])
            ]) { error in
                if let error = error {
                    print("Error removing dislike: \(error)")
                } else {
                    DispatchQueue.main.async {
                        self.product_dislikes -= 1
                        self.hasDisliked = false
                    }
                }
            }
        } else {
            // Dislike the product
            var updates: [String: Any] = [
                "dislikes": FieldValue.increment(Int64(1))
            ]
            var customerUpdates: [String: Any] = [
                "disliked_products": FieldValue.arrayUnion([productID])
            ]
            if hasLiked {
                // Remove like
                updates["likes"] = FieldValue.increment(Int64(-1))
                customerUpdates["liked_products"] = FieldValue.arrayRemove([productID])
            }
            productRef.updateData(updates)
            customerRef.updateData(customerUpdates) { error in
                if let error = error {
                    print("Error disliking product: \(error)")
                } else {
                    DispatchQueue.main.async {
                        self.product_dislikes += 1
                        self.hasDisliked = true
                        if self.hasLiked {
                            self.product_likes -= 1
                            self.hasLiked = false
                        }
                    }
                }
            }
        }
    }
    
}

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

// Preview Provider
struct Product_Page_Previews: PreviewProvider {
    static var previews: some View {
        Product_Page(productID: "AqLHYVv64EVezlPHmyQ6")
    }
}
