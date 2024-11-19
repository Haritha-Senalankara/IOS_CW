import SwiftUI

struct Splash_View: View {
    @State private var navigateToNextPage = false
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Image("App Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                Spacer()
            }
            .background(Color.white)
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    navigateToNextPage = true
                }
            }
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
