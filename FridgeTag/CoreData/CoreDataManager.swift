//
//  CoreDataManager.swift
//  FridgeTag
//
//  Created by Karen Khachatryan on 20.11.24.
//

import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "FridgeTag")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func addProduct(productModel: ProductModel, completion: @escaping (Error?) -> Void) {
        let id = productModel.id ?? UUID()
        let backgroundContext = persistentContainer.newBackgroundContext()
        backgroundContext.perform {
            let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            
            do {
                let results = try backgroundContext.fetch(fetchRequest)
                let product: Product
                
                if let existingProduct = results.first {
                    product = existingProduct
                } else {
                    product = Product(context: backgroundContext)
                    product.id = id
                }
                product.name = productModel.name
                product.dateAdded = productModel.dateAdded
                product.dateExpiry = productModel.dateExpiry
                product.category = productModel.category
                product.photo = productModel.photo
                try backgroundContext.save()
                DispatchQueue.main.async {
                    completion(nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }
    }
    
    func fetchProducts(completion: @escaping ([ProductModel], Error?) -> Void) {
        let backgroundContext = persistentContainer.newBackgroundContext()
        backgroundContext.perform {
            let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
            do {
                let results = try backgroundContext.fetch(fetchRequest)
                var productsModel: [ProductModel] = []
                for result in results {
                    let productModel = ProductModel(id: result.id, name: result.name, dateAdded: result.dateAdded, dateExpiry: result.dateExpiry, category: result.category, photo: result.photo)
                    productsModel.append(productModel)
                }
                DispatchQueue.main.async {
                    completion(productsModel, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion([], error)
                }
            }
        }
    }
}

