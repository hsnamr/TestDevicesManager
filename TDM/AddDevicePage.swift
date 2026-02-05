//
//  AddDevicePage.swift
//  TDM
//
//  Created by Hussian Ali Al-Amri on 11/1/16.
//  Copyright © 2016 IM. All rights reserved.
//

import UIKit
import CoreData

final class AddDevicePage: UIViewController, UITextFieldDelegate {

    @IBOutlet private weak var deviceTextField: UITextField!
    @IBOutlet private weak var osTextField: UITextField!
    @IBOutlet private weak var manufacturerTextField: UITextField!
    @IBOutlet private weak var titleBar: UINavigationBar!

    weak var homePage: HomePage?

    override func viewDidLoad() {
        super.viewDidLoad()
        deviceTextField.delegate = self
        osTextField.delegate = self
        manufacturerTextField.delegate = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let topInset = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        titleBar.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: titleBar.frame.height + topInset)
        [deviceTextField, osTextField, manufacturerTextField].forEach { textField in
            guard let textField = textField else { return }
            textField.frame = CGRect(
                x: textField.frame.origin.x,
                y: textField.frame.origin.y + topInset,
                width: textField.frame.width,
                height: textField.frame.height
            )
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case deviceTextField: osTextField?.becomeFirstResponder()
        case osTextField: manufacturerTextField?.becomeFirstResponder()
        default: textField.resignFirstResponder()
        }
        return true
    }

    @IBAction private func cancel(_ sender: Any) {
        let hasContent = [deviceTextField, osTextField, manufacturerTextField]
            .contains { !($0?.text ?? "").isEmpty }
        if hasContent {
            showAlert(title: "Warning", message: "Are you sure you want to cancel?", action1: "Yes", action2: "No", dismissOnFirst: true)
        } else {
            dismiss(animated: true)
        }
    }

    @IBAction private func save(_ sender: Any) {
        let name = deviceTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let os = osTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let manufacturer = manufacturerTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if name.isEmpty || os.isEmpty || manufacturer.isEmpty {
            showAlert(title: "Error", message: "Please fill all the fields", action1: nil, action2: "OK", dismissOnFirst: false)
        } else {
            dismiss(animated: true) { [weak self] in
                MainController.shared.addDevice(name: name, os: os, manufacturer: manufacturer)
                self?.homePage?.refresh()
            }
        }
    }

    private func showAlert(title: String, message: String, action1: String?, action2: String, dismissOnFirst: Bool) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if let action1 = action1 {
            alert.addAction(UIAlertAction(title: action1, style: .cancel) { [weak self] _ in
                if dismissOnFirst { self?.dismiss(animated: true) }
            })
        }
        alert.addAction(UIAlertAction(title: action2, style: .default))
        present(alert, animated: true)
    }
}
