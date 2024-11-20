//
//  MenuViewController.swift
//  FridgeTag
//
//  Created by Karen Khachatryan on 20.11.24.
//

import UIKit

class MenuViewController: UIViewController {

    @IBOutlet weak var searchTextField: PaddingTextField!
    @IBOutlet weak var mainCollectionView: UICollectionView!
    private let addButton = UIButton(type: .custom)
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        addButton.setImage(.addButton, for: .normal)
        addButton.addTarget(self, action: #selector(clickedAdd), for: .touchUpInside)
        setNaviagtionSettingsButton()
        setNaviagtionAddButton(button: addButton)
        searchTextField.setupRightViewIcon(.search, size: CGSize(width: 60, height: 40))
        searchTextField.font = .bold(size: 21)
        searchTextField.attributedPlaceholder = NSAttributedString(string: "Search", attributes: [.font: UIFont.bold(size: 21) ?? .boldSystemFont(ofSize: 21), .foregroundColor: UIColor.border])
    }
    
    @objc func clickedAdd() {
        
    }
}
