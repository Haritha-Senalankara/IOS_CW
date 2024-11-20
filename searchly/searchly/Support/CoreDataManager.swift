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
        imageData: Data?,
        siteName: String,
        locationLatitude: Double?,
        locationLongitude: Double?
    ) {
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            let results = try context.fetch(fetchRequest)
            let product: Product
            
            if let existingProduct = results.first {
                product = existingProduct
            } else {
                product = Product(context: self.context)
                product.id = id
            }
            
            // Update only savable properties
            product.name = name
            product.price = price
            product.likes = Int32(likes)
            product.dislikes = Int32(dislikes)
            product.rating = rating
            product.imageName = imageName
            product.imageData = imageData
            product.siteName = siteName
            product.locationLatitude = locationLatitude ?? 0.0
            product.locationLongitude = locationLongitude ?? 0.0
            
            try context.save()
            print("Product saved/updated successfully.")
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
