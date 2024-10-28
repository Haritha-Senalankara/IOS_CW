//
//  Login or Signup.swift
//  searchly
//
//  Created by cobsccompy4231p-007 on 2024-10-27.
//

import SwiftUI

struct Login_or_Signup: View {
    var body: some View {
            VStack(spacing: 20) {
                Spacer()
                
                Image("App Logo") // Make sure this matches the image in your assets
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                
                Text("Login or Sign Up")
                    .font(.custom("Heebo-Bold", size: 26))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(hex: "#102A36"))
                
                Text("Log in or sign up to track your favorite products, set price alerts and unlock many features.")
                    .font(.custom("Heebo-Regular", size: 16))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(hex: "#606084"))
                    .padding(.horizontal, 20)
                
                Spacer()
                
                VStack(spacing: 15) {
                    Button(action: {
                        // Apple login action
                    }) {
                        HStack {
                            Image("Apple Logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                            Text("Continue with Apple")
                                .font(.custom("Heebo-Bold", size: 16))
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal, 30)
                    
                    Button(action: {
                        // Google login action
                    }) {
                        HStack {
                            Image("Google Logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                            Text("Continue with Google")
                                .font(.custom("Heebo-Bold", size: 16))
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 1)
                        )
                        .foregroundColor(Color.black)
                    }
                    .padding(.horizontal, 30)
                    
                    Button(action: {
                        // Email login action
                    }) {
                        HStack {
                            Image("Email Logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                            Text("Continue with Email")
                                .font(.custom("Heebo-Bold", size: 16))
                        }
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
                
                Button(action: {
                    // Skip action
                }) {
                    Text("I'll do it later")
                        .font(.custom("Heebo-Regular", size: 14))
                        .foregroundColor(Color(hex: "#102A36"))
                }
                .padding(.top, 10)
                
                Spacer()
            }
            .background(Color.white)
            .edgesIgnoringSafeArea(.all)
        }
}


extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        
        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}

#Preview {
    Login_or_Signup()
}
