//
//  GroupActivitiesVC.swift
//  AllCapabilitiesDemo
//
//  Created by Nihar Dudhat on 19/08/25.
//

import UIKit
import GroupActivities

// Define the Group Activity for the to-do list
struct TodoListActivity: GroupActivity {
    static let activityIdentifier = "com.appcaps.TodoApp.TodoListActivity"

    var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()
        metadata.title = NSLocalizedString("Shared To-Do List", comment: "Activity title")
        metadata.type = .generic
        return metadata
    }
}

// Coordinator to manage Group Activities
class TodoListCoordinator: NSObject {
    var groupSession: GroupSession<TodoListActivity>?
    var messenger: GroupSessionMessenger?
    var todos: [String] = []
    weak var delegate: TodoListCoordinatorDelegate?

    // Start sharing the activity
    func startSharing() async {
        let activity = TodoListActivity()
        do {
            _ = try await activity.activate()
            print("Activity activated successfully")
        } catch {
            print("Failed to activate activity: \(error)")
        }
    }

    // Configure and monitor group sessions
    func configureGroupSession() async {
        for await session in TodoListActivity.sessions() {
            self.groupSession = session
            self.messenger = GroupSessionMessenger(session: session)
            session.join()

            // Monitor session state
            Task {
                for await state in session.$state.values {
                    print("Session state: \(state)")
                    if case .invalidated = state {
                        await MainActor.run {
                            self.groupSession = nil
                            self.messenger = nil
                            self.todos.removeAll()
                            self.delegate?.didUpdateTodos([])
                        }
                    }
                }
            }

            // Handle incoming to-do items
            await setupMessageHandler()
        }
    }

    // Receive to-do items from other participants
    func setupMessageHandler() async {
        guard let messenger = messenger else { return }
        for await (message, _) in messenger.messages(of: String.self) {
            await MainActor.run {
                self.todos.append(message)
                self.delegate?.didUpdateTodos(self.todos)
            }
        }
    }

    // Send a new to-do item
    func sendTodo(_ todo: String) async {
        guard let messenger = messenger else {
            print("No active session")
            return
        }
        do {
            try await messenger.send(todo)
            await MainActor.run {
                self.todos.append(todo)
                self.delegate?.didUpdateTodos(self.todos)
            }
        } catch {
            print("Failed to send to-do: \(error)")
        }
    }
}

// Delegate protocol for coordinator updates
protocol TodoListCoordinatorDelegate: AnyObject {
    func didUpdateTodos(_ todos: [String])
}

// Main View Controller
class GroupActivitiesVC: UIViewController, UITableViewDataSource, UITableViewDelegate, TodoListCoordinatorDelegate {
    
    private let coordinator = TodoListCoordinator()
    private var todos: [String] = []

    // UI Components
    private let tableView = UITableView()
    private let textField = UITextField()
    private let addButton = UIButton(type: .system)
    private let shareButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        coordinator.delegate = self
        Task {
            await coordinator.configureGroupSession()
        }
    }

    // Set up the UI
    private func setupUI() {
        view.backgroundColor = .white

        // Configure text field
        textField.placeholder = "Enter to-do"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textField)

        // Configure add button
        addButton.setTitle("Add To-Do", for: .normal)
        addButton.addTarget(self, action: #selector(addTodoTapped), for: .touchUpInside)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addButton)

        // Configure share button
        shareButton.setTitle("Start Sharing", for: .normal)
        shareButton.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(shareButton)

        // Configure table view
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TodoCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        // Layout constraints
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textField.trailingAnchor.constraint(equalTo: addButton.leadingAnchor, constant: -10),
            textField.heightAnchor.constraint(equalToConstant: 40),

            addButton.centerYAnchor.constraint(equalTo: textField.centerYAnchor),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.widthAnchor.constraint(equalToConstant: 100),

            shareButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 20),
            shareButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            tableView.topAnchor.constraint(equalTo: shareButton.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    // MARK: - Actions
    @objc private func addTodoTapped() {
        guard let todo = textField.text, !todo.isEmpty else { return }
        Task {
            await coordinator.sendTodo(todo)
            textField.text = ""
            textField.resignFirstResponder()
        }
    }

    @objc private func shareTapped() {
        Task {
            await coordinator.startSharing()
        }
    }

    // MARK: - TodoListCoordinatorDelegate
    func didUpdateTodos(_ todos: [String]) {
        self.todos = todos
        tableView.reloadData()
    }

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath)
        cell.textLabel?.text = todos[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        return cell
    }
}
