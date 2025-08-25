//
//  ICloudViewController.swift
//  AllCapabilitiesDemo
//
//  Created by DREAMWORLD on 10/12/24.
//

import UIKit
import CloudKit

class ICloudViewController: UIViewController {
    
    private let database = CKContainer(identifier: "iCloud.allcaps.container").privateCloudDatabase
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var lblNoData: UILabel!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    var gItems = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Grocery List"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addItems)
        )
        navigationController?.navigationItem.hidesBackButton = true
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(pulltorefresh), for: .valueChanged)
        tblView.refreshControl = refreshControl
        
        tblView.delegate = self
        tblView.dataSource = self
        tblView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
              
        loader.startAnimating()
        fetchRecords()
    }
    
    @objc func pulltorefresh() {
        self.tblView.refreshControl?.beginRefreshing()
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "GroceryItem", predicate: predicate)
        
        database.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if let records = records {
                    DispatchQueue.main.async {
                        self.gItems = records.compactMap({$0.value(forKey: "name") as? String})
                        self.tblView.reloadData()
                        self.lblNoData.isHidden = !(self.gItems.count == 0)
                        self.tblView.refreshControl?.endRefreshing()

                    }
                }
            }
        }
    }
    
    @objc func addItems() {
        let alert = UIAlertController(title: "Add Items", message: nil, preferredStyle: .alert)
        alert.addTextField { field in
            field.placeholder = "Enter name"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak self] _ in
            if let field = alert.textFields?.first, let text = field.text, !text.isEmpty {
                self?.saveRecord(name: text)
            }
        }))
        present(alert, animated: true)
    }
    
    func saveRecord(name: String) {
        loader.startAnimating()
        let record = CKRecord(recordType: "GroceryItem")
        record.setValue(name, forKey: "name")
        
        database.save(record) { (record, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self.loader.stopAnimating()
                    self.showAlert(message: error.localizedDescription)
                    print(error.localizedDescription)
                } else if let record = record, let savedName = record["name"] as? String {
                    // ✅ Update local list immediately
                    self.gItems.append(savedName)
                    self.tblView.reloadData()
                    self.lblNoData.isHidden = !self.gItems.isEmpty
                    self.loader.stopAnimating()
                    
                    print("Record saved successfully")
                }
            }
        }
    }
    
    func fetchRecords() {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "GroceryItem", predicate: predicate)
        
        database.fetch(withQuery: query, inZoneWith: nil, desiredKeys: nil, resultsLimit: 100) { result in
            switch result {
            case .success(let (matchResults, _)):
                var fetchedItems: [String] = []
                
                // Loop through the matchResults array
                for (_, recordResult) in matchResults {
                    switch recordResult {
                    case .success(let record):
                        if let name = record["name"] as? String {
                            fetchedItems.append(name)
                        }
                    case .failure(let error):
                        print("Error fetching record: \(error.localizedDescription)")
                    }
                }

                DispatchQueue.main.async {
                    self.gItems = fetchedItems
                    self.tblView.reloadData()
                    self.lblNoData.isHidden = !fetchedItems.isEmpty
                    self.loader.stopAnimating()
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self.loader.stopAnimating()
                    self.showAlert(message: error.localizedDescription)
                }
                print("Query failed: \(error.localizedDescription)")
            }
        }
    }


    func updateRecordByName(name: String, newName: String, index: Int) {
        self.loader.startAnimating()
        
        let predicate = NSPredicate(format: "name == %@", name)
        let query = CKQuery(recordType: "GroceryItem", predicate: predicate)
        
        database.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                self.loader.stopAnimating()
                print("Error fetching record for update: \(error.localizedDescription)")
            } else if let records = records, let recordToUpdate = records.first {
                // Update the fetched record
                recordToUpdate.setValue(newName, forKey: "name")
                
                self.database.save(recordToUpdate) { savedRecord, error in
                    if let error = error {
                        print("Error saving updated record: \(error.localizedDescription)")
                    } else {
                        print("Record updated successfully")
                        //self.fetchRecords() // Refresh the data after update
                        DispatchQueue.main.async {
                            self.gItems[index] = newName
                            self.tblView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                            self.loader.stopAnimating()
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.loader.stopAnimating()
                }
                print("No record found with the specified name")
            }
        }
    }

    
    func deleteRecord(recordID: CKRecord.ID) {
        database.delete(withRecordID: recordID) { (recordID, error) in
            if let error = error {
                print("Error deleting record: \(error.localizedDescription)")
            } else {
                print("Record deleted successfully")
            }
        }
    }
    
    func deleteRecordByName(name: String) {
        let predicate = NSPredicate(format: "name == %@", name)
        let query = CKQuery(recordType: "GroceryItem", predicate: predicate)
        
        database.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("Error fetching record for deletion: \(error.localizedDescription)")
            } else if let records = records, let recordToDelete = records.first {
                // Delete the fetched record
                self.deleteRecord(recordID: recordToDelete.recordID)
            } else {
                print("No record found with the specified name")
            }
        }
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            alert.dismiss(animated: true)
        }))
        self.present(alert, animated: true)
    }
    
}

extension ICloudViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        gItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = self.gItems[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.deleteRecordByName(name: self.gItems[indexPath.row])
            // Remove item from the data source
            gItems.remove(at: indexPath.row)
            // Delete the row from the table view
            tblView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Delete Action
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, completionHandler in
            self.deleteRecordByName(name: self.gItems[indexPath.row])
            // Remove item from the data source
            self.gItems.remove(at: indexPath.row)
            // Delete the row from the table view
            self.tblView.deleteRows(at: [indexPath], with: .fade)
            completionHandler(true)
        }
        
        // Update Action
        let updateAction = UIContextualAction(style: .normal, title: "Update") { _, _, completionHandler in
            let currentName = self.gItems[indexPath.row]
            let alert = UIAlertController(title: "Update Items", message: nil, preferredStyle: .alert)
            alert.addTextField { field in
                field.placeholder = "Enter name"
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { [weak self] _ in
                if let field = alert.textFields?.first, let text = field.text, !text.isEmpty {
                    self?.updateRecordByName(name: currentName, newName: text, index: indexPath.row)
                }
            }))
            self.present(alert, animated: true)
            completionHandler(true)
        }
        
        updateAction.backgroundColor = .blue
        
        return UISwipeActionsConfiguration(actions: [deleteAction, updateAction])
    }

    
}
