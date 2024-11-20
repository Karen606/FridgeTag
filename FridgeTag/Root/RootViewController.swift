//
//  ViewController.swift
//  FridgeTag
//
//  Created by Karen Khachatryan on 20.11.24.
//

import UIKit

class RootViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.pushViewController(MenuViewController.self)
    }
}

