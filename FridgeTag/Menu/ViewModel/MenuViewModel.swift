//
//  MenuViewModel.swift
//  FridgeTag
//
//  Created by Karen Khachatryan on 21.11.24.
//

import Foundation

class MenuViewModel {
    static let shared = MenuViewModel()
    private var data = CategoriesModel()
    @Published var categories = CategoriesModel()
    private var search: String?
    private init() {}
    
    func fetchData() {
        CoreDataManager.shared.fetchProducts { [weak self] products, _ in
            guard let self = self else { return }
            let fruits = products.filter({ $0.category == Category.fruits.rawValue })
            let vegetables = products.filter({ $0.category == Category.vegetables.rawValue })
            let milkProducts = products.filter({ $0.category == Category.milkProducts.rawValue })
            let animalProducts = products.filter({ $0.category == Category.animalProducts.rawValue })
            let drinks = products.filter({ $0.category == Category.drinks.rawValue })
            let other = products.filter({ $0.category == Category.other.rawValue })
            self.data = CategoriesModel(fruits: fruits, vegetables: vegetables, milkProducts: milkProducts, animalProducts: animalProducts, drinks: drinks, other: other)

            filter(by: search)
        }
    }
    
    func filter(by value: String?) {
        search = value
        if let search = search?.lowercased(), !search.isEmpty {
            let categories = CategoriesModel(fruits: data.fruits.filter({ ($0.name?.lowercased())?.contains(search) ?? false }), vegetables: data.vegetables.filter({ ($0.name?.lowercased())?.contains(search) ?? false }), milkProducts: data.milkProducts.filter({ ($0.name?.lowercased())?.contains(search) ?? false }), animalProducts: data.animalProducts.filter({ ($0.name?.lowercased())?.contains(search) ?? false }), drinks: data.drinks.filter({ ($0.name?.lowercased())?.contains(search) ?? false }), other: data.other.filter({ ($0.name?.lowercased())?.contains(search) ?? false }))
            self.categories = categories
        } else {
            self.categories = data
        }
    }
    
    func removeProduct(id: UUID) {
        CoreDataManager.shared.removeProduct(by: id) { [weak self] _ in
            guard let self = self else { return }
            NotificationManager.shared.deleteNotification(with: id.uuidString)
            self.fetchData()
        }
    }
}
