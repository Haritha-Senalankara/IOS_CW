import SwiftUI

struct TopNavBar: View {
    @Binding var searchText: String
    var onProfileTap: () -> Void
    var onNotificationTap: () -> Void
    var showSearch: Bool
    var onSearchBarTap: () -> Void // New closure

    // Updated initializer to include onSearchBarTap with a default value
    init(
        searchText: Binding<String>,
        onProfileTap: @escaping () -> Void,
        onNotificationTap: @escaping () -> Void,
        showSearch: Bool = true, // Default value set to true
        onSearchBarTap: @escaping () -> Void = {} // Default empty closure
    ) {
        self._searchText = searchText
        self.onProfileTap = onProfileTap
        self.onNotificationTap = onNotificationTap
        self.showSearch = showSearch
        self.onSearchBarTap = onSearchBarTap
    }

    var body: some View {
        HStack {
            if showSearch { // Conditional rendering based on showSearch
                HStack {
                    Image("search")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                        .padding(.leading, 8)

                    TextField("Search", text: $searchText)
                        .padding(10)
                }
                .background(Color(hex: "#F7F7F7"))
                .cornerRadius(8)
                .padding(.leading, 20)
                .frame(height: 40)
                .onTapGesture {
                    onSearchBarTap() // Call the closure when search bar is tapped
                }
            }

            Spacer()

            Button(action: onNotificationTap) {
                Image("notification-icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .padding(.trailing, 15)
                    .accessibilityLabel("Notifications") // Accessibility
            }

            Button(action: onProfileTap) {
                Image("profile-icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .padding(.trailing, 20)
                    .accessibilityLabel("Profile") // Accessibility
            }
        }
        .padding(.top, 50)
        .padding(.bottom, 10)
    }
}

struct TopNavBar_Previews: PreviewProvider {
    @State static var searchText = ""

    static var previews: some View {
        Group {
            // Preview with showSearch = true
            TopNavBar(
                searchText: $searchText,
                onProfileTap: { print("Profile tapped") },
                onNotificationTap: { print("Notification tapped") },
                showSearch: true,
                onSearchBarTap: { print("Search bar tapped") }
            )
            .previewDisplayName("With Search")

            // Preview with showSearch = false
            TopNavBar(
                searchText: $searchText,
                onProfileTap: { print("Profile tapped") },
                onNotificationTap: { print("Notification tapped") },
                showSearch: false
            )
            .previewDisplayName("Without Search")
        }
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
