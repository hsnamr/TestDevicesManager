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
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showDeviceDetail", sender: self)
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 1
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // return the count of listOfDevices or 0 if array is nil
//        return listOfDevices?.count ?? 0
//    }
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cellForDevice", for: indexPath)
//
//        // Configure the cell...
//
//        return cell
//    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // To-Do: Add warning dialogue before committing deletion
            print("Warning: Are you sure you want to delete this device?")
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        }
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
