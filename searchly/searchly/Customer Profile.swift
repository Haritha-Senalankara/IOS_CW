import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct Customer_Profile: View {
    @State private var name: String = "Loading..." // Default value for name
    @State private var profileImageURL: String = "" // Default value for profile image URL
    @State private var isLoading: Bool = true // Loading state
    @State private var navigateToOnboarding: Bool = false // For logout navigation

    // Additional Profile Fields
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var phoneNumber: String = ""
    @State private var gender: String = "Male" // Default gender

    private let db = Firestore.firestore() // Firestore reference

    var body: some View {
        VStack(spacing: 0) {
            
            // Profile Picture and Name Section
            VStack(spacing: 15) {
                if isLoading {
                    // Show a loading placeholder while data is being fetched
                    ProgressView()
                        .frame(width: 100, height: 100)
                } else {
                    // Profile Image
                    AsyncImage(url: URL(string: profileImageURL)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color(hexValue: "#F2A213"), lineWidth: 2))
                    } placeholder: {
                        Image(systemName: "person.circle.fill") // Placeholder image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(Color(hexValue: "#F2A213"))
                            .background(Color(hexValue: "#F9F0DC"))
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color(hexValue: "#F2A213"), lineWidth: 2))
                    }
                }

                // Name and Edit Icon
                HStack(spacing: 8) {
                    Text(name)
                        .font(.custom("Heebo-Bold", size: 18))
                        .foregroundColor(Color(hexValue: "#102A36"))
                }
            }
            .padding(.bottom, 40)
            .padding(.top, 50)
            
            // Additional Profile Editing Section
            VStack(spacing: 20) {
                // First Name
                HStack {
                    Text("First Name")
                        .font(.headline)
                        .frame(width: 100, alignment: .leading)
                    TextField("Enter first name", text: $firstName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // Last Name
                HStack {
                    Text("Last Name")
                        .font(.headline)
                        .frame(width: 100, alignment: .leading)
                    TextField("Enter last name", text: $lastName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // Phone Number
                HStack {
                    Text("Phone")
                        .font(.headline)
                        .frame(width: 100, alignment: .leading)
                    TextField("Enter phone number", text: $phoneNumber)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.phonePad)
                }
                
                // Gender Selector
                HStack {
                    Text("Gender")
                        .font(.headline)
                        .frame(width: 100, alignment: .leading)
                    Picker("Gender", selection: $gender) {
                        Text("Male").tag("Male")
                        Text("Female").tag("Female")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(maxWidth: 200)
                }
                
                // Save Button
                Button(action: saveProfile) {
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
            
            
            
            
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            fetchCustomerProfile()
        }
    }
    
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
            "name": firstName + " " + lastName
        ]
        
        db.collection("customers").document(userID).updateData(updatedData) { error in
            if let error = error {
                print("Error updating profile: \(error.localizedDescription)")
            } else {
                print("Profile updated successfully.")
            }
        }
    }

}

// Preview
#Preview {
    Customer_Profile()
}
