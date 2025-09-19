//
//  GameCenterVC.swift
//  AllCapabilitiesDemo
//
//  Created by Nihar Dudhat on 18/09/25.
//

import UIKit
import GameKit

class GameCenterVC: UIViewController, GKGameCenterControllerDelegate {
    
    // UI Elements
    private let scoreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.text = "Score: 0"
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24)
        label.textAlignment = .center
        label.text = "Time: 10s"
        return label
    }()
    
    private let tapButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Tap Me!", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        button.backgroundColor = .blue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        return button
    }()
    
    private let playAgainButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Play Again", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.backgroundColor = .green
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.isHidden = true
        return button
    }()
    
    private let leaderboardButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("View Leaderboard", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.backgroundColor = .gray
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let achievementsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("View Achievements", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.backgroundColor = .gray
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.textColor = .red
        label.numberOfLines = 0
        return label
    }()
    
    // Game State
    private var score: Int = 0
    private var timeRemaining: Int = 10
    private var gameOver: Bool = false
    private var timer: Timer?
    private var isAuthenticated: Bool = false
    
    // Game Center IDs (Match your App Store Connect setup)
    let leaderboardID = "high_scores"
    let achievementID = "master_tapper"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "TapMaster Demo"
        
        setupUI()
        authenticatePlayer()
    }
    
    private func setupUI() {
        let stackView = UIStackView(arrangedSubviews: [scoreLabel, timeLabel, tapButton, playAgainButton, leaderboardButton, achievementsButton, statusLabel])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])
        
        tapButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        tapButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        playAgainButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
        playAgainButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        leaderboardButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        leaderboardButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        achievementsButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        achievementsButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        tapButton.addTarget(self, action: #selector(tapAction), for: .touchUpInside)
        playAgainButton.addTarget(self, action: #selector(playAgainAction), for: .touchUpInside)
        leaderboardButton.addTarget(self, action: #selector(showLeaderboard), for: .touchUpInside)
        achievementsButton.addTarget(self, action: #selector(showAchievements), for: .touchUpInside)
    }
    
    @IBAction func btnInfoAction(_ sender: Any) {
        let vc = DescriptionVC()
        vc.infoText = """
            The Game Center capability in iOS lets your game connect to Apple’s social gaming network so players can enjoy a more fun, competitive, and connected experience.

            🔹 What It Does

                • Player Authentication – Allows users to sign in with their Apple ID and use a single Game Center profile across all their games.

                • Leaderboards – Lets players compare their scores with friends or players worldwide.

                • Achievements – Reward players with badges or milestones for reaching goals in your game.

                • Challenges & Multiplayer – Enables friendly challenges, real-time, or turn-based multiplayer matches.

                • Cross-Device Sync – Game progress and scores automatically stay up-to-date across all of a player’s devices.

            🔑 Why It’s Useful

                • Makes your game feel professional and engaging without needing a custom backend for leaderboards or achievements.

                • Encourages replay and competition, which helps boost user retention.

                • Integrates with Apple’s ecosystem (Siri, iMessage, Notifications), giving a smooth, native gaming experience.

            📌 Requirements

                • Apple Developer Program membership.

                • Enable Game Center capability in Xcode.

                • Configure leaderboards, achievements, and multiplayer in App Store Connect.
            """
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func authenticatePlayer() {
        statusLabel.text = "Authenticating with Game Center..."
        
        let localPlayer = GKLocalPlayer.local
        localPlayer.authenticateHandler = { [weak self] viewController, error in
            guard let self = self else { return }
            
            if let vc = viewController {
                self.present(vc, animated: true)
            } else if localPlayer.isAuthenticated {
                self.isAuthenticated = true
                print("Authenticated: \(localPlayer.displayName), isAuthenticated: \(localPlayer.isAuthenticated)")
                self.statusLabel.text = "Authenticated as: \(localPlayer.displayName)"
                self.startGame()
            } else if let error = error {
                self.statusLabel.text = "Authentication failed: \(error.localizedDescription)"
            } else {
                self.statusLabel.text = "Not authenticated. Some features unavailable."
            }
        }
    }
    
    private func startGame() {
        gameOver = false
        score = 0
        timeRemaining = 10
        updateUI()
        playAgainButton.isHidden = true
        tapButton.isEnabled = true
        
        // Invalidate any existing timer to prevent overlap
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            if !self.gameOver {
                self.timeRemaining -= 1
                if self.timeRemaining <= 0 {
                    self.endGame()
                } else {
                    self.updateUI()
                }
            }
        }
    }
    
    private func updateUI() {
        scoreLabel.text = gameOver ? "Game Over! Score: \(score)" : "Score: \(score)"
        // Prevent negative time display
        timeLabel.text = "Time: \(max(0, timeRemaining))s"
    }
    
    @objc private func tapAction() {
        guard isAuthenticated else {
            statusLabel.text = "Please authenticate first."
            return
        }
        if !gameOver {
            score += 1
            updateUI()
        }
    }
    
    @objc private func playAgainAction() {
        startGame()
    }
    
    private func endGame() {
        gameOver = true
        timer?.invalidate()
        timer = nil
        tapButton.isEnabled = false
        playAgainButton.isHidden = false
        updateUI()
        if isAuthenticated {
            Task {
                await submitScore()
                await checkAchievement()
            }
        } else {
            statusLabel.text = "Not authenticated. Score not submitted."
        }
    }
    
    private func submitScore() async {
        let gkScore = GKScore(leaderboardIdentifier: leaderboardID)
        gkScore.value = Int64(score)
        
        do {
            try await GKScore.report([gkScore])
            print("Score submitted: \(score)")
            DispatchQueue.main.async { [weak self] in
                self?.statusLabel.text = "Score submitted!"
            }
        } catch {
            print("Score submission failed: \(error)")
            print("Error details: \(error.localizedDescription)")
            if let gkError = error as? GKError {
                print("GameKit error code: \(gkError.code), description: \(gkError.localizedDescription)")
            }
            DispatchQueue.main.async { [weak self] in
                self?.statusLabel.text = "Failed to submit score: \(error.localizedDescription)"
            }
        }
    }
    
    private func checkAchievement() async {
        if score >= 50 {
            let achievement = GKAchievement(identifier: achievementID)
            achievement.percentComplete = 100.0
            
            do {
                try await GKAchievement.report([achievement])
                print("Achievement unlocked: \(achievementID)")
                DispatchQueue.main.async { [weak self] in
                    self?.statusLabel.text = "Achievement unlocked!"
                }
            } catch {
                print("Achievement submission failed: \(error)")
                print("Error details: \(error.localizedDescription)")
                if let gkError = error as? GKError {
                    print("GameKit error code: \(gkError.code), description: \(gkError.localizedDescription)")
                }
                DispatchQueue.main.async { [weak self] in
                    self?.statusLabel.text = "Failed to unlock achievement: \(error.localizedDescription)"
                }
            }
        }
    }
    
    @objc private func showLeaderboard() {
        guard isAuthenticated else {
            statusLabel.text = "Please authenticate first."
            return
        }
        
        let vc = GKGameCenterViewController(leaderboardID: leaderboardID, playerScope: .global, timeScope: .allTime)
        vc.gameCenterDelegate = self
        present(vc, animated: true)
    }
    
    @objc private func showAchievements() {
        guard isAuthenticated else {
            statusLabel.text = "Please authenticate first."
            return
        }
        
        let vc = GKGameCenterViewController(state: .achievements)
        vc.gameCenterDelegate = self
        present(vc, animated: true)
    }
    
    // GKGameCenterControllerDelegate
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true)
    }
}
