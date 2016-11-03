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
    
    // homePage cannot be nil
    public var homePage:HomePage!
    
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
            alert(title: "Warning", message: "Are you sure you want to cancel?", action1: "Yes", action2: "No")
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func save(_ sender: Any) {
        if (deviceTextField.text?.characters.count)! == 0 || (osTextField.text?.characters.count)! == 0 || (manufacturerTextField.text?.characters.count)! == 0 {
            alert(title: "Error", message: "Please fill all the fields", action1: nil, action2: "OK")
        } else {
            dismiss(animated: true, completion: {
                // pass data to Core Data
                PersistenceService.shared.addDevice(name: self.deviceTextField.text!, os: self.osTextField.text!, manufacturer: self.manufacturerTextField.text!)
                // and then from Core Data to the web service
                // TO-DO: perform needed reachability checks and service calls
                // refresh Home Page
                self.homePage.refresh()
            })
        }
    }
    
    func alert(title:String, message:String, action1: String?, action2: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if let _ = action1 {
            alert.addAction(UIAlertAction(title: action1!, style: .cancel, handler: { (_) in
                self.dismiss(animated: true, completion: nil)
            }))
        }

        alert.addAction(UIAlertAction(title: action2, style: .default, handler: { (_) in
            return
        }))
        
        present(alert, animated: true, completion: nil)
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
