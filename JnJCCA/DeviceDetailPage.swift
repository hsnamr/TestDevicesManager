//
//  DeviceDetailPage.swift
//  JnJCCA
//
//  Created by Hussian Ali Al-Amri on 11/1/16.
//  Copyright © 2016 IM. All rights reserved.
//

import UIKit

class DeviceDetailPage: UIViewController {
    
    // if we got this far, device cannot be nil
    public var device:Device!

    @IBOutlet weak var deviceLabel: UILabel!
    
    @IBOutlet weak var osLabel: UILabel!
    
    @IBOutlet weak var manufacturerLabel: UILabel!
    
    @IBOutlet weak var lastCheckedOutLabel: UILabel!
    
    @IBOutlet weak var checkInOutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        // Do any additional setup after loading the view.
    }
    
    func setupView() {
        // setup the labels and button
        deviceLabel.text = "Device: \(device.name!)"
        osLabel.text = "OS: \(device.os!)"
        manufacturerLabel.text = "Manufacturer: \(device.manufacturer!)"
        if device.isCheckedOut == true {
            // if device is checked out then checkedOutBy and checkedOutDate are not nil
            lastCheckedOutLabel.text = "Last Checked Out: \(device.lastCheckedOutBy!) on \(device.lastCheckedOutDate!)"
            // and button should be Check In
            checkInOutButton.setTitle("Check In", for: .normal)
        } else if device.isCheckedOut == false {
            if let _ = device.lastCheckedOutDate {
                lastCheckedOutLabel.isHidden = false
                lastCheckedOutLabel.text = "Last Checked Out: \(device.lastCheckedOutBy!) on \(device.lastCheckedOutDate!)"
            } else {
                // the device might have never been checked out before
                lastCheckedOutLabel.isHidden = true
            }
            // if the device is available then button should be Check Out
            checkInOutButton.setTitle("Check Out", for: .normal)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func checkInOutDevice(_ sender: Any) {
        device.isCheckedOut = !device.isCheckedOut
        if device.isCheckedOut == true {
            // the device is being checked out
            // display alert popup with textfield for person's name
            alert(title: "Check Out", message: "", action1: "Cancel", action2: "Save")
        } else {
            // the device is being checked in
            assert(self.device.isCheckedOut == false)
            self.setupView()
            // pass the information to Core Data
            PersistenceService.shared.updateDevice(id: device.objectID, isCheckedOut: false, lastCheckedOutBy: nil, lastCheckedOutDate: nil)
        }
    }
    
    func alert(title:String, message:String, action1: String, action2: String) {
        var checkedOutByTextField: UITextField!
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addTextField { (textfield) in
            textfield.placeholder = "Please enter your name"
            checkedOutByTextField = textfield
        }
        alert.addAction(UIAlertAction(title: action1, style: .cancel, handler:{ (_) in
            return
        }))
        alert.addAction(UIAlertAction(title: action2, style: .default, handler:{ (UIAlertAction) in
//            print("Checking out device: \(self.device.name)")
            self.device.lastCheckedOutBy = checkedOutByTextField.text
//            print("Checked out by: \(self.device.lastCheckedOutBy)")
            self.device.lastCheckedOutDate = Date.init(timeIntervalSinceNow: 0) as NSDate?
//            print("Checked out date: \(self.device.lastCheckedOutDate)")
            
            // the device is being checked out, isCheckedOut must be true, else fail
            assert(self.device.isCheckedOut == true)
            self.setupView()
            // pass the information to Core Data
            PersistenceService.shared.updateDevice(id: self.device.objectID, isCheckedOut: self.device.isCheckedOut, lastCheckedOutBy: self.device.lastCheckedOutBy, lastCheckedOutDate: self.device.lastCheckedOutDate as Date?)
            // and then web service

        }))
        self.present(alert, animated: true, completion: nil)
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
