//
//  ProductFormViewController.swift
//  FridgeTag
//
//  Created by Karen Khachatryan on 20.11.24.
//

import UIKit
import Combine
import DropDown
import PhotosUI

class ProductFormViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet var textFields: [PaddingTextField]!
    @IBOutlet var titleLabels: [UILabel]!
    @IBOutlet weak var nameTextField: PaddingTextField!
    @IBOutlet weak var addDateTextField: PaddingTextField!
    @IBOutlet weak var expiryDateTextField: PaddingTextField!
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: BaseButton!
    @IBOutlet weak var categoryDropImageView: UIImageView!
    private let addedDateDropImageView = UIImageView(image: .arrowDown, highlightedImage: .arrowUp)
    private let expiryDateDropImageView = UIImageView(image: .arrowDown, highlightedImage: .arrowUp)
    private let viewModel = ProductFormViewModel.shared
    private let addedDatePicker = UIDatePicker()
    private let expiryDatePicker = UIDatePicker()
    private var cancellables: Set<AnyCancellable> = []
    private let dropDown = DropDown()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDropDown()
        subscribe()
    }
    
    override func viewDidLayoutSubviews() {
        dropDown.width = categoryButton.bounds.width
        dropDown.bottomOffset = CGPoint(x: categoryButton.frame.minX, y: categoryButton.frame.maxY + 2)
    }
    
    func setupUI() {
        self.navigationItem.hidesBackButton = true
        setNavigationBar(title: "Add a product")
        titleLabels.forEach({ $0.font = .extraBold(size: 21) })
        for field in textFields {
            field.layer.borderWidth = 2
            field.layer.borderColor = UIColor.border.cgColor
            field.layer.cornerRadius = 16
            field.font = .extraBold(size: 21)
            field.delegate = self
        }
        addedDateDropImageView.frame = CGRect(x: 0, y: 0, width: 60, height: 40)
        expiryDateDropImageView.frame = CGRect(x: 0, y: 0, width: 60, height: 40)
        addDateTextField.setupDropDownIcon(addedDateDropImageView)
        expiryDateTextField.setupDropDownIcon(expiryDateDropImageView)
        categoryButton.layer.borderWidth = 2
        categoryButton.layer.borderColor = UIColor.border.cgColor
        categoryButton.layer.cornerRadius = 16
        categoryButton.titleLabel?.font = .extraBold(size: 21)
        photoButton.layer.borderWidth = 2
        photoButton.layer.borderColor = UIColor.border.cgColor
        photoButton.layer.cornerRadius = 16
        photoButton.layer.masksToBounds = true
        photoButton.imageView?.contentMode = .scaleAspectFit
        
        cancelButton.titleLabel?.font = .extraBold(size: 21)
        saveButton.titleLabel?.font = .extraBold(size: 21)
        addedDatePicker.locale = NSLocale.current
        addedDatePicker.datePickerMode = .dateAndTime
        addedDatePicker.preferredDatePickerStyle = .inline
        addedDatePicker.addTarget(self, action: #selector(addedDateChanged), for: .valueChanged)
        addDateTextField.inputView = addedDatePicker
        
        expiryDatePicker.locale = NSLocale.current
        expiryDatePicker.datePickerMode = .dateAndTime
        expiryDatePicker.preferredDatePickerStyle = .inline
        expiryDatePicker.addTarget(self, action: #selector(expiryDateChanged), for: .valueChanged)
        expiryDateTextField.inputView = expiryDatePicker
    }
    
    func setupDropDown() {
        let data: [String] = Category.allCases.map { $0.rawValue }
        dropDown.backgroundColor = .background
        dropDown.layer.cornerRadius = 16
        dropDown.dataSource = data
        dropDown.anchorView = contentView
        dropDown.direction = .bottom
        DropDown.appearance().textColor = .baseBlack
        DropDown.appearance().textFont = .extraBold(size: 21) ?? .boldSystemFont(ofSize: 21)
        dropDown.addShadow()
        
        dropDown.selectionAction = { [weak self] (index: Int, item: String) in
            guard let self = self else { return }
            self.viewModel.product.category = item
            self.categoryDropImageView.isHighlighted = false
        }
        
        dropDown.cancelAction = { [weak self] in
            guard let self = self else { return }
            self.categoryDropImageView.isHighlighted = false
        }
    }
    
    func subscribe() {
        viewModel.$product
            .receive(on: DispatchQueue.main)
            .sink { [weak self] product in
                guard let self = self else { return }
                self.saveButton.isEnabled = (product.name.checkValidation() && product.dateAdded != nil && product.dateExpiry != nil && product.category.checkValidation())
                self.nameTextField.text = product.name
                self.addDateTextField.text = product.dateAdded?.toString()
                self.expiryDateTextField.text = product.dateExpiry?.toString()
                self.categoryButton.setTitle(product.category, for: .normal)
                if let data = product.photo {
                    self.photoButton.setImage(UIImage(data: data), for: .normal)
                } else {
                    self.photoButton.setImage(.imagePlaceholder, for: .normal)
                }
            }
            .store(in: &cancellables)
    }
    
    @objc func addedDateChanged() {
        viewModel.product.dateAdded = addedDatePicker.date
    }
    
    @objc func expiryDateChanged() {
        viewModel.product.dateExpiry = expiryDatePicker.date
    }
    
    @IBAction func handleTapgesture(_ sender: UITapGestureRecognizer) {
        handleTap()
    }
    
    @IBAction func chooseCategory(_ sender: UIButton) {
        dropDown.show()
        categoryDropImageView.isHighlighted = !dropDown.isHidden
    }
    
    @IBAction func choosePhoto(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: "Select Image", message: "Choose a source", preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
                self.requestCameraAccess()
            }))
        }
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { _ in
            self.requestPhotoLibraryAccess()
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func clickedCancel(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clickedSave(_ sender: BaseButton) {
        viewModel.save { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.showErrorAlert(message: error.localizedDescription)
            } else {
                if let date = viewModel.product.dateExpiry, let id = viewModel.product.id?.uuidString {
                    let title = "Expiration date"
                    let body = "The expiration date of the product \(viewModel.product.name ?? "") is today"
                    NotificationManager.shared.scheduleNotification(identifier: id, for: date, title: title, body: body)
                }
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    deinit {
        viewModel.clear()
    }
}

extension ProductFormViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == nameTextField {
            viewModel.product.name = textField.text
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return textField == nameTextField
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == addDateTextField {
            addedDateDropImageView.isHighlighted = true
        } else if textField == expiryDateTextField {
            expiryDateDropImageView.isHighlighted = true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == addDateTextField {
            addedDateDropImageView.isHighlighted = false
        } else if textField == expiryDateTextField {
            expiryDateDropImageView.isHighlighted = false
        }
    }
}

enum Category: String, CaseIterable {
    case fruits = "Fruits"
    case vegetables = "Vegetables"
    case milkProducts = "Milk Products"
    case animalProducts = "Animal Products"
    case drinks = "Drinks"
    case other = "Other"
}

extension ProductFormViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private func requestCameraAccess() {
            let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
            switch cameraStatus {
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    if granted {
                        self.openCamera()
                    }
                }
            case .authorized:
                openCamera()
            case .denied, .restricted:
                showSettingsAlert()
            @unknown default:
                break
            }
        }
        
        private func requestPhotoLibraryAccess() {
            let photoStatus = PHPhotoLibrary.authorizationStatus()
            switch photoStatus {
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization { status in
                    if status == .authorized {
                        self.openPhotoLibrary()
                    }
                }
            case .authorized:
                openPhotoLibrary()
            case .denied, .restricted:
                showSettingsAlert()
            case .limited:
                break
            @unknown default:
                break
            }
        }
        
        private func openCamera() {
            DispatchQueue.main.async {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    let imagePicker = UIImagePickerController()
                    imagePicker.delegate = self
                    imagePicker.sourceType = .camera
                    imagePicker.allowsEditing = true
                    self.present(imagePicker, animated: true, completion: nil)
                }
            }
        }
        
        private func openPhotoLibrary() {
            DispatchQueue.main.async {
                if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                    let imagePicker = UIImagePickerController()
                    imagePicker.delegate = self
                    imagePicker.sourceType = .photoLibrary
                    imagePicker.allowsEditing = true
                    self.present(imagePicker, animated: true, completion: nil)
                }
            }
        }
        
        private func showSettingsAlert() {
            let alert = UIAlertController(title: "Access Needed", message: "Please allow access in Settings", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { _ in
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                }
            }))
            present(alert, animated: true, completion: nil)
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                photoButton.setImage(editedImage, for: .normal)
            } else if let originalImage = info[.originalImage] as? UIImage {
                photoButton.setImage(originalImage, for: .normal)
            }
            if let imageData = photoButton.imageView?.image?.jpegData(compressionQuality: 1.0) {
                let data = imageData
                viewModel.product.photo = data
            }
            picker.dismiss(animated: true, completion: nil)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
        }
}
