//
//  Forgot Password Step 3.swift
//  searchly
//
//  Created by cobsccompy4231p-007 on 2024-10-27.
//

import SwiftUI

struct Forgot_Password_Step_3: View {
    @State private var newPassword: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image("App Logo")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
            
            Text("Set New Password")
                .font(.custom("Heebo-Bold", size: 26))
                .multilineTextAlignment(.center)
                .foregroundColor(Color(hex: "#102A36"))
            
            Text("Please enter your new password below.")
                .font(.custom("Heebo-Regular", size: 16))
                .multilineTextAlignment(.center)
                .foregroundColor(Color(hex: "#606084"))
                .padding(.horizontal, 20)
            
            Spacer()
            
            VStack(spacing: 15) {
                HStack {
                    SecureField("New Password", text: $newPassword)
                        .font(.custom("Heebo-Regular", size: 16))
                        .padding()
                    
                    if !newPassword.isEmpty {
                        Button(action: {
                            newPassword = ""
                        }) {
                            Image("icon-x")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                        }
                        .padding(.trailing, 8)
                    }
                }
                .overlay(Rectangle().frame(height: 1).padding(.top, 35), alignment: .bottom)
                .foregroundColor(Color.gray)
                .padding(.horizontal, 30)
            }
            
            Button(action: {
            }) {
                Text("Next")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "#F2A213"))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 30)
            .padding(.top, 20)
            
            Spacer()
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    Forgot_Password_Step_3()
}
