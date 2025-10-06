//
//  MessageCollaborationVC.swift
//  AllCapabilitiesDemo
//
//  Created by Nihar Dudhat on 02/10/25.
//

import UIKit
import CloudKit
import SharedWithYou
import UniformTypeIdentifiers

//struct Note {
//    let record: CKRecord
//    
//    var id: CKRecord.ID { record.recordID }
//    var text: String {
//        get { record["text"] as? String ?? "" }
//        set { record["text"] = newValue }
//    }
//    
//    init(text: String) {
//        self.record = CKRecord(recordType: "Note")
//        self.record["text"] = text
//    }
//    
//    init(record: CKRecord) {
//        self.record = record
//    }
//}
//
//class CloudKitManager {
//    static let shared = CloudKitManager()
//    let container = CKContainer.default()
//    let db = CKContainer(identifier: "iCloud.allcaps.container").privateCloudDatabase
//
//    
//    func createNoteAndShare(text: String, completion: @escaping (CKShare?, CKRecord?, Error?) -> Void) {
//        let note = Note(text: text)
//        let share = CKShare(rootRecord: note.record)
//        share[CKShare.SystemFieldKey.title] = "Shared Note" as CKRecordValue
//        
//        let records = [note.record, share]
//        let saveOperation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
//        saveOperation.savePolicy = .allKeys
//        saveOperation.modifyRecordsResultBlock = { result in
//            switch result {
//            case .success:
//                completion(share, note.record, nil)
//            case .failure(let error):
//                completion(nil, nil, error)
//            }
//        }
//        db.add(saveOperation)
//    }
//}


//class MessageCollaborationVC: UIViewController {
    
//    private let shareButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Create & Share Note", for: .normal)
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
//        button.backgroundColor = UIColor.systemBlue
//        button.setTitleColor(.white, for: .normal)
//        button.layer.cornerRadius = 8
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .systemBackground
//        
//        view.addSubview(shareButton)
//        NSLayoutConstraint.activate([
//            shareButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            shareButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//            shareButton.widthAnchor.constraint(equalToConstant: 220),
//            shareButton.heightAnchor.constraint(equalToConstant: 50)
//        ])
//        
//        shareButton.addTarget(self, action: #selector(didTapShare), for: .touchUpInside)
//    }
    
//    @objc private func didTapShare() {
//        CloudKitManager.shared.createNoteAndShare(text: "Hello collaborators from UIKit!") { share, noteRecord, error in
//            if let share = share, let noteRecord = noteRecord {
//                DispatchQueue.main.async {
//                    let activityVC = UIActivityViewController(activityItems: [share, noteRecord], applicationActivities: nil)
//                    self.present(activityVC, animated: true)
//                }
//            } else if let error = error {
//                print("Error creating share: \(error)")
//            }
//        }
//    }
    
//}

