//
//  CoreDataManager.swift
//  searchly
//
//  Created by cobsccompy4231p-007 on 2024-11-18.
//

import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    let persistentContainer: NSPersistentContainer
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "ProductsModel")
        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
    }
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveProduct(
        id: String,
        name: String,
        price: Double,
        likes: Int,
        dislikes: Int,
        rating: Double,
        imageName: String,
        imageData: Data?, // Add this parameter
        siteName: String,
        categories: [String],
        locationLatitude: Double?,
        locationLongitude: Double?,
        sellerApps: [AppFilter],
        sellerContacts: [ContactMethodFilter]
    ) {
        let product = Product(context: self.context)
        product.id = id
        product.name = name
        product.price = price
        product.likes = Int32(likes)
        product.dislikes = Int32(dislikes)
        product.rating = rating
        product.imageName = imageName
        product.imageData = imageData
        product.siteName = siteName
        product.categories = categories as NSArray
        product.locationLatitude = locationLatitude ?? 0.0
        product.locationLongitude = locationLongitude ?? 0.0
        product.sellerApps = sellerApps as NSArray
        product.sellerContacts = sellerContacts as NSArray
        
        do {
            try self.context.save()
        } catch {
            print("Failed to save product: \(error)")
        }
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save context: \(error)")
            }
        }
    }
}
