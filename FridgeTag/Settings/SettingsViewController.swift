//
//  SettingsViewController.swift
//  FridgeTag
//
//  Created by Karen Khachatryan on 21.11.24.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet var settingsLabels: [UILabel]!
    @IBOutlet weak var contactInformationLabel: UILabel!
    @IBOutlet var settingsButtons: [UIButton]!
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var interfaceModeSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        interfaceModeSwitch.isOn = UserDefaults.standard.bool(forKey: "isDarkModeEnabled")
        notificationSwitch.isOn = UserDefaults.standard.bool(forKey: "isTaskNotificationsEnabled")
    }
    
    func setupUI() {
        self.setNavigationBar(title: "Settings")
        settingsLabels.forEach({ $0.font = .semibold(size: 21) })
        contactInformationLabel.font = .extraBold(size: 21)
        settingsButtons.forEach({ $0.titleLabel?.font = .extraBold(size: 21) })
        notificationSwitch.layer.cornerRadius = interfaceModeSwitch.frame.height / 2
        interfaceModeSwitch.layer.cornerRadius = interfaceModeSwitch.frame.height / 2
    }
    
    @IBAction func chooseInterfaceMode(_ sender: UISwitch) {
        sender.isOn = sender.isOn
        let interfaceMode = sender.isOn ? UIUserInterfaceStyle.dark : .light
        UserDefaults.standard.set(sender.isOn, forKey: "isDarkModeEnabled")
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            for window in windowScene.windows {
                window.overrideUserInterfaceStyle = interfaceMode
            }
        }
    }
    
    @IBAction func chooseNotifications(_ sender: UISwitch) {
        if sender.isOn {
            NotificationManager.shared.requestNotificationPermission(completion: { granted in
                sender.isOn = granted
                sender.setOn(granted, animated: true)
                UserDefaults.standard.set(sender.isOn, forKey: "isNotificationsEnabled")
            })
        } else {
            print("Notifications disabled")
            sender.isOn = false
            UserDefaults.standard.set(sender.isOn, forKey: "isNotificationsEnabled")
        }
    }
    
    @IBAction func clickedContactUs(_ sender: UIButton) {
    }
    @IBAction func clickedPrivacyPolicy(_ sender: UIButton) {
    }
    @IBAction func clickedRateUs(_ sender: UIButton) {
    }
}
