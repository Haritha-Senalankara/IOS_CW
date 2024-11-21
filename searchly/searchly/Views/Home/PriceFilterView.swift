//
//  PriceFilterView.swift
//  searchly
//
//  Created by cobsccompy4231p-007 on 2024-11-10.
//

import SwiftUI
import Foundation

struct PriceFilterView: View {
    @Binding var selectedMinPrice: Double
    @Binding var selectedMaxPrice: Double
    @Binding var isPresented: Bool
    var onApply: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Minimum Price: Rs.\(Int(selectedMinPrice))")
                .font(.custom("Heebo-Regular", size: 18))
                .padding(.top, 20)
            
            Slider(value: $selectedMinPrice, in: 0...selectedMaxPrice, step: 10000)
                .accentColor(Color(hex: "#F2A213"))
                .padding(.horizontal, 20)
            
            Text("Maximum Price: Rs.\(Int(selectedMaxPrice))")
                .font(.custom("Heebo-Regular", size: 18))
                .padding(.top, 10)
            
            Slider(value: $selectedMaxPrice, in: selectedMinPrice...1000000, step: 10000)
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
