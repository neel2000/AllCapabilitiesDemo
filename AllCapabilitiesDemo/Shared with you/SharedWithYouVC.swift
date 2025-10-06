//
//  SharedWithYouVC.swift
//  AllCapabilitiesDemo
//
//  Created by Nihar Dudhat on 06/10/25.
//

import UIKit
import SharedWithYou

@available(iOS 16.0, *)
final class SharedWithYouVC: UIViewController, UITableViewDelegate, UITableViewDataSource, SWHighlightCenterDelegate {

    // MARK: - UI Components
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    // MARK: - Data
    private let highlightCenter = SWHighlightCenter()
    private var highlights: [SWHighlight] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupHighlightCenter()
    }

    // MARK: - Setup UI
    private func setupUI() {
        title = "Shared With You"
        view.backgroundColor = .systemGroupedBackground
        view.addSubview(tableView)
        
        // ✅ Add constraints for tableView
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SharedWithYouCell.self, forCellReuseIdentifier: "SharedWithYouCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.backgroundColor = .systemGroupedBackground
    }

    private func setupHighlightCenter() {
        highlightCenter.delegate = self
        highlights = highlightCenter.highlights
        print(highlights)
    }

    // MARK: - SWHighlightCenterDelegate
    func highlightCenterHighlightsDidChange(_ highlightCenter: SWHighlightCenter) {
        highlights = highlightCenter.highlights
        print(highlights)
    }

    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if highlights.isEmpty {
            tableView.setEmptyMessage("No shared items yet.\nWhen someone shares a link with you in Messages, it will appear here.")
        } else {
            tableView.restoreBackground()
        }
        return highlights.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SharedWithYouCell", for: indexPath) as? SharedWithYouCell else {
            return UITableViewCell()
        }
        cell.configure(with: highlights[indexPath.row])
        return cell
    }

    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let highlight = highlights[indexPath.row]
        UIApplication.shared.open(highlight.url)
    }
}

@available(iOS 16.0, *)
class SharedWithYouCell: UITableViewCell {
    
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private var attributionView: SWAttributionView?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        // Rounded background container like your screenshot
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 12
        containerView.layer.masksToBounds = true
        contentView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])

        // Title label setup
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.font = .systemFont(ofSize: 15)
        containerView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -120),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -12)
        ])
    }

    func configure(with highlight: SWHighlight) {
        titleLabel.text = highlight.url.absoluteString

        // Remove old attribution view
        attributionView?.removeFromSuperview()

        // Create new attribution view
        let attribution = SWAttributionView()
        attribution.highlight = highlight
        attribution.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(attribution)
        attributionView = attribution

        NSLayoutConstraint.activate([
            attribution.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            attribution.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            attribution.widthAnchor.constraint(greaterThanOrEqualToConstant: 100),
            attribution.heightAnchor.constraint(equalToConstant: 30),

            // Prevent overlap with label
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: attribution.leadingAnchor, constant: -8)
        ])
    }
}

extension UITableView {
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.textColor = .secondaryLabel
        messageLabel.font = .systemFont(ofSize: 16)
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        backgroundView = messageLabel
    }

    func restoreBackground() {
        backgroundView = nil
    }
}
