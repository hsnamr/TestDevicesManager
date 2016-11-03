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

    lazy var dataSource: DATASource = {
        let request: NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Device")
        request.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true),
        ]
        
        let dataSource = DATASource(tableView: self.tableView, cellIdentifier: "cellForDevice", fetchRequest: request, mainContext: self.dataStack.mainContext)
        dataSource.delegate = self
        
        return dataSource
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellForDevice")
        self.tableView.dataSource = self.dataSource
        
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
        self.dataStack.mainContext.refreshAllObjects()
        
        tableView.dataSource = dataSource
        tableView.reloadData()
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

extension HomePage: DATASourceDelegate {
    
    func dataSource(_ dataSource: DATASource, configureTableViewCell cell: UITableViewCell, withItem item: NSManagedObject, atIndexPath indexPath: IndexPath) {
        cell.textLabel?.text = item.value(forKey: "name") as? String ?? ""
    }
}
