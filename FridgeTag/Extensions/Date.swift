//
//  Date.swift
//  FridgeTag
//
//  Created by Karen Khachatryan on 20.11.24.
//

import Foundation

extension Date {
    func toString(format: String = "dd/MM/yyyy") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}
