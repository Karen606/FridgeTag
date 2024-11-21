//
//  HeaderCollectionReusableView.swift
//  FridgeTag
//
//  Created by Karen Khachatryan on 21.11.24.
//

import UIKit

class HeaderCollectionReusableView: UICollectionReusableView {
    @IBOutlet weak var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        nameLabel.font = .extraBold(size: 21)
    }
}
