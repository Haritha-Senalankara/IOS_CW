//
//  Nav.swift
//  searchly
//
//  Created by cobsccompy4231p-007 on 2024-11-10.
//

import SwiftUI
import Foundation

struct MainView: View {
    @State private var selectedTab: Tab = .home
    
    enum Tab {
        case home
        case favorites
        case settings
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Content based on selected tab
            switch selectedTab {
            case .home:
                Home()
            case .favorites:
                Wishlist()
            case .settings:
                Settings()
            }
            
            // Bottom Navigation Bar
            Divider()
            HStack {
                BottomNavItem(iconName: "home-icon", title: "Home", isActive: selectedTab == .home)
                    .onTapGesture {
                        selectedTab = .home
                    }
                Spacer()
                BottomNavItem(iconName: "heart-icon", title: "Favorites", isActive: selectedTab == .favorites)
                    .onTapGesture {
                        selectedTab = .favorites
                    }
                Spacer()
                BottomNavItem(iconName: "settings-icon", title: "Settings", isActive: selectedTab == .settings)
                    .onTapGesture {
                        selectedTab = .settings
                    }
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 10)
            .background(Color(hex: "#102A36"))
            .foregroundColor(.white)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 0)
            .padding(.bottom, 30)
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
    }
}

// Preview Provider
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
