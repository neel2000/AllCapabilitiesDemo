//
//  DescriptionVC.swift
//  AllCapabilitiesDemo
//
//  Created by Nihar Dudhat on 16/09/25.
//

import UIKit

class DescriptionVC: UIViewController {
    
    // MARK: - UI Elements
    private let infoTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.isEditable = false
        textView.isScrollEnabled = true
        return textView
    }()
    
    // MARK: - Variable to hold text
    var infoText: String?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()
        
        // Set passed text
        infoTextView.text = infoText
    }
    
    // MARK: - Layout Setup
    private func setupLayout() {
        view.addSubview(infoTextView)
        infoTextView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            infoTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            infoTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            infoTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            infoTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12)
        ])
    }
}

//import UIKit
//import ClassKit
//
//class DescriptionVC: UIViewController {
//    
//    var infoText: String?
//    
//    private let questionLabel: UILabel = {
//        let label = UILabel()
//        label.text = "What is 2 + 2?"
//        label.font = .systemFont(ofSize: 24, weight: .bold)
//        label.textAlignment = .center
//        label.numberOfLines = 0
//        return label
//    }()
//    
//    private let answerButton1: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("3", for: .normal)
//        button.tag = 1
//        return button
//    }()
//    
//    private let answerButton2: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("4", for: .normal)
//        button.tag = 2
//        return button
//    }()
//    
//    // ClassKit context & activity
//    private var quizContext: CLSContext?
//    private var currentActivity: CLSActivity?
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .systemBackground
//        
//        setupUI()
//        createClassKitContext()
//    }
//    
//    private func setupUI() {
//        let stack = UIStackView(arrangedSubviews: [questionLabel, answerButton1, answerButton2])
//        stack.axis = .vertical
//        stack.spacing = 20
//        stack.alignment = .center
//        stack.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(stack)
//        
//        NSLayoutConstraint.activate([
//            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
//        ])
//        
//        answerButton1.addTarget(self, action: #selector(answerTapped(_:)), for: .touchUpInside)
//        answerButton2.addTarget(self, action: #selector(answerTapped(_:)), for: .touchUpInside)
//    }
//    
//    // MARK: - ClassKit
//    
//    private func createClassKitContext() {
//        let store = CLSDataStore.shared
//        
//        // Create a new quiz context
//        let context = CLSContext(type: .quiz, identifier: "math_quiz_1", title: "Simple Math Quiz")
//        quizContext = context
//        
//        // Save context
//        store.mainAppContext.addChildContext(context)
//        
//        store.save { error in
//            if let error = error {
//                print("❌ Error saving context: \(error.localizedDescription)")
//            } else {
//                print("✅ ClassKit context saved.")
//                self.startActivity()
//            }
//        }
//    }
//    
//    private func startActivity() {
//        guard let quizContext = quizContext else { return }
//        
//        // Make context active
//        quizContext.becomeActive()
//        
//        // ✅ Create an activity linked to this context
//        let activity = quizContext.createNewActivity()
//        activity.primaryActivityItem?.title = "Quiz Attempt"
//        activity.progress = 0.0
//        currentActivity = activity
//        
//        print("✅ Activity created and started for quiz.")
//        
//        // Save to persist activity
//        CLSDataStore.shared.save { error in
//            if let error = error {
//                print("❌ Error saving activity: \(error.localizedDescription)")
//            } else {
//                print("✅ Activity saved successfully.")
//            }
//        }
//    }
//
//    
//    @objc private func answerTapped(_ sender: UIButton) {
//        guard let activity = currentActivity else { return }
//        
//        if sender.tag == 2 {
//            questionLabel.text = "✅ Correct! 2 + 2 = 4"
//            activity.progress = 1.0
//            //activity.finish()
//        } else {
//            questionLabel.text = "❌ Wrong! Try again."
//            activity.progress = 0.5
//        }
//        
//        CLSDataStore.shared.save { error in
//            if let error = error {
//                print("❌ Error saving progress: \(error.localizedDescription)")
//            } else {
//                print("✅ Progress updated: \(activity.progress)")
//            }
//        }
//    }
//}
