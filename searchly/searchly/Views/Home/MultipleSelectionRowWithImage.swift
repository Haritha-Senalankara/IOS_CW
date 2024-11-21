//
//  MultipleSelectionRowWithImage.swift
//  searchly
//
//  Created by cobsccompy4231p-007 on 2024-11-10.
//

import SwiftUI
import Foundation


struct MultipleSelectionRowWithImage: View {
    var title: String
    var imageURL: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: { self.action() }) {
            HStack {
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .cornerRadius(12)
                } placeholder: {
                    Color.gray
                        .frame(width: 24, height: 24)
                        .cornerRadius(12)
                }
                Text(self.title)
                    .foregroundColor(.black)
                Spacer()
                if self.isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(Color(hex: "#F2A213"))
                }
            }
        }
    }
}
