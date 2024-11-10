//
//  CustomTextField.swift
//  searchly
//
//  Created by cobsccompy4231p-007 on 2024-11-10.
//

import SwiftUI
import Foundation

// Custom TextField Component
struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack {
            TextField(placeholder, text: $text)
                .font(.custom("Heebo-Regular", size: 16))
                .padding()
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
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
    }
}
