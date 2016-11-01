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
    public var device:Any!  // Any for now

    @IBOutlet weak var deviceLabel: UILabel!
    
    @IBOutlet weak var osLabel: UILabel!
    
    @IBOutlet weak var manufacturerLabel: UILabel!
    
    @IBOutlet weak var lastCheckedOutLabel: UILabel!
    
    @IBOutlet weak var checkInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // setup the labels
        deviceLabel.text = "Device: \(device.name)"
        osLabel.text = "OS: \(device.operatingSystem)"
        manufacturerLabel.text = "Manufacturer: \(device.manufacturer)"
        if device.checkedOut == true {
            // if device is checked out then checkedOutBy and checkedOutDate are not nil
            lastCheckedOutLabel.text = "Last Checked Out: \(device.checkedOutBy) on \(device.checkedOutDate)"
            // and Check In button should be hidden
            checkInButton.isHidden = true
        } else {
            // if the device is available then hide the label
            lastCheckedOutLabel.isHidden = true
            // and unhide the button
            checkInButton.isHidden = false
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func checkInDevice(_ sender: Any) {
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
