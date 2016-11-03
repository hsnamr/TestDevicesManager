//
//  HomePage.swift
//  JnJCCA
//
//  Created by Hussian Ali Al-Amri on 11/1/16.
//  Copyright © 2016 IM. All rights reserved.
//

import UIKit
import DATAStack
import DATASource

class HomePage: UITableViewController, DATASourceDelegate {
    
    var listOfDevices:[Device]?
    let dataStack = DATAStack(modelName: "JnJCCA")
    var dataSource:DATASource!
    var refreshTimer:Timer?
    var refreshInterval = 0.5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UINib(nibName: "DeviceCell", bundle: nil), forCellReuseIdentifier: "cellForDevice")
        self.tableView.setEditing(true, animated: true)
        WebService.shared.getDevices(completion: {
            self.refresh()
        })
        
        // the following is not necessary
        // 1. we are extending uitableviewcontroller
        // 2. already set in the interface builder
//        self.tableView.delegate = self
//        self.tableView.dataSource = self
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh() {
        let request: NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Device")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        dataSource = DATASource(tableView: self.tableView, cellIdentifier: "cellForDevice", fetchRequest: request, mainContext: self.dataStack.mainContext, configuration: { cell, item, indexPath in
            (cell as! DeviceCell).device.text = "\(item.value(forKey: "name")!) - \(item.value(forKey: "os")!)"
//            (cell as! DeviceCell).detail.text = "Available"
            if let isCheckedOut = item.value(forKey: "isCheckedOut") as! Bool? {
                if isCheckedOut == true {
                    (cell as! DeviceCell).detail.text = "Checked out by \(item.value(forKey: "lastCheckedOutBy")!)"
                } else {
                    (cell as! DeviceCell).detail.text = "Available"
                }
            }
        })
        
        self.tableView.dataSource = dataSource
        self.dataSource.delegate = self
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showDeviceDetail", sender: self)
    }
    
    func dataSource(_ dataSource: DATASource, tableView: UITableView, canEditRowAtIndexPath indexPath: IndexPath) -> Bool {
        return true
    }
    
    // not swipe to delete, but couldn't get that to work using the uitableview delegates below
    func dataSource(_ dataSource: DATASource, tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: IndexPath) {
        if editingStyle == .delete {
            if let selectedDevice = self.dataSource.objectAtIndexPath(indexPath) as? Device {

                PersistenceService.shared.deleteDevice(id: selectedDevice.objectID)
                alert(title: "Warning", message: "Are you sure you want to delete \(selectedDevice.name!)?", action1: "Delete", action2: "No", userData: selectedDevice.objectID)
            }
//            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    /* the following should work but isn't, I've done it before. I could be missing a config somewhere */
//    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }
//
//    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
//        return .delete
//    }
//
//    // Override to support editing the table view.
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            if let selectedDevice = self.dataSource.objectAtIndexPath(indexPath) as? Device {
//                
//                PersistenceService.shared.deleteDevice(id: selectedDevice.objectID)
//                alert(title: "Warning", message: "Are you sure you want to delete \(selectedDevice.name!)?", action1: "Delete", action2: "No", userData: selectedDevice.objectID)
//            }
//            //            tableView.deleteRows(at: [indexPath], with: .fade)
//        } else if editingStyle == .insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//        }
//    }
    
    func alert(title:String, message:String, action1: String, action2: String, userData: Any) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: action1, style: .destructive, handler: { (_) in
            // Delete the row from the data source
            PersistenceService.shared.deleteDevice(id: userData as! NSManagedObjectID)
            // refresh
            self.refresh()
        }))
        
        alert.addAction(UIAlertAction(title: action2, style: .default, handler: { (_) in
            return
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Timer methods
    func setRefreshTimer() {
        if (refreshTimer != nil) {
            return
        }
        
        refreshTimer = Timer.scheduledTimer(timeInterval: refreshInterval, target: self, selector: #selector(refresh), userInfo: nil, repeats: true)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showDeviceDetail" {
            let deviceDetailPage = segue.destination as! DeviceDetailPage
            if let selectedDevice = self.dataSource.objectAtIndexPath(tableView.indexPathForSelectedRow!) as? Device {
                deviceDetailPage.device = selectedDevice
            }
        } else if segue.identifier == "showAddDevice" {
            let addDevicePage = segue.destination as! AddDevicePage
            addDevicePage.homePage = self
        }
    }
}
