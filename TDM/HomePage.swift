//
//  HomePage.swift
//  TDM
//
//  Created by Hussian Ali Al-Amri on 11/1/16.
//  Copyright © 2016 IM. All rights reserved.
//

import UIKit
import DATAStack
import DATASource

final class HomePage: UITableViewController, DATASourceDelegate {

    var dataStack = DATAStack(modelName: "JnJCCA")
    var dataSource: DATASource!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "DeviceCell", bundle: nil), forCellReuseIdentifier: "cellForDevice")
        tableView.isEditing = true
        setupDataSource()
        MainController.shared.getDevices { [weak self] in
            self?.refresh()
        }
    }

    func setupDataSource() {
        let excludedIds = MainController.shared.readUpdatedAndDeleted()
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Device")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        if let array = excludedIds, !array.isEmpty {
            request.predicate = NSPredicate(format: "NOT (id IN %@ AND isSynced == true)", array)
        }

        dataSource = DATASource(
            tableView: tableView,
            cellIdentifier: "cellForDevice",
            fetchRequest: request,
            mainContext: dataStack.mainContext
        ) { [weak self] cell, item, indexPath in
            self?.setupCell(cell: cell, item: item)
        }
        tableView.dataSource = dataSource
        dataSource.delegate = self
    }

    func setupCell(cell: UITableViewCell, item: NSManagedObject) {
        guard let deviceCell = cell as? DeviceCell else { return }
        deviceCell.device.text = "\(item.value(forKey: "name") ?? "") - \(item.value(forKey: "os") ?? "")"
        let isCheckedOut = item.value(forKey: "isCheckedOut") as? Bool ?? false
        if isCheckedOut, let lastCheckedOutBy = item.value(forKey: "lastCheckedOutBy") as? String {
            deviceCell.detail.text = "Checked out by \(lastCheckedOutBy)"
        } else {
            deviceCell.detail.text = "Available"
        }
    }

    func refresh() {
        MainController.shared.syncOfflineChanges()
        setupDataSource()
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showDeviceDetail", sender: self)
    }

    func dataSource(_ dataSource: DATASource, tableView: UITableView, canEditRowAtIndexPath indexPath: IndexPath) -> Bool {
        true
    }

    func dataSource(
        _ dataSource: DATASource,
        tableView: UITableView,
        commitEditingStyle editingStyle: UITableViewCell.EditingStyle,
        forRowAtIndexPath indexPath: IndexPath
    ) {
        if editingStyle == .delete {
            showDeleteAlert(indexPath: indexPath)
        }
    }

    private func showDeleteAlert(indexPath: IndexPath) {
        let alert = UIAlertController(title: "Warning", message: "Delete this device?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            let selectedDevice = self.dataSource.objectAtIndexPath(indexPath) as? Device
            MainController.shared.deleteDevice(device: selectedDevice)
            self.refresh()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDeviceDetail",
           let destination = segue.destination as? DeviceDetailPage,
           let indexPath = tableView.indexPathForSelectedRow,
           let device = dataSource.objectAtIndexPath(indexPath) as? Device {
            destination.device = device
        } else if segue.identifier == "showAddDevice", let destination = segue.destination as? AddDevicePage {
            destination.homePage = self
        }
    }
}
