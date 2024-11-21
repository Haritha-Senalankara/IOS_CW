//
//  BottomNavBar.swift
//  searchly
//
//  Created by cobsccompy4231p-007 on 2024-11-16.
//

import SwiftUI

struct BottomNavBar: View {
    var selectedTab: NavTab
    var onTabSelected: (NavTab) -> Void
    
    enum NavTab {
        case home
        case favorites
        case settings
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack {
                NavItem(iconName: "home-icon", title: "Home", isSelected: selectedTab == .home) {
                    onTabSelected(.home)
                }
                
                Spacer()
                
                NavItem(iconName: "heart-icon", title: "Favorites", isSelected: selectedTab == .favorites) {
                    onTabSelected(.favorites)
                }
                
                Spacer()
                
                NavItem(iconName: "settings-icon", title: "Settings", isSelected: selectedTab == .settings) {
                    onTabSelected(.settings)
                }
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 10)
            .background(Color(hex: "#102A36"))
            .foregroundColor(.white)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 0)
            .padding(.bottom, 30)
        }
    }
}

struct NavItem: View {
    var iconName: String
    var title: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                Text(title)
                    .font(.caption)
            }
            .foregroundColor(isSelected ? Color.yellow : Color.white)
        }
    }
}

struct BottomNavBar_Previews: PreviewProvider {
    static var previews: some View {
        BottomNavBar(selectedTab: .home, onTabSelected: { _ in })
    }
}
