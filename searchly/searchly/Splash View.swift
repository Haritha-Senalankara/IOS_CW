//
//  Splash View.swift
//  searchly
//
//  Created by cobsccompy4231p-007 on 2024-10-27.
//

import SwiftUI

struct Splash_View: View {
    var body: some View {
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
        }
}

#Preview {
    Splash_View()
}
