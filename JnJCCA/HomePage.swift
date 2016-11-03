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

class HomePage: UITableViewController {
    
    var listOfDevices:[Device]?
    let dataStack = DATAStack(modelName: "JnJCCA")
    var dataSource:DATASource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellForDevice")
        self.tableView.allowsSelectionDuringEditing = false
        refresh()
        
        WebService.shared.getDevices()
        
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
            cell.textLabel?.text = "\(item.value(forKey: "name")!) - \(item.value(forKey: "os")!)"
        })
        
        self.tableView.dataSource = dataSource
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showDeviceDetail", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // To-Do: Add warning dialogue before committing deletion
            if let selectedDevice = self.dataSource.objectAtIndexPath(self.tableView.indexPathForSelectedRow!) as? Device {
                PersistenceService.shared.deleteDevice(id: selectedDevice.objectID)
                alert(title: "Warning", message: "Are you sure you want to delete \(selectedDevice.name)?", action1: "Delete", action2: "No")
            }
//            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func alert(title:String, message:String, action1: String?, action2: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if let _ = action1 {
            alert.addAction(UIAlertAction(title: action1!, style: .cancel, handler: { (_) in
                // Delete the row from the data source
                if let selectedDevice = self.dataSource.objectAtIndexPath(self.tableView.indexPathForSelectedRow!) as? Device {
                    PersistenceService.shared.deleteDevice(id: selectedDevice.objectID)
                }
            }))
        }
        
        alert.addAction(UIAlertAction(title: action2, style: .default, handler: { (_) in
            return
        }))
        
        present(alert, animated: true, completion: nil)
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
