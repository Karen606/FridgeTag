//
//  Font.swift
//  FridgeTag
//
//  Created by Karen Khachatryan on 20.11.24.
//

import UIKit

extension UIFont {
    static func extraBold(size: CFloat) -> UIFont? {
        return UIFont(name: "Montserrat-ExtraBold", size: CGFloat(size))
    }
    
    static func semibold(size: CFloat) -> UIFont? {
        return UIFont(name: "Montserrat-SemiBold", size: CGFloat(size))
    }
    
    static func bold(size: CFloat) -> UIFont? {
        return UIFont(name: "Montserrat-Bold", size: CGFloat(size))
    }
}
