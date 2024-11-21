//
//  Forgot Password Step 5.swift
//  searchly
//
//  Created by cobsccompy4231p-007 on 2024-10-27.
//

import SwiftUI

struct Forgot_Password_Step_5: View {
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image("thumbs-up")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
            
            Text("New password has been set successfully.")
                .font(.custom("Heebo-Bold", size: 20))
                .multilineTextAlignment(.center)
                .foregroundColor(Color(hex: "#102A36"))
                .padding(.horizontal, 20)
            
            Spacer()
            
            Button(action: {
            }) {
                Text("Back To Login")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "#F2A213"))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 30)
            
            Spacer()
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    Forgot_Password_Step_5()
}
