//
//  ProductCollectionViewCell.swift
//  FridgeTag
//
//  Created by Karen Khachatryan on 21.11.24.
//

import UIKit

class ProductCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var datesLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameLabel.font = .extraBold(size: 21)
        datesLabel.font = .semibold(size: 13)
        photoImageView.contentMode = .scaleAspectFill
    }

    func configure(product: ProductModel) {
        if let data = product.photo {
            photoImageView.image = UIImage(data: data)
        } else {
            photoImageView.image = nil
        }
        nameLabel.text = product.name
        datesLabel.text = "\(product.dateAdded?.toString(format: "d MMM") ?? "")\n\(product.dateExpiry?.toString(format: "d MMM") ?? "")"
    }
}
