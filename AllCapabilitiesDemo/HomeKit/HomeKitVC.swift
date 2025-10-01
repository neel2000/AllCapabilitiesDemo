//
//  HomeKitVC.swift
//  AllCapabilitiesDemo
//
//  Created by Nihar Dudhat on 19/09/25.
//

import UIKit
import HomeKit

class HomeKitVC: UIViewController {
    
    private var homeManager: HMHomeManager!
    private var homes: [HMHome] = []
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        return table
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .gray
        label.text = "Loading HomeKit data..."
        return label
    }()
    
    private let infoButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Info", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "HomeKit Demo"
        view.backgroundColor = .systemBackground
        
        setupUI()
        
        // Initialize HomeManager (triggers permission request if needed)
        homeManager = HMHomeManager()
        homeManager.delegate = self
    }
    
    private func setupUI() {
        view.addSubview(tableView)
        view.addSubview(infoLabel)
        view.addSubview(infoButton)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        NSLayoutConstraint.activate([
            // TableView constraints
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: infoButton.topAnchor, constant: -8),
            
            // Info Label constraints
            infoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            infoLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Info Button constraints
//            infoButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            infoButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            infoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            infoButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            infoButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Add button action
        infoButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
    }
    
    @objc private func infoButtonTapped() {
        let vc = DescriptionVC()
        vc.infoText = """
            The HomeKit capability lets your app securely connect with and control smart home devices such as lights, thermostats, cameras, locks, and sensors. It provides a standardized way to manage smart accessories and organize them into homes, rooms, zones, and scenes.

            With HomeKit, your app can:

                • 🔍 Discover smart devices on the local network.

                • 🏡 Create and manage homes with rooms and zones.

                • 💡 Control accessories (e.g., turn lights on/off, lock doors, adjust temperature).

                • 🎭 Set up scenes (like “Good Night” to dim lights and lock doors at once).

                • 🤖 Create automations triggered by time, location, or accessory states.

                • ☁️ Sync with iCloud so settings work across all Apple devices.

            🔑 Requirements

                • Enable HomeKit capability in Xcode (Signing & Capabilities → HomeKit).

                • Add Privacy - HomeKit Usage Description in Info.plist with a clear explanation.

                • Users must grant HomeKit permission when prompted.

                • Accessories must support Apple HomeKit protocol to appear.

            💡 Why It’s Useful

            HomeKit ensures:

                • Security: Strong encryption for smart device control.

                • Seamless integration: Works with Siri, Control Center, and the Home app.

                • Consistency: All HomeKit-enabled accessories follow the same standards.

            👉 In simple terms: HomeKit lets your iOS app act as a smart home controller, securely managing and automating lights, locks, thermostats, and more, while integrating deeply with Apple’s ecosystem.
            """
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


// MARK: - HMHomeManagerDelegate
extension HomeKitVC: HMHomeManagerDelegate {
    
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        homes = manager.homes
        if homes.isEmpty {
            infoLabel.text = "No Home configured.\nAdd a Home in the Home app."
            tableView.isHidden = true
        } else {
            infoLabel.text = nil
            tableView.isHidden = false
            tableView.reloadData()
        }
    }
}

// MARK: - UITableViewDataSource
extension HomeKitVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return homes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let home = homes[indexPath.row]
        cell.textLabel?.text = home.name
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

// MARK: - UITableViewDelegate
extension HomeKitVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let home = homes[indexPath.row]
        let accessoriesVC = AccessoriesViewController(home: home)
        navigationController?.pushViewController(accessoriesVC, animated: true)
    }
}

class AccessoriesViewController: UIViewController {
    
    private let home: HMHome
    private var accessories: [HMAccessory] = []
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(UITableViewCell.self, forCellReuseIdentifier: "AccessoryCell")
        return table
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = .gray
        label.text = "No accessories found in this Home."
        label.isHidden = true
        return label
    }()
    
    init(home: HMHome) {
        self.home = home
        super.init(nibName: nil, bundle: nil)
        self.accessories = home.accessories
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = home.name
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        view.addSubview(emptyLabel)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        updateUI()
    }
    
    private func updateUI() {
        if accessories.isEmpty {
            emptyLabel.isHidden = false
            tableView.isHidden = true
        } else {
            emptyLabel.isHidden = true
            tableView.isHidden = false
        }
    }
}

// MARK: - UITableViewDataSource
extension AccessoriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accessories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccessoryCell", for: indexPath)
        let accessory = accessories[indexPath.row]
        cell.textLabel?.text = accessory.name
        return cell
    }
}

// MARK: - UITableViewDelegate
extension AccessoriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let accessory = accessories[indexPath.row]
        print("Tapped accessory: \(accessory.name)")
    }
}
