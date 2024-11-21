import SwiftUI

struct onboarding: View {
    @State private var navigateToLoginSignup = false
    @State private var navigateToHome = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()
                
                Image("App Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 133, height: 121)
                    .padding(.top, 40)
                
                Text("Get Started with Your\n Account")
                    .font(.custom("Heebo-Bold", size: 26))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(hex: "#102A36"))
                    .padding(.top, 24)
                
                Text("Find the best deals online and locally. Filter products by price, location, and ratings to ensure you get the best value. Connect directly with vendors for quick and easy access to great offers.")
                    .font(.custom("Heebo-Regular", size: 14))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(hex: "#606084"))
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                
                Spacer()
                
                VStack(spacing: 28) {
                    Button(action: {
                        navigateToLoginSignup = true
                    }) {
                        Text("Sign In")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "#F2A213"))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 30)
                    
                    Button(action: {
                        navigateToLoginSignup = true
                    }) {
                        Text("Create A Profile")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(hex: "#F2A213"), lineWidth: 2)
                            )
                            .foregroundColor(Color(hex: "#F2A213"))
                    }
                    .padding(.horizontal, 30)
                }
                .padding(.top, 50)
                Spacer(minLength: 160)
                
                Spacer()
            }
            .background(Color.white)
            .edgesIgnoringSafeArea(.all)
            .background(
                NavigationLink(
                    destination: Login_or_Signup(),
                    isActive: $navigateToLoginSignup
                ) {
                    EmptyView()
                }
                    .hidden()
            )
            .background(
                NavigationLink(
                    destination: Home(),
                    isActive: $navigateToHome
                ) {
                    EmptyView()
                }
                    .hidden()
            )
            .onAppear {
                handleOnAppear()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarBackButtonHidden(true)
    }
    
    private func handleOnAppear() {
        let defaults = UserDefaults.standard
        let isFirstLaunch = !defaults.bool(forKey: "hasLaunchedBefore")
        
        if isFirstLaunch {
            defaults.set(true, forKey: "hasLaunchedBefore")
            print("App launched for the first time. Staying on onboarding screen.")
        } else {
            checkUserStatus()
        }
    }
    
    private func checkUserStatus() {
        let defaults = UserDefaults.standard
        
        if defaults.dictionaryRepresentation().isEmpty {
            print("UserDefaults are empty. Doing nothing.")
            return
        }
        
        let isLoggedOut = defaults.bool(forKey: "isLoggedOut")
        
        if isLoggedOut {
            navigateToLoginSignup = true
            print("User is logged out. Redirecting to login/signup page.")
        } else if let _ = defaults.string(forKey: "userID") {
            navigateToHome = true
            print("User is logged in. Redirecting to home page.")
        } else {
            navigateToLoginSignup = true
            print("No user ID found. Staying on login/signup page.")
        }
    }
}


#Preview {
    onboarding()
}

