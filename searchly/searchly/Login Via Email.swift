//
//  Login Via Email.swift
//  searchly
//
//  Created by cobsccompy4231p-007 on 2024-10-27.
//

import SwiftUI

struct Login_Via_Email: View {
    @State private var username: String = ""
        @State private var password: String = ""

        var body: some View {
            VStack(spacing: 20) {
                Spacer()
                
                Image("App Logo") // Make sure this matches the image in your assets
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                
                Text("Login")
                    .font(.custom("Heebo-Bold", size: 26))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(hex: "#102A36"))
                
                Text("Log in to track your favorite products, set price alerts and unlock many features.")
                    .font(.custom("Heebo-Regular", size: 16))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(hex: "#606084"))
                    .padding(.horizontal, 20)
                
                Spacer()
                
                VStack(spacing: 15) {
                    HStack {
                        TextField("Enter your name", text: $username)
                            .font(.custom("Heebo-Regular", size: 16))
                            .padding()
                        
                        if !username.isEmpty {
                            Button(action: {
                                username = ""
                            }) {
                                Image("icon-x")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                            }
                        }
                    }
                    .overlay(Rectangle().frame(height: 1).padding(.top, 35), alignment: .bottom)
                    .foregroundColor(Color.gray)
                    .padding(.horizontal, 30)
                    
                    HStack {
                        SecureField("Enter your password", text: $password)
                            .font(.custom("Heebo-Regular", size: 16))
                            .padding()
                        
                        if !password.isEmpty {
                            Button(action: {
                                password = ""
                            }) {
                                Image("icon-x")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                            }
                        }
                    }
                    .overlay(Rectangle().frame(height: 1).padding(.top, 35), alignment: .bottom)
                    .foregroundColor(Color.gray)
                    .padding(.horizontal, 30)
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            // Forgot Password action
                        }) {
                            Text("Forgot Password?")
                                .font(.custom("Heebo-Regular", size: 14))
                                .foregroundColor(Color(hex: "#606084"))
                        }
                        .padding(.trailing, 30)
                    }
                }
                
                Button(action: {
                    // Login action
                }) {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "#F2A213"))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 30)
                .padding(.top, 20)
                
                Button(action: {
                    // Sign up action
                }) {
                    Text("Sign Up")
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

#Preview {
    Login_Via_Email()
}
