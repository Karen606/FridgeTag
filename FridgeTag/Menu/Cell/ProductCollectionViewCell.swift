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
    @IBOutlet weak var removeButton: UIButton!
    private var id: UUID?
    
    override var isSelected: Bool {
        didSet {
            removeButton.isHidden = !isSelected
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameLabel.font = .extraBold(size: 21)
        datesLabel.font = .semibold(size: 13)
        photoImageView.contentMode = .scaleAspectFill
    }

    func configure(product: ProductModel) {
        self.id = product.id
        if let data = product.photo {
            photoImageView.image = UIImage(data: data)
        } else {
            photoImageView.image = nil
        }
        nameLabel.text = product.name
        datesLabel.text = "\(product.dateAdded?.toString(format: "d MMM") ?? "")\n\(product.dateExpiry?.toString(format: "d MMM") ?? "")"
    }
    
    override func prepareForReuse() {
        id = nil
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if removeButton.frame.contains(point) {
            return removeButton
        }
        return super.hitTest(point, with: event)
    }
    
    @IBAction func clickedRemove(_ sender: UIButton) {
        guard let id = id else { return }
        MenuViewModel.shared.removeProduct(id: id)
    }
}
