//
//  FilterButton.swift
//  searchly
//
//  Created by cobsccompy4231p-007 on 2024-11-10.
//

import SwiftUI
import Foundation

struct FilterButton: View {
    var iconName: String
    var title: String
    var action: (() -> Void)? = nil
    var body: some View {
        Button(action: { action?() }) {
            HStack {
                Image(iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                Text(title)
                    .font(.custom("Heebo-Regular", size: 12))
                    .foregroundColor(.black)
            }
            .padding(10)
            .frame(maxWidth: .infinity)
            .background(Color(hex: "#F7F7F7"))
            .cornerRadius(8)
        }
    }
}
