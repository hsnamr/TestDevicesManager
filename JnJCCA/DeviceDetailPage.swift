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
    public var name:String!
    public var os:String!
    public var manufacturer:String!
    public var isCheckedOut:Bool!
    public var lastCheckedOutBy:String?
    public var lastCheckedOutDate:Date?

    @IBOutlet weak var deviceLabel: UILabel!
    
    @IBOutlet weak var osLabel: UILabel!
    
    @IBOutlet weak var manufacturerLabel: UILabel!
    
    @IBOutlet weak var lastCheckedOutLabel: UILabel!
    
    @IBOutlet weak var checkInOutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // setup the labels
        deviceLabel.text = "Device: \(name)"
        osLabel.text = "OS: \(os)"
        manufacturerLabel.text = "Manufacturer: \(manufacturer)"
        if isCheckedOut == true {
            // if device is checked out then checkedOutBy and checkedOutDate are not nil
            lastCheckedOutLabel.text = "Last Checked Out: \(lastCheckedOutBy) on \(lastCheckedOutDate)"
            // and button should be Check In
            checkInOutButton.titleLabel?.text = "Check In"
        } else {
            // if the device is available then hide the label
            lastCheckedOutLabel.isHidden = true
            // and button should be Check Out
            checkInOutButton.titleLabel?.text = "Check Out"
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func checkInOutDevice(_ sender: Any) {
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
