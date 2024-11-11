//
//  ReviewModel.swift
//  searchly
//
//  Created by cobsccompy4231p-007 on 2024-11-11.
//

import Foundation

// Review Model
struct Review: Identifiable {
    var id: String
    var userID: String
    var rating: Int
    var comment: String
}
