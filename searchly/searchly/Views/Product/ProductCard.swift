//
//  ProductCard.swift
//  searchly
//
//  Created by cobsccompy4231p-007 on 2024-11-10.
//

import SwiftUI
import Foundation

struct ProductCard: View {
    var imageName: String
    var name: String
    var siteName: String
    var price: String
    var likes: String
    var rating: String
    var imageData: Data?
    
    // Number formatter for price
    private var formattedPrice: String {
        if let priceDouble = Double(price) {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 2
            if let formatted = formatter.string(from: NSNumber(value: priceDouble)) {
                return "Rs." + formatted
            } else {
                
                print("NumberFormatter failed to format the price: \(priceDouble)")
                return price
            }
        } else {
            print("Failed to convert price string '\(price)' to Double.")
            return price
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let imageData = imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 138, height: 166)
                    .clipped()
                    .cornerRadius(8)
            } else {
                AsyncImage(url: URL(string: imageName)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 138, height: 166)
                        .clipped()
                        .cornerRadius(8)
                } placeholder: {
                    Color.gray
                        .frame(width: 138, height: 166)
                        .cornerRadius(8)
                }
            }
            
            Divider()
            
            Text(name)
                .font(.custom("Heebo-Bold", size: 14))
                .foregroundColor(.black)
                .lineLimit(3)
                .truncationMode(.tail)
                .frame(maxWidth: 169, alignment: .leading)

            
            Divider()
            
            Text(siteName)
                .font(.custom("Heebo-Regular", size: 12))
                .foregroundColor(.gray)
            
            Text(formattedPrice)
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
        .frame(width: 169)
    }
}
