//
//  MenuViewController.swift
//  FridgeTag
//
//  Created by Karen Khachatryan on 20.11.24.
//

import UIKit
import Combine

class MenuViewController: UIViewController {

    @IBOutlet weak var searchTextField: PaddingTextField!
    @IBOutlet weak var mainCollectionView: UICollectionView!
    private let viewModel = MenuViewModel.shared
    private var cancellables: Set<AnyCancellable> = []

    private let addButton = UIButton(type: .custom)
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        subscribe()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel.fetchData()
    }
    
    func setupUI() {
        addButton.setImage(.addButton, for: .normal)
        addButton.addTarget(self, action: #selector(clickedAdd), for: .touchUpInside)
        setNaviagtionSettingsButton()
        setNaviagtionAddButton(button: addButton)
        searchTextField.setupRightViewIcon(.search, size: CGSize(width: 60, height: 40))
        searchTextField.font = .bold(size: 21)
        searchTextField.attributedPlaceholder = NSAttributedString(string: "Search", attributes: [.font: UIFont.bold(size: 21) ?? .boldSystemFont(ofSize: 21), .foregroundColor: UIColor.border])
        searchTextField.delegate = self
        mainCollectionView.register(UINib(nibName: "ProductCollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "ProductCollectionViewCell")
        let nib = UINib(nibName: "HeaderCollectionReusableView", bundle: nil)
        mainCollectionView.register(nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "HeaderView")
        if let layout = createLayout() {
            mainCollectionView.collectionViewLayout = layout
        }
        mainCollectionView.delegate = self
        mainCollectionView.dataSource = self
        
    }
    
    func createSectionLayout(isEmpty: Bool) -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .absolute(125), heightDimension: .absolute(150)))
        let group = isEmpty
            ? NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .estimated(0), heightDimension: .absolute(0)), subitems: [item])
            : NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .estimated(view.frame.width), heightDimension: .absolute(150)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 30, bottom: 24, trailing: 0)
        if !isEmpty {
            section.boundarySupplementaryItems = [.init(layoutSize: .init(widthDimension: .absolute(view.frame.width), heightDimension: .absolute(60)), elementKind: UICollectionView.elementKindSectionFooter, alignment: .top)]
        }
        return section
    }

    
    func createLayout() -> UICollectionViewCompositionalLayout? {
        return UICollectionViewCompositionalLayout { [weak self] sectionNum, environment in
            guard let self = self else { return nil }
            let determinedSection = Category.allCases[sectionNum]
            switch determinedSection {
            case .fruits:
                return createSectionLayout(isEmpty: viewModel.categories.fruits.isEmpty)
            case .vegetables:
                return createSectionLayout(isEmpty: viewModel.categories.vegetables.isEmpty)
            case .milkProducts:
                return createSectionLayout(isEmpty: viewModel.categories.milkProducts.isEmpty)
            case .animalProducts:
                return createSectionLayout(isEmpty: viewModel.categories.animalProducts.isEmpty)
            case .drinks:
                return createSectionLayout(isEmpty: viewModel.categories.drinks.isEmpty)
            case .other:
                return createSectionLayout(isEmpty: viewModel.categories.other.isEmpty)
            }
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderView", for: indexPath) as! HeaderCollectionReusableView
            footerView.nameLabel.text = Category.allCases[indexPath.section].rawValue
                return footerView
            }
        fatalError()
    }
    
    func subscribe() {
        viewModel.$categories
            .receive(on: DispatchQueue.main)
            .sink { [weak self] categories in
                guard let self = self else { return }
                self.mainCollectionView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    @objc func clickedAdd() {
        self.pushViewController(ProductFormViewController.self)
    }
    
    @IBAction func handleTapGesture(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
}

extension MenuViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Category.allCases.count
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch Category.allCases[section] {
        case .fruits:
            return viewModel.categories.fruits.count
        case .vegetables:
            return viewModel.categories.vegetables.count
        case .milkProducts:
            return viewModel.categories.milkProducts.count
        case .animalProducts:
            return viewModel.categories.animalProducts.count
        case .drinks:
            return viewModel.categories.drinks.count
        case .other:
            return viewModel.categories.other.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCollectionViewCell", for: indexPath) as! ProductCollectionViewCell
        switch Category.allCases[indexPath.section] {
        case .fruits:
            cell.configure(product: viewModel.categories.fruits[indexPath.item])
        case .vegetables:
            cell.configure(product: viewModel.categories.vegetables[indexPath.item])
        case .milkProducts:
            cell.configure(product: viewModel.categories.milkProducts[indexPath.item])
        case .animalProducts:
            cell.configure(product: viewModel.categories.animalProducts[indexPath.item])
        case .drinks:
            cell.configure(product: viewModel.categories.drinks[indexPath.item])
        case .other:
            cell.configure(product: viewModel.categories.other[indexPath.item])
        }
        return cell
    }
}

extension MenuViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        debounceFilter(by: textField.text)
    }
    
    private func debounceFilter(by searchText: String?) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(performFilter), object: searchText)
        perform(#selector(performFilter), with: searchText, afterDelay: 0.3)
    }
    
    @objc private func performFilter(_ searchText: String?) {
        viewModel.filter(by: searchText)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
    }
}
