//
//  LikesFilterView.swift
//  searchly
//
//  Created by cobsccompy4231p-007 on 2024-11-10.
//

import SwiftUI
import Foundation

// MARK: - LikesFilterView
struct LikesFilterView: View {
    @Binding var selectedLikes: Int
    @Binding var isPresented: Bool
    var onApply: () -> Void // Closure to execute when 'Apply' is tapped
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Minimum Likes: \(selectedLikes)")
                .font(.custom("Heebo-Regular", size: 18))
                .padding(.top, 20)
            
            Slider(value: Binding(get: {
                Double(selectedLikes)
            }, set: {
                selectedLikes = Int($0)
            }), in: 0...1000, step: 10)
                .accentColor(Color(hex: "#F2A213"))
                .padding(.horizontal, 20)
            
            Button(action: {
                isPresented = false
                onApply()
            }) {
                Text("Apply")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "#F2A213"))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .padding(.bottom, 30)
        .background(Color.white)
        .cornerRadius(12)
    }
}