//import UIKit
//import SharedWithYou
//
//struct DemoDoc {
//    let id: String
//    let title: String
//    let fileURL: URL
//}
//
//@available(iOS 16.0, *)
//final class MessageCollaborationVC: UIViewController, SWCollaborationActionHandler {
//
//    let doc = DemoDoc(
//        id: "demo-document-id",
//        title: "Team Plan",
//        fileURL: FileManager.default.temporaryDirectory.appendingPathComponent("DemoPlan.txt")
//    )
//
//    private let collabCoordinator = SWCollaborationCoordinator.shared
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .systemBackground
//
//        collabCoordinator.actionHandler = self
//
//        let button = UIButton(type: .system)
//        button.setTitle("Share in Messages", for: .normal)
//        button.addTarget(self, action: #selector(shareDoc), for: .touchUpInside)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(button)
//        NSLayoutConstraint.activate([
//            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
//        ])
//
//        // Write sample text to file.
//        try? "Project timeline:\n- Kickoff\n- Review\n- Launch".write(to: doc.fileURL, atomically: true, encoding: .utf8)
//    }
//
//    @objc private func shareDoc() {
//        // 1. Prepare collaboration metadata
//        let collabID = SWLocalCollaborationIdentifier(rawValue: doc.id)
//        let meta = SWCollaborationMetadata(localIdentifier: collabID)
//        meta.title = doc.title
//        meta.initiatorHandle = "demo@example.com"
//        meta.initiatorNameComponents = PersonNameComponentsFormatter().personNameComponents(from: "Jane Demo")
//        // Provide collaboration options
//        let perm = SWCollaborationOptionsPickerGroup(
//            identifier: "permission",
//            options: [
//                SWCollaborationOption(title: "Can Edit", identifier: "edit"),
//                SWCollaborationOption(title: "View Only", identifier: "readonly")
//            ]
//        )
//        perm.options.first?.isSelected = true
//        perm.title = "Permissions"
//        meta.defaultShareOptions = SWCollaborationShareOptions(optionsGroups: [perm])
//
//        // 2. Register collaboration metadata
//        let provider = NSItemProvider()
//        provider.registerObject(meta, visibility: .all)
//        // Register file copy for "Send a Copy" option:
//        provider.registerFileRepresentation(forTypeIdentifier: "public.text", fileOptions: [], visibility: .all) { completion in
//            completion(self.doc.fileURL, false, nil)
//            return nil
//        }
//
//        // 3. Show share sheet
//        let config = UIActivityItemsConfiguration(itemProviders: [provider])
//        let sheet = UIActivityViewController(activityItemsConfiguration: config)
//        present(sheet, animated: true)
//    }
//
//    // Collaboration handlers: Required for custom infra (or backend), demo stubs shown.
//    func collaborationCoordinator(_ coordinator: SWCollaborationCoordinator, handle action: SWStartCollaborationAction) {
//        let localCollabID = action.collaborationMetadata.localIdentifier.rawValue
//        let dummyURL = URL(string: "allcapabilities://collaboration/\(localCollabID)")!
//        let collabIdentifier = "local-collab-\(localCollabID)"
//        action.fulfill(using: dummyURL, collaborationIdentifier: SWCollaborationIdentifier(rawValue: collabIdentifier))
//    }
//    
//    func collaborationCoordinator(_ coordinator: SWCollaborationCoordinator, handle action: SWUpdateCollaborationParticipantsAction) {
//        // Update participants on backend as needed
//        action.fulfill()
//    }
//}

//// Create zone if it doesn’t exist
//database.save(customZone) { zone, error in
//    if let error = error as? CKError {
//        print("Error creating zone: \(error)")
//    } else {
//        print("Zone ready: \(self.customZone.zoneID)")
//    }
//}
import UIKit
import CloudKit

class MessageCollaborationVC: UIViewController {
    let container = CKContainer(identifier: "iCloud.allcaps.container")
    var database: CKDatabase!
    let customZone = CKRecordZone(zoneName: "DocumentsZone")
    
    let shareButton = UIButton(type: .system)
    let textView = UITextView()
    let saveButton = UIButton(type: .system)
    let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    var currentRecord: CKRecord?
    var txtLoaded = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        database = container.privateCloudDatabase
        view.backgroundColor = .systemBackground
        title = "Document Editor"
        
        // Setup UI
        setupUI()
        
