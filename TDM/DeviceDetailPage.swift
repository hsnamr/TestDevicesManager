//
//  DeviceDetailPage.swift
//  TDM
//
//  Created by Hussian Ali Al-Amri on 11/1/16.
//  Copyright © 2016 IM. All rights reserved.
//

import UIKit

final class DeviceDetailPage: UIViewController {

    var device: Device!

    @IBOutlet private weak var deviceLabel: UILabel!
    @IBOutlet private weak var osLabel: UILabel!
    @IBOutlet private weak var manufacturerLabel: UILabel!
    @IBOutlet private weak var lastCheckedOutLabel: UILabel!
    @IBOutlet private weak var checkInOutButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    private func setupView() {
        deviceLabel.text = "Device: \(device.name ?? "")"
        osLabel.text = "OS: \(device.os ?? "")"
        manufacturerLabel.text = "Manufacturer: \(device.manufacturer ?? "")"

        if device.isCheckedOut {
            lastCheckedOutLabel.text = "Last Checked Out: \(device.lastCheckedOutBy ?? "") on \(device.lastCheckedOutDate ?? Date())"
            checkInOutButton.setTitle("Check In", for: .normal)
        } else {
            if let date = device.lastCheckedOutDate as Date?, let by = device.lastCheckedOutBy {
                lastCheckedOutLabel.text = "Last Checked Out: \(by) on \(date)"
            } else {
                lastCheckedOutLabel.text = ""
            }
            checkInOutButton.setTitle("Check Out", for: .normal)
        }
    }

    @IBAction private func checkInOutDevice(_ sender: Any) {
        device.isCheckedOut.toggle()
        if device.isCheckedOut {
            showCheckOutAlert()
        } else {
            setupView()
            MainController.shared.checkInDevice(device: device)
        }
    }

    private func showCheckOutAlert() {
        var nameTextField: UITextField?
        let alert = UIAlertController(title: "Check Out", message: "", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Please enter your name"
            nameTextField = textField
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            self?.device.isCheckedOut = false
            self?.setupView()
        })
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.device.lastCheckedOutBy = nameTextField?.text
            self.device.lastCheckedOutDate = Date() as NSDate
            self.setupView()
            MainController.shared.checkOutDevice(device: self.device)
        })
        present(alert, animated: true)
    }
}
