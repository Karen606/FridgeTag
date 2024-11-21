//
//  ProductForm.swift
//  FridgeTag
//
//  Created by Karen Khachatryan on 20.11.24.
//

import Foundation

struct ProductModel {
    var id: UUID?
    var name: String?
    var dateAdded: Date?
    var dateExpiry: Date?
    var category: String?
    var photo: Data?
}
