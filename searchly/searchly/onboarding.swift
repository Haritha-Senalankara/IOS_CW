//
//  onboarding.swift
//  searchly
//
//  Created by cobsccompy4231p-007 on 2024-10-27.
//

import SwiftUI

struct onboarding: View {
    var body: some View {
            VStack(spacing: 20) {
                Spacer()
                
                Image("App Logo") // Make sure this matches the image in your assets
                    .resizable()
                    .scaledToFit()
                    .frame(width: 133, height: 121)
                    .padding(.top, 40)
                
                Text("Get Started with Your\n Account")
                    .font(.custom("Heebo-Bold", size: 26))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(hex: "#102A36"))
                    .padding(.top,24)
                
                Text("Find the best deals online and locally. Filter products by price, location, and ratings to ensure you get the best value. Connect directly with vendors for quick and easy access to great offers.")
                    .font(.custom("Heebo-Regular", size: 14))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(hex: "#606084"))
                    .padding(.horizontal, 20)
                    .padding(.top,20)
                
                Spacer()
                
                VStack(spacing: 28) {
                    Button(action: {
                        // Sign In action
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
                        // Create a profile action
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
//                    .padding(.top,)
                }
                .padding(.top,50)
                
                Button(action: {
                    // Skip action
                }) {
                    Text("I'll do it later")
                        .font(.custom("Heebo-Regular", size: 14))
                        .foregroundColor(Color(hex: "#102A36"))
                }
                .padding(.top, 120)
                .padding(.bottom,30)
                
                Spacer()
            }
            .background(Color.white)
            .edgesIgnoringSafeArea(.all)
        }
}

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
    onboarding()
}
