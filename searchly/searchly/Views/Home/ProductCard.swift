//
//  ProductCard.swift
//  searchly
//
//  Created by cobsccompy4231p-007 on 2024-11-10.
//

import SwiftUI
import Foundation

// MARK: - ProductCard
struct ProductCard: View {
    var imageName: String
    var name: String
    var siteName: String
    var price: String
    var likes: String
    var rating: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: imageName)) { image in
                image
                    .resizable()
                    .scaledToFill() // Ensures the image covers the entire frame while maintaining aspect ratio
                    .frame(width: 120, height: 120) // Adjust the size as per your design
                    .clipped() // Clips the overflowing parts to fit the frame
                    .cornerRadius(8)
            } placeholder: {
                Color.gray // Placeholder while the image is loading
                    .frame(width: 120, height: 120) // Match the size of the image frame
                    .cornerRadius(8)
            }
            
            Text(name)
                .font(.custom("Heebo-Bold", size: 14))
                .foregroundColor(.black)
                .lineLimit(2)
            
            Text(siteName)
                .font(.custom("Heebo-Regular", size: 12))
                .foregroundColor(.gray)
            
            Text(price)
                .font(.custom("Heebo-Bold", size: 14))
                .foregroundColor(Color(hex: "#F2A213"))
            
            HStack {
                HStack(spacing: 5) {
                    Image("like-icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12.9, height: 15)
                    Text(likes)
                        .font(.custom("Heebo-Regular", size: 12))
                        .foregroundColor(.black)
                }
                .frame(width: 60, height: 30)
                .background(Color.white)
                .cornerRadius(8)
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                
                HStack(spacing: 5) {
                    Image("rating-icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12.9, height: 15)
                    Text(rating)
                        .font(.custom("Heebo-Regular", size: 12))
                        .foregroundColor(.black)
                }
                .frame(width: 60, height: 30)
                .background(Color.white)
                .cornerRadius(8)
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

