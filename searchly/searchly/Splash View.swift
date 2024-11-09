import SwiftUI

struct Splash_View: View {
    @State private var navigateToNextPage = false // State to control navigation
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Image("App Logo") // Make sure the image is added to your Assets.xcassets
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                Spacer()
            }
            .background(Color.white) // Set the background color to match your design
            .edgesIgnoringSafeArea(.all) // Make sure the splash screen fills the entire screen
            .onAppear {
                // Wait for 1 second and navigate to the next page
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    navigateToNextPage = true
                }
            }
            // Navigation link to redirect to the next view
            .background(
                NavigationLink(destination: onboarding(), isActive: $navigateToNextPage) {
                    EmptyView()
                }
                .hidden()
            )
 
        }
        .navigationViewStyle(StackNavigationViewStyle()) // To prevent nested navigation issues
    }
}


#Preview {
    Splash_View()
}
