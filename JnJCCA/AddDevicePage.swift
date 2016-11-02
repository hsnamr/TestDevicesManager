//
//  AddDevice.swift
//  JnJCCA
//
//  Created by Hussian Ali Al-Amri on 11/1/16.
//  Copyright © 2016 IM. All rights reserved.
//

import UIKit

class AddDevicePage: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var deviceTextField: UITextField!
    @IBOutlet weak var osTextField: UITextField!
    @IBOutlet weak var manufacturerTextField: UITextField!
    @IBOutlet weak var titleBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // set the delegate for the textfield to implement the return functionality
        self.deviceTextField.delegate = self
        self.osTextField.delegate = self
        self.manufacturerTextField.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        titleBar.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: titleBar.frame.size.height + UIApplication.shared.statusBarFrame.size.height)
        deviceTextField.frame = CGRect(x: deviceTextField.frame.origin.x, y: deviceTextField.frame.origin.y + UIApplication.shared.statusBarFrame.size.height, width: deviceTextField.frame.size.width, height: deviceTextField.frame.size.height)
        osTextField.frame = CGRect(x: osTextField.frame.origin.x, y: osTextField.frame.origin.y + UIApplication.shared.statusBarFrame.size.height, width: osTextField.frame.size.width, height: osTextField.frame.size.height)
        manufacturerTextField.frame = CGRect(x: manufacturerTextField.frame.origin.x, y: manufacturerTextField.frame.origin.y + UIApplication.shared.statusBarFrame.size.height, width: manufacturerTextField.frame.size.width, height: manufacturerTextField.frame.size.height)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == deviceTextField {
            osTextField.becomeFirstResponder()
        } else if textField == osTextField {
            manufacturerTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    

    @IBAction func cancel(_ sender: Any) {
        if (deviceTextField.text?.characters.count)! > 0 || (osTextField.text?.characters.count)! > 0 || (manufacturerTextField.text?.characters.count)! > 0 {
            print("Warning: Are you sure you want to cancel?")
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func save(_ sender: Any) {
        if (deviceTextField.text?.characters.count)! == 0 || (osTextField.text?.characters.count)! == 0 || (manufacturerTextField.text?.characters.count)! == 0 {
            print("Warning: All fields are mandatory")
        } else {
            dismiss(animated: true, completion: {
                // pass data to Core Data and then from Core Data to the web service
            })
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
