//
//  ProductModel.swift
//  searchly
//
//  Created by cobsccompy4231p-007 on 2024-11-10.
//

import Foundation
import MapKit

// MARK: - Product Model
struct Products: Identifiable {
    var id: String
    var name: String
    var price: Double
    var siteName: String
    var likes: Int
    var dislikes: Int
    var rating: Double
    var categories: [String]
    var imageName: String // Includes fallback for missing images
    var imageData: Data? // Add this property
    var location: CLLocationCoordinate2D?
    var sellerApps: [AppFilter] = [] // Holds seller's apps
    var sellerContacts: [ContactMethodFilter] = [] // Holds seller's contact methods
}
