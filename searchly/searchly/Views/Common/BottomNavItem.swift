//
//  BottomNavItem.swift
//  searchly
//
//  Created by cobsccompy4231p-007 on 2024-11-10.
//

import SwiftUI
import Foundation

struct BottomNavItem: View {
    var iconName: String
    var title: String
    var isActive: Bool
    
    var body: some View {
        VStack {
            Image(iconName)
                .resizable()
                .scaledToFit()
                .frame(width: isActive ? 24 : 20, height: isActive ? 24 : 20)
                .foregroundColor(isActive ? Color(hex: "#F2A213") : .white)
            Text(title)
                .font(.custom("Heebo-Regular", size: 10))
                .padding(.top, 2)
                .foregroundColor(isActive ? Color(hex: "#F2A213") : .white)
        }
    }
}
