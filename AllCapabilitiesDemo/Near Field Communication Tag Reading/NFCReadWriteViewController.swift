//
//  NFCReadWriteViewController.swift
//  AllCapabilitiesDemo
//
//  Created by Nihar Dudhat on 11/08/25.
//

import UIKit
import CoreNFC

class NFCReadWriteViewController: UIViewController, NFCNDEFReaderSessionDelegate {
    
    var nfcSession: NFCNDEFReaderSession?
    var isWriting = false
    var messageToWrite: NFCNDEFMessage?
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Tap a button to begin"
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let inputField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter text to write to NFC tag"
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.widthAnchor.constraint(equalToConstant: 320).isActive = true
        tf.heightAnchor.constraint(equalToConstant: 40).isActive = true
        return tf
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let readButton = UIButton(type: .system)
        readButton.setTitle("Read NFC Tag", for: .normal)
        readButton.addTarget(self, action: #selector(startRead), for: .touchUpInside)
        
        let writeButton = UIButton(type: .system)
        writeButton.setTitle("Write NFC Tag", for: .normal)
        writeButton.addTarget(self, action: #selector(startWrite), for: .touchUpInside)
        
        let stack = UIStackView(arrangedSubviews: [statusLabel, inputField, readButton, writeButton])
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.alignment = .center
        
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    @objc func startRead() {
        isWriting = false
        guard NFCNDEFReaderSession.readingAvailable else {
            updateStatus("NFC is not supported on this device.")
            return
        }
        
        nfcSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        nfcSession?.alertMessage = "Hold your iPhone near the NFC tag to read."
        nfcSession?.begin()
    }
    
    @objc func startWrite() {
        isWriting = true
        
        let textToWrite = inputField.text ?? ""
        guard !textToWrite.isEmpty else {
            self.showAlert(message: "Please enter text before writing.")
//            updateStatus("Please enter text before writing.")
            return
        }
        
        if let payload = NFCNDEFPayload.wellKnownTypeTextPayload(string: textToWrite, locale: Locale(identifier: "en")) {
            messageToWrite = NFCNDEFMessage(records: [payload])
        } else {
            updateStatus("Failed to create NFC payload.")
            return
        }
        
        guard NFCNDEFReaderSession.readingAvailable else {
            updateStatus("NFC is not supported on this device.")
            return
        }
        
        nfcSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        nfcSession?.alertMessage = "Hold your iPhone near the NFC tag to write."
        nfcSession?.begin()
    }
    
    // MARK: - NFCNDEFReaderSessionDelegate
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        updateStatus("Session ended: \(error.localizedDescription)")
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        var results = [String]()
        for message in messages {
            for record in message.records {
                if let text = String(data: record.payload, encoding: .utf8) {
                    results.append(text)
                }
            }
        }
        updateStatus("✅ Read: \(results.joined(separator: ", "))")
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        guard let tag = tags.first else { return }
        
        session.connect(to: tag) { [weak self] error in
            if let error = error {
                session.invalidate(errorMessage: "Connection failed: \(error.localizedDescription)")
                return
            }
            
            tag.queryNDEFStatus { status, _, error in
                guard error == nil else {
                    session.invalidate(errorMessage: "NDEF status query failed.")
                    return
                }
                
                if self?.isWriting == true {
                    if status == .readWrite, let message = self?.messageToWrite {
                        tag.writeNDEF(message) { error in
                            if let error = error {
                                session.invalidate(errorMessage: "Write failed: \(error.localizedDescription)")
                            } else {
                                session.alertMessage = "Successfully wrote to NFC tag."
                                session.invalidate()
                            }
                        }
                    } else {
                        session.invalidate(errorMessage: "Tag is not writable.")
                    }
                } else {
                    tag.readNDEF { message, error in
                        if let message = message {
                            let payloads = message.records.map { String(data: $0.payload, encoding: .utf8) ?? "" }
                            session.invalidate()
                            self?.updateStatus("✅ Read: \(payloads.joined(separator: ", "))")
                        } else {
                            session.invalidate(errorMessage: "Read failed.")
                        }
                    }
                }
            }
        }
    }
    
    private func updateStatus(_ text: String) {
        DispatchQueue.main.async {
            self.statusLabel.text = text
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Info", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