        // Create zone if it doesn’t exist
        database.save(customZone) { zone, error in
            if let error = error as? CKError {
                if error.code == .zoneBusy {
                    print("Zone already exists: \(self.customZone.zoneID)")
                } else {
                    print("Error creating zone: \(error)")
                    DispatchQueue.main.async {
                        self.showAlert(title: "Error", message: error.localizedDescription)
                    }
                }
            } else {
                print("Zone created: \(self.customZone.zoneID)")
            }
            // Fetch the single document after zone is ready
            self.fetchSingleDocument()
            self.setupCloudKitSubscription()
        }
    }
    
    private func setupCloudKitSubscription() {
        let subscription = CKDatabaseSubscription(subscriptionID: "shared-document-changes")
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        subscription.notificationInfo = notificationInfo
        container.sharedCloudDatabase.save(subscription) { subscription, error in
            if let error = error {
                print("Failed to save subscription: \(error)")
            } else {
                print("Subscribed to shared document changes")
            }
        }
    }
    
    private func setupUI() {
        // Setup save button
        saveButton.setTitle("Save Changes", for: .normal)
        saveButton.backgroundColor = .systemBlue
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        saveButton.layer.cornerRadius = 8
        saveButton.clipsToBounds = true
        saveButton.addTarget(self, action: #selector(saveChanges), for: .touchUpInside)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(saveButton)
        
        // Setup share button
        shareButton.setTitle("Share Document", for: .normal)
        shareButton.backgroundColor = .systemBlue
        shareButton.setTitleColor(.white, for: .normal)
        shareButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        shareButton.layer.cornerRadius = 8
        shareButton.clipsToBounds = true
        shareButton.addTarget(self, action: #selector(shareDocument), for: .touchUpInside)
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(shareButton)
        
        // Setup text view
        textView.text = "Enter your document content here..."
        textView.textColor = .systemGray
        textView.font = .systemFont(ofSize: 16)
        textView.backgroundColor = .secondarySystemBackground
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.clipsToBounds = true
        textView.delegate = self
        textView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)
        
        // Setup activity indicator
        activityIndicator.color = .systemBlue
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            textView.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -20),
            
            saveButton.bottomAnchor.constraint(equalTo: shareButton.topAnchor, constant: -10),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.widthAnchor.constraint(equalToConstant: 200),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            
            shareButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            shareButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shareButton.widthAnchor.constraint(equalToConstant: 200),
            shareButton.heightAnchor.constraint(equalToConstant: 50),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func fetchSingleDocument() {
        activityIndicator.startAnimating()
        let recordID = CKRecord.ID(recordName: "SingleDocument", zoneID: customZone.zoneID)
        database.fetch(withRecordID: recordID) { [weak self] record, error in
            guard let self = self else {
                self?.activityIndicator.stopAnimating()
                return
            }
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                if let error = error as? CKError, error.code == .unknownItem {
                    // No document exists, create a new one
                    self.createSingleDocument()
                } else if let error = error {
                    print("Error fetching document: \(error)")
                    self.showAlert(title: "Error", message: "Could not load document: \(error.localizedDescription)")
                    self.textView.text = ""
                    self.textView.textColor = .label
                } else if let record = record {
                    self.currentRecord = record
                    self.textView.text = record["content"] as? String ?? ""
                    self.txtLoaded = record["content"] as? String ?? ""
                    self.textView.textColor = .label
                    self.title = record["title"] as? String ?? "Document Editor"
                }
            }
        }
    }
    
    private func createSingleDocument() {
        let recordID = CKRecord.ID(recordName: "SingleDocument", zoneID: customZone.zoneID)
        let record = CKRecord(recordType: "Document", recordID: recordID)
        record["title"] = "My Document" as CKRecordValue
        record["content"] = "" as CKRecordValue
        currentRecord = record
        
        database.save(record) { [weak self] savedRecord, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                if let error = error {
                    print("Error creating document: \(error)")
                    self.showAlert(title: "Error", message: "Failed to create document: \(error.localizedDescription)")
                    self.currentRecord = nil
                    self.textView.text = ""
                    self.textView.textColor = .label
                } else {
                    self.currentRecord = savedRecord
                    self.textView.text = ""
                    self.textView.textColor = .label
                    print("Single document created")
                }
            }
        }
    }
    
    @objc func shareDocument() {
        guard let record = currentRecord else {
            showAlert(title: "No Document", message: "Please wait for the document to load or create one first.")
            return
        }
        
        activityIndicator.startAnimating()
        let share = CKShare(rootRecord: record)
        share[CKShare.SystemFieldKey.title] = "Collaboration with My Document" as CKRecordValue
        share.publicPermission = .readWrite
        
        let op = CKModifyRecordsOperation(recordsToSave: [record, share], recordIDsToDelete: nil)
        op.modifyRecordsCompletionBlock = { [weak self] savedRecords, _, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                if let error = error {
                    print("Error sharing document: \(error)")
                    self.showAlert(title: "Error", message: "Failed to share document: \(error.localizedDescription)")
                    return
                }
                
                if let savedRecord = savedRecords?.first(where: { $0.recordID == record.recordID }) {
                    self.currentRecord = savedRecord
                }
                
                guard let savedShare = savedRecords?.first(where: { $0 is CKShare }) as? CKShare else {
                    print("Share not found in saved records")
                    return
                }
                
                let shareController = UICloudSharingController(share: savedShare, container: self.container)
                shareController.delegate = self
                self.present(shareController, animated: true, completion: nil)
            }
        }
        database.add(op)
    }
    
    @objc func saveChanges() {
        guard let record = currentRecord else {
            showAlert(title: "No Document", message: "Please wait for the document to load.")
            return
        }
        let updatedText = (textView.textColor == .label ? textView.text : "") ?? ""
        updateSharedDocument(record: record, newText: updatedText)
    }
    
    func updateSharedDocument(record: CKRecord, newText: String) {
        
        guard textView.text != self.txtLoaded else {
            return
        }
        
        activityIndicator.startAnimating()
        record["title"] = "My Document" as CKRecordValue
        record["content"] = newText as CKRecordValue
        
        let database: CKDatabase
        if let share = record.share, share.recordID.zoneID != self.customZone.zoneID {
            // Record is shared, use sharedCloudDatabase with the share's zone
            database = container.sharedCloudDatabase
        } else {
            // Record is not shared or in private zone, use privateCloudDatabase
            database = container.privateCloudDatabase
        }
        
        database.save(record) { [weak self] savedRecord, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                if let error = error {
                    print("Error saving updated document: \(error)")
                    self.showAlert(title: "Error", message: "Failed to save document: \(error.localizedDescription)")
                    return
                }
                self.currentRecord = savedRecord
                print("Document updated successfully")
                self.showAlert(title: "Success", message: "Document updated successfully.")
            }
        }
    }
    
    func handleShareMetadata(_ metadata: CKShare.Metadata) {
        activityIndicator.startAnimating()
        let database = container.sharedCloudDatabase
        database.fetch(withRecordID: metadata.rootRecordID) { [weak self] record, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                if let error = error {
                    print("Error fetching shared record: \(error)")
                    self.showAlert(title: "Error", message: "Could not load shared document: \(error.localizedDescription)")
                    return
                }
                guard let record = record else {
                    print("No record found")
                    return
                }
                self.currentRecord = record
                self.textView.text = record["content"] as? String ?? ""
                self.textView.textColor = .label
                self.title = record["title"] as? String ?? "Document Editor"
            }
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension MessageCollaborationVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .systemGray {
            textView.text = ""
            textView.textColor = .label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Enter your document content here..."
            textView.textColor = .systemGray
        }
    }
}

extension MessageCollaborationVC: UICloudSharingControllerDelegate {
    func cloudSharingController(_ csc: UICloudSharingController, failedToSaveShareWithError error: Error) {
        print("Failed to share: \(error)")
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.showAlert(title: "Error", message: "Failed to share document: \(error.localizedDescription)")
        }
    }
    
    func cloudSharingControllerDidSaveShare(_ csc: UICloudSharingController) {
        print("Share saved successfully")
    }
    
    func itemTitle(for csc: UICloudSharingController) -> String? {
        return "My Collaborative Document"
    }
}
