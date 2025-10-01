//
//  ICloudDocumentsViewController.swift
//  AllCapabilitiesDemo
//
//  Created by DREAMWORLD on 12/12/24.
//
import UIKit
import os.log

// Custom UIDocument subclass for handling note files
class NoteDocument: UIDocument {
    var text: String = ""
    
    override func contents(forType typeName: String) throws -> Any {
        return text.data(using: .utf8) ?? Data()
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        if let data = contents as? Data {
            text = String(data: data, encoding: .utf8) ?? ""
        }
    }
}

// Editor View Controller for editing notes (presented as bottom sheet)
class NoteEditorViewController: UIViewController, UITextViewDelegate {
    var document: NoteDocument?
    let textView = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        textView.frame = view.bounds
        textView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        textView.delegate = self
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.backgroundColor = .systemBackground
        view.addSubview(textView)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneEditing))
        
        if let doc = document {
            doc.open { success in
                if success {
                    self.textView.text = doc.text
                    os_log("Opened document: %@", log: OSLog.default, type: .info, doc.fileURL.absoluteString)
                } else {
                    os_log("Failed to open document: %@", log: OSLog.default, type: .error, doc.fileURL.absoluteString)
                }
            }
        }
    }
    
    @objc func doneEditing() {
        guard let doc = document else {
            os_log("No document to save", log: OSLog.default, type: .error)
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Error", message: "No document available to save.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
            return
        }
        
        // Only save if the text has changed
        if doc.text == textView.text {
            os_log("No changes to save for document: %@", log: OSLog.default, type: .info, doc.fileURL.absoluteString)
            closeDocumentAndDismiss(doc)
            return
        }
        
        // Update document content
        doc.text = textView.text
        doc.updateChangeCount(.done) // Mark document as changed
        
        // Perform file operations on a background queue
        DispatchQueue.global(qos: .userInitiated).async {
            let coordinator = NSFileCoordinator()
            var error: NSError?
            
            coordinator.coordinate(writingItemAt: doc.fileURL, options: .forReplacing, error: &error) { url in
                os_log("Starting save for document: %@", log: OSLog.default, type: .info, doc.fileURL.absoluteString)
                doc.save(to: url, for: .forOverwriting) { saveSuccess in
                    if saveSuccess {
                        os_log("Note saved to: %@", log: OSLog.default, type: .info, doc.fileURL.absoluteString)
                        doc.close { closeSuccess in
                            if closeSuccess {
                                os_log("Document closed successfully: %@", log: OSLog.default, type: .info, doc.fileURL.absoluteString)
                                DispatchQueue.main.async {
                                    self.textView.resignFirstResponder()
                                    let alert = UIAlertController(title: "Success", message: "Note updated successfully.", preferredStyle: .alert)
                                    self.present(alert, animated: true)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                        alert.dismiss(animated: true) {
                                            // Notify ICloudDocumentsViewController to refresh
                                            NotificationCenter.default.post(name: .NSMetadataQueryDidUpdate, object: nil)
                                            self.dismiss(animated: true)
                                        }
                                    }
                                }
                            } else {
                                os_log("Failed to close document: %@", log: OSLog.default, type: .error, doc.fileURL.absoluteString)
                                DispatchQueue.main.async {
                                    let alert = UIAlertController(title: "Error", message: "Failed to close note.", preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                                    self.present(alert, animated: true)
                                }
                            }
                        }
                    } else {
                        os_log("Failed to save document: %@", log: OSLog.default, type: .error, doc.fileURL.absoluteString)
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "Error", message: "Failed to update note.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default))
                            self.present(alert, animated: true)
                        }
                    }
                }
            }
            
            if let error = error {
                os_log("File coordination error: %@", log: OSLog.default, type: .error, error.localizedDescription)
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error", message: "Failed to coordinate file access: \(error.localizedDescription)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    private func closeDocumentAndDismiss(_ document: NoteDocument) {
        DispatchQueue.global(qos: .userInitiated).async {
            document.close { closeSuccess in
                if closeSuccess {
                    os_log("Document closed without saving: %@", log: OSLog.default, type: .info, document.fileURL.absoluteString)
                } else {
                    os_log("Failed to close document: %@", log: OSLog.default, type: .error, document.fileURL.absoluteString)
                }
                DispatchQueue.main.async {
                    self.textView.resignFirstResponder()
                    self.dismiss(animated: true)
                }
            }
        }
    }
       
    
    func textViewDidChange(_ textView: UITextView) {
        // Auto-save can be implemented here if needed
    }
}

// Main View Controller for listing, creating, editing, deleting iCloud documents
class ICloudDocumentsViewController: UITableViewController {
    let containerIdentifier = "iCloud.allcaps.container"
    var query: NSMetadataQuery?
    var documents: [URL] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "iCloud Notes"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createNote))
        //navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Syncing...", style: .plain, target: nil, action: nil)
        
        // Add Back button to the navigation bar
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backTapped))
        
        // Make UI attractive
        navigationController?.navigationBar.tintColor = .systemBlue
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.backgroundColor = .systemGroupedBackground
        tableView.separatorStyle = .singleLine
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        // Add pull-to-refresh
//        let refreshControl = UIRefreshControl()
//        refreshControl.addTarget(self, action: #selector(refreshNotes), for: .valueChanged)
//        tableView.refreshControl = refreshControl
        
        setupMetadataQuery()
        checkiCloudAvailability()
    }
    
    @objc func backTapped() {
        // Handle back action: pop or dismiss based on presentation
        if navigationController?.viewControllers.count ?? 0 > 1 {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        query?.stop()
        query?.start()
        os_log("Restarted metadata query", log: OSLog.default, type: .info)
    }
    
    func checkiCloudAvailability() {
        os_log("Checking iCloud availability", log: OSLog.default, type: .debug)
        if let containerURL = FileManager.default.url(forUbiquityContainerIdentifier: containerIdentifier) {
            os_log("iCloud container URL: %@", log: OSLog.default, type: .info, containerURL.absoluteString)
            // Ensure Documents directory exists
            let documentsURL = containerURL.appendingPathComponent("Documents")
            do {
                try FileManager.default.createDirectory(at: documentsURL, withIntermediateDirectories: true)
                os_log("Documents directory ready: %@", log: OSLog.default, type: .info, documentsURL.absoluteString)
            } catch {
                os_log("Failed to create Documents directory: %@", log: OSLog.default, type: .error, error.localizedDescription)
            }
        } else {
            os_log("iCloud container unavailable", log: OSLog.default, type: .error)
            let alert = UIAlertController(title: "iCloud Error", message: "Please ensure iCloud is enabled and the container is set up in entitlements.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    func setupMetadataQuery() {
        query = NSMetadataQuery()
        query?.predicate = NSPredicate(format: "%K LIKE '*.txt'", NSMetadataItemFSNameKey)
        query?.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateQueryResults), name: .NSMetadataQueryDidFinishGathering, object: query)
        NotificationCenter.default.addObserver(self, selector: #selector(updateQueryResults), name: .NSMetadataQueryDidUpdate, object: query)
        
        query?.start()
        os_log("Metadata query started", log: OSLog.default, type: .info)
    }
    
    @objc func updateQueryResults() {
        DispatchQueue.main.async {
            self.documents = []
            if let results = self.query?.results as? [NSMetadataItem] {
                os_log("Query found %d items", log: OSLog.default, type: .info, results.count)
                for item in results {
                    if let url = item.value(forAttribute: NSMetadataItemURLKey) as? URL {
                        self.documents.append(url)
                        os_log("Found document: %@", log: OSLog.default, type: .info, url.absoluteString)
                    }
                }
                self.navigationItem.leftBarButtonItem?.title = "Synced"
            } else {
                self.navigationItem.leftBarButtonItem?.title = "No Data"
                os_log("No query results", log: OSLog.default, type: .error)
            }
            self.tableView.reloadData()
            if self.tableView.refreshControl?.isRefreshing == true {
                self.tableView.refreshControl?.endRefreshing()
            }
        }
    }
    
    @objc func refreshNotes() {
        os_log("Refreshing notes", log: OSLog.default, type: .info)
        query?.disableUpdates()
        query?.enableUpdates()
        query?.start()
    }
    
    @objc func createNote() {
        let alert = UIAlertController(title: "New Note", message: "Enter title and description", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Title"
            textField.autocapitalizationType = .words
        }
        alert.addTextField { textField in
            textField.placeholder = "Description"
            textField.autocapitalizationType = .sentences
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            guard let titleField = alert.textFields?.first, let descField = alert.textFields?.last,
                  let title = titleField.text, !title.isEmpty else {
                let errorAlert = UIAlertController(title: "Error", message: "Title cannot be empty.", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(errorAlert, animated: true)
                return
            }
            let description = descField.text ?? ""
            
            guard let containerURL = FileManager.default.url(forUbiquityContainerIdentifier: self.containerIdentifier) else { return }
            let documentsURL = containerURL.appendingPathComponent("Documents")
            let sanitizedTitle = title.replacingOccurrences(of: "/", with: "-") // Sanitize filename
            let newFileURL = documentsURL.appendingPathComponent("\(sanitizedTitle).txt")
            
            let document = NoteDocument(fileURL: newFileURL)
            document.text = description
            let coordinator = NSFileCoordinator(filePresenter: nil)
            coordinator.coordinate(writingItemAt: newFileURL, options: .forReplacing, error: nil) { _ in
                document.save(to: newFileURL, for: .forCreating) { success in
                    if success {
                        os_log("Note created at: %@", log: OSLog.default, type: .info, newFileURL.absoluteString)
                        document.close(completionHandler: nil)
                        let successAlert = UIAlertController(title: "Success", message: "Note added successfully.", preferredStyle: .alert)
                        self.present(successAlert, animated: true)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            successAlert.dismiss(animated: true)
                        }
                    } else {
                        os_log("Failed to create note at %@: %@", log: OSLog.default, type: .error, newFileURL.absoluteString, String(describing: FileManager.default.fileExists(atPath: newFileURL.path)))
                        let errorAlert = UIAlertController(title: "Error", message: "Failed to add note.", preferredStyle: .alert)
                        errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(errorAlert, animated: true)
                    }
                }
            }
        })
        present(alert, animated: true)
    }
    
    func editNote(at url: URL) {
        let document = NoteDocument(fileURL: url)
        let editorVC = NoteEditorViewController()
        editorVC.document = document
        editorVC.title = url.deletingPathExtension().lastPathComponent
        
        let nav = UINavigationController(rootViewController: editorVC)
        if #available(iOS 15.0, *) {
            if let sheet = nav.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 20
            }
        }
        present(nav, animated: true)
    }
    
    func deleteNote(at url: URL) {
        let coordinator = NSFileCoordinator(filePresenter: nil)
        coordinator.coordinate(writingItemAt: url, options: .forDeleting, error: nil) { _ in
            do {
                try FileManager.default.removeItem(at: url)
                os_log("Note deleted: %@", log: OSLog.default, type: .info, url.absoluteString)
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Success", message: "Note deleted successfully.", preferredStyle: .alert)
                    self.present(alert, animated: true)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        alert.dismiss(animated: true)
                    }
                }
            } catch {
                os_log("Failed to delete note: %@", log: OSLog.default, type: .error, error.localizedDescription)
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error", message: "Failed to delete note.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return documents.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let url = documents[indexPath.row]
        cell.textLabel?.text = url.deletingPathExtension().lastPathComponent
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        cell.backgroundColor = .systemBackground
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = documents[indexPath.row]
        editNote(at: url)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let url = documents[indexPath.row]
            deleteNote(at: url)
            documents.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    deinit {
        query?.stop()
        NotificationCenter.default.removeObserver(self)
        os_log("ICloudDocumentsViewController deinit", log: OSLog.default, type: .info)
    }
}
