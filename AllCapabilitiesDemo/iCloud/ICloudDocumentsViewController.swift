//
//  ICloudDocumentsViewController.swift
//  AllCapabilitiesDemo
//
//  Created by DREAMWORLD on 12/12/24.
//

import UIKit

class ICloudDocumentsViewController: UIViewController {
    
    @IBOutlet weak var tfContent: UITextField!
    @IBOutlet weak var lblContent: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        iCloudManager.shared.createDirectoryIfNeeded()
    }
    
    @IBAction func btnSaveContentAction(_ sender: Any) {
        if (tfContent.text ?? "").isEmpty {
            self.showAlert(message: "Please enter content")
        } else {
            saveDocument(fileName: "sample3.txt", content: self.tfContent.text ?? "")
        }
    }
    
    @IBAction func btnFetchContentAction(_ sender: Any) {
        fetchDocuments()
    }
    
    @IBAction func btnDeleteContent(_ sender: Any) {
        self.lblContent.text = ""
        deleteDocument(fileName: "sample3.txt")
    }
        
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Cap Demo", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            alert.dismiss(animated: true)
        }))
        self.present(alert, animated: true)
    }
    
    func saveDocument(fileName: String, content: String) {
        guard let iCloudDir = iCloudManager.shared.getICloudDirectory() else { return }
        
        let fileURL = iCloudDir.appendingPathComponent(fileName)
        let document = MyDocument(fileURL: fileURL)
        document.content = content
        
        document.save(to: fileURL, for: .forCreating) { success in
            if success {
                self.tfContent.text = ""
                self.showAlert(message: "Content saved successfully.")
                print("Document saved successfully.")
            } else {
                print("Failed to save document.")
            }
        }
    }
    
    func fetchDocuments() {
        guard let iCloudDir = iCloudManager.shared.getICloudDirectory() else { return }
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: iCloudDir, includingPropertiesForKeys: nil)
            
            for fileURL in fileURLs {
                let document = MyDocument(fileURL: fileURL)
                document.open { success in
                    if success {
                        self.lblContent.text = document.content
                        print("Document content: \(document.content)")
                        document.close()
                    } else {
                        self.showAlert(message: "Failed to open document.")
                        print("Failed to open document.")
                    }
                }
            }
        } catch {
            print("Error fetching documents: \(error.localizedDescription)")
        }
    }
    
    func deleteDocument(fileName: String) {
        guard let iCloudDir = iCloudManager.shared.getICloudDirectory() else { return }
        let fileURL = iCloudDir.appendingPathComponent(fileName)
        
        do {
            try FileManager.default.removeItem(at: fileURL)
            self.showAlert(message: "Document deleted successfully.")
            print("Document deleted successfully.")
        } catch {
            print("Error deleting document: \(error.localizedDescription)")
        }
    }
    
    
    
}

class iCloudManager {
    
    static let shared = iCloudManager()
    
    // Access iCloud Documents Directory
    func getICloudDirectory() -> URL? {
        guard let iCloudURL = FileManager.default.url(forUbiquityContainerIdentifier: nil) else {
            print("iCloud not available")
            return nil
        }
        return iCloudURL.appendingPathComponent("Documents")
    }
    
    // Create a Directory if Not Exists
    func createDirectoryIfNeeded() {
        guard let iCloudDir = getICloudDirectory() else { return }
        
        if !FileManager.default.fileExists(atPath: iCloudDir.path) {
            do {
                try FileManager.default.createDirectory(at: iCloudDir, withIntermediateDirectories: true, attributes: nil)
                print("iCloud directory created.")
            } catch {
                print("Error creating iCloud directory: \(error.localizedDescription)")
            }
        }
    }
}

class MyDocument: UIDocument {
    var content: String = ""
    
    override func contents(forType typeName: String) throws -> Any {
        // Convert content to Data
        return content.data(using: .utf8) ?? Data()
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        // Convert Data to String
        if let data = contents as? Data, let loadedContent = String(data: data, encoding: .utf8) {
            content = loadedContent
        }
    }
}
