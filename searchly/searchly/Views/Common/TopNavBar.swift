import SwiftUI

struct TopNavBar: View {
    @Binding var searchText: String
    var onProfileTap: () -> Void
    var onNotificationTap: () -> Void
    var showSearch: Bool
    var onSearchBarTap: () -> Void
    
    init(
        searchText: Binding<String>,
        onProfileTap: @escaping () -> Void,
        onNotificationTap: @escaping () -> Void,
        showSearch: Bool = true,
        onSearchBarTap: @escaping () -> Void = {}
    ) {
        self._searchText = searchText
        self.onProfileTap = onProfileTap
        self.onNotificationTap = onNotificationTap
        self.showSearch = showSearch
        self.onSearchBarTap = onSearchBarTap
    }
    
    var body: some View {
        HStack {
            if showSearch {
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
                    onSearchBarTap()
                }
            }
            
            Spacer()
            
            Button(action: onNotificationTap) {
                Image("notification-icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .padding(.trailing, 15)
                    .accessibilityLabel("Notifications")
            }
            
            Button(action: onProfileTap) {
                Image("profile-icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .padding(.trailing, 20)
                    .accessibilityLabel("Profile")
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
