//
//  IconActionButton.swift
//  searchly
//
//  Created by cobsccompy4231p-007 on 2024-11-10.
//

import SwiftUI
import Foundation

// Reusable Icon Button Component for Product Actions
struct IconActionButton: View {
    var iconName: String
    var label: String
    
    var body: some View {
        HStack(spacing: 5) {
            Image(iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18) // Adjust icon size for consistency
            if !label.isEmpty {
                Text(label)
                    .font(.custom("Heebo-Regular", size: 12))
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}
