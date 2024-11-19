import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct Customer_Profile: View {
    @State private var name: String = "Loading..."
    @State private var profileImageURL: String = ""
    @State private var isLoading: Bool = true
    @State private var navigateToOnboarding: Bool = false
    
    // Additional Profile Fields
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var phoneNumber: String = ""
    @State private var gender: String = "Male"
    
    @State private var recentlyViewedProducts: [Products] = []
    @State private var generatedOTP: String = ""
    @State private var enteredOTP: String = ""
    @State private var showOTPPopup: Bool = false
    
    private let db = Firestore.firestore()
    
    var body: some View {
        VStack(spacing: 0) {
            // Profile Picture and Name Section
            VStack(spacing: 15) {
                if isLoading {
                    ProgressView()
                        .frame(width: 100, height: 100)
                } else {
                    AsyncImage(url: URL(string: profileImageURL)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color(hexValue: "#F2A213"), lineWidth: 2))
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(Color(hexValue: "#F2A213"))
                            .background(Color(hexValue: "#F9F0DC"))
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color(hexValue: "#F2A213"), lineWidth: 2))
                    }
                }
                
                HStack(spacing: 8) {
                    Text(name)
                        .font(.custom("Heebo-Bold", size: 18))
                        .foregroundColor(Color(hexValue: "#102A36"))
                }
            }
            .padding(.bottom, 40)
            .padding(.top, 50)
            
            // Profile Editing Section
            VStack(spacing: 20) {
                HStack {
                    Text("First Name")
                        .font(.headline)
                        .frame(width: 100, alignment: .leading)
                    TextField("Enter first name", text: $firstName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                HStack {
                    Text("Last Name")
                        .font(.headline)
                        .frame(width: 100, alignment: .leading)
                    TextField("Enter last name", text: $lastName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                HStack {
                    Text("Phone")
                        .font(.headline)
                        .frame(width: 100, alignment: .leading)
                    TextField("Enter phone number", text: $phoneNumber)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.phonePad)
                }
                
                HStack {
                    Text("Gender")
                        .font(.headline)
                        .frame(width: 100, alignment: .leading)
                    Picker("Gender", selection: $gender) {
                        Text("Male").tag("Male")
                        Text("Female").tag("Female")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Button(action: generateAndSendOTP) {
                    Text("Save")
                        .font(.custom("Heebo-Bold", size: 16))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hexValue: "#F2A213"))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.top, 20)
            }
            .padding(.horizontal, 20)
            
            Spacer()
            Divider()
            
            // Recently Viewed Products Section
            VStack(alignment: .leading, spacing: 10) {
                Text("Recently Viewed Products")
                    .font(.custom("Heebo-Bold", size: 16))
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                
                ScrollView(.vertical, showsIndicators: false) {
                    LazyHGrid(rows: [GridItem(.fixed(180))], spacing: 20) {
                        ForEach(recentlyViewedProducts, id: \.id) { product in
                            NavigationLink(destination: Product_Page(productID: product.id)) {
                                ProductCard(
                                    imageName: product.imageName,
                                    name: product.name,
                                    siteName: product.siteName,
                                    price: "\(Int(product.price))",
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
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            fetchCustomerProfile()
            fetchRecentlyViewedProducts()
        }
        .sheet(isPresented: $showOTPPopup) {
            OTPVerificationPopup(
                enteredOTP: $enteredOTP,
                generatedOTP: generatedOTP,
                onVerify: verifyOTP
            )
        }
    }
    
    // MARK: - Generate and Send OTP
    private func generateAndSendOTP() {
        guard !phoneNumber.isEmpty else {
            print("Phone number is empty")
            return
        }
        
        // Generate a random 6-digit OTP
        generatedOTP = String(format: "%06d", Int.random(in: 100000...999999))
        
        // Save OTP in Firestore
        let otpData: [String: Any] = [
            "to": "\(phoneNumber)",
            "otp_msg": "Your OTP is \(generatedOTP)"
        ]
        
        db.collection("OTP").addDocument(data: otpData) { error in
            if let error = error {
                print("Error saving OTP: \(error.localizedDescription)")
            } else {
                print("OTP saved successfully. Sent to \(phoneNumber)")
                // Show OTP popup
                showOTPPopup = true
            }
        }
    }
    
    // MARK: - Verify OTP
    private func verifyOTP() {
        if enteredOTP == generatedOTP {
            saveProfile() // Save the profile if OTP matches
            showOTPPopup = false // Dismiss the popup
        } else {
            print("Invalid OTP")
        }
    }
    
    // MARK: - Save Profile to Firestore
    private func saveProfile() {
        guard let userID = UserDefaults.standard.string(forKey: "userID") else {
            print("User ID not found")
            return
        }
        
        let updatedData: [String: Any] = [
            "first_name": firstName,
            "last_name": lastName,
            "phone": phoneNumber,
            "gender": gender,
            "name": "\(firstName) \(lastName)"
        ]
        
        db.collection("customers").document(userID).setData(updatedData, merge: true) { error in
            if let error = error {
                print("Error updating profile: \(error.localizedDescription)")
            } else {
                print("Profile updated successfully.")
            }
        }
    }
    
    // MARK: - Fetch Customer Profile
    private func fetchCustomerProfile() {
        guard let userID = UserDefaults.standard.string(forKey: "userID") else {
            print("User ID not found in UserDefaults")
            return
        }
        
        db.collection("customers").document(userID).getDocument { document, error in
            if let error = error {
                print("Error fetching customer profile: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists {
                let data = document.data()
                DispatchQueue.main.async {
                    self.name = data?["name"] as? String ?? "Unknown Name"
                    self.profileImageURL = data?["profile_image"] as? String ?? ""
                    self.firstName = data?["first_name"] as? String ?? ""
                    self.lastName = data?["last_name"] as? String ?? ""
                    self.phoneNumber = data?["phone"] as? String ?? ""
                    self.gender = data?["gender"] as? String ?? "Male"
                    self.isLoading = false
                }
            } else {
                print("No document found for user ID: \(userID)")
            }
        }
    }
    
    // MARK: - Fetch Recently Viewed Products
    private func fetchRecentlyViewedProducts() {
        guard let userID = UserDefaults.standard.string(forKey: "userID") else {
            print("User ID not found in UserDefaults")
            return
        }
        
        db.collection("customers").document(userID).getDocument { document, error in
            if let error = error {
                print("Error fetching customer data: \(error.localizedDescription)")
                return
            }
            
            guard let document = document, document.exists, let data = document.data() else {
                print("No document found for user ID: \(userID)")
                return
            }
            
            guard let recentlyVisitedData = data["recently_visited_products"] as? [[String: Any]] else {
                print("No recently visited products found for user ID: \(userID)")
                return
            }
            
            let sortedVisited = recentlyVisitedData.compactMap { dict -> (String, Date)? in
                guard let productID = dict["productID"] as? String,
                      let timestamp = dict["timestamp"] as? Timestamp else {
                    return nil
                }
                return (productID, timestamp.dateValue())
            }.sorted { $0.1 > $1.1 }
            
            let productIDs = Array(Set(sortedVisited.map { $0.0 })).prefix(10)
            
            if productIDs.isEmpty {
                print("No recently viewed products to display.")
                return
            }
            
            db.collection("products")
                .whereField(FieldPath.documentID(), in: Array(productIDs))
                .getDocuments { snapshot, error in
                    if let error = error {
                        print("Error fetching products: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let documents = snapshot?.documents else {
                        print("No products found.")
                        return
                    }
                    
                    let products: [Products] = documents.compactMap { doc in
                        let data = doc.data()
                        let id = doc.documentID
                        let name = data["name"] as? String ?? "Unknown Product"
                        let imageName = data["product_image"] as? String ?? ""
                        let priceString = data["price"] as? String ?? "\(data["price"] as? Double ?? 0.0)"
                        let price = Double(priceString) ?? 0.0
                        let siteName = data["siteName"] as? String ?? "Unknown Seller"
                        let likes = data["likes"] as? Int ?? 0
                        let dislikes = data["dislikes"] as? Int ?? 0
                        let ratingString = data["rating"] as? String ?? "\(data["rating"] as? Double ?? 0.0)"
                        let rating = Double(ratingString) ?? 0.0
                        let categories = data["categories"] as? [String] ?? []
                        
                        return Products(
                            id: id,
                            name: name,
                            price: price,
                            siteName: siteName,
                            likes: likes,
                            dislikes: dislikes,
                            rating: rating,
                            categories: categories,
                            imageName: imageName
                        )
                    }
                    
                    let sortedProducts = productIDs.compactMap { id in
                        products.first(where: { $0.id == id })
                    }
                    
                    DispatchQueue.main.async {
                        self.recentlyViewedProducts = sortedProducts
                    }
                }
        }
    }
}

// MARK: - OTP Verification Popup
struct OTPVerificationPopup: View {
    @Binding var enteredOTP: String
    let generatedOTP: String
    let onVerify: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Verify OTP")
                .font(.headline)
            
            TextField("Enter OTP", text: $enteredOTP)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
            
            Button(action: onVerify) {
                Text("Verify")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.yellow)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            Button(action: {
                UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true)
            }) {
                Text("Cancel")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 10)
        .frame(maxWidth: 300)
    }
}

// MARK: - Preview
#Preview {
    Customer_Profile()
}
