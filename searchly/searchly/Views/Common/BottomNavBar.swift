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
            .background(Color(hex: "#102A36")) // Ensure Color(hex:) is defined
            .foregroundColor(.white)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 0)
            .padding(.bottom, 30) // Space for home indicator or safe area
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
            .foregroundColor(isSelected ? Color.yellow : Color.white) // Change color as needed
        }
    }
}

struct BottomNavBar_Previews: PreviewProvider {
    static var previews: some View {
        BottomNavBar(selectedTab: .home, onTabSelected: { _ in })
    }
}

//// Extension to handle hexadecimal color values
//extension Color {
//    init(hex: String) {
//        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
//        var int: UInt64 = 0
//        Scanner(string: hex).scanHexInt64(&int)
//        let a, r, g, b: UInt64
//        switch hex.count {
//        case 3: // RGB (12-bit)
//            (a, r, g, b) = (255,
//                            (int >> 8) * 17,
//                            (int >> 4 & 0xF) * 17,
//                            (int & 0xF) * 17)
//        case 6: // RGB (24-bit)
//            (a, r, g, b) = (255,
//                            int >> 16,
//                            int >> 8 & 0xFF,
//                            int & 0xFF)
//        case 8: // ARGB (32-bit)
//            (a, r, g, b) = (int >> 24,
//                            int >> 16 & 0xFF,
//                            int >> 8 & 0xFF,
//                            int & 0xFF)
//        default:
//            (a, r, g, b) = (255, 0, 0, 0)
//        }
//
//        self.init(
//            .sRGB,
//            red: Double(r) / 255,
//            green: Double(g) / 255,
//            blue:  Double(b) / 255,
//            opacity: Double(a) / 255
//        )
//    }
//}
