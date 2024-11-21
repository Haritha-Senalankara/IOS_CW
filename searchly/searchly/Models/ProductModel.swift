//
//  ProductModel.swift
//  searchly
//
//  Created by cobsccompy4231p-007 on 2024-11-10.
//

import Foundation
import MapKit

struct Products: Identifiable {
    var id: String
    var name: String
    var price: Double
    var siteName: String
    var likes: Int
    var dislikes: Int
    var rating: Double
    var categories: [String]
    var imageName: String
    var imageData: Data?
    var location: CLLocationCoordinate2D?
    var sellerApps: [AppFilter] = []
    var sellerContacts: [ContactMethodFilter] = []
}
