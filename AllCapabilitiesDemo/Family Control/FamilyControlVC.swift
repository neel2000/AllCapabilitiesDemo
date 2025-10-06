//
//  FamilyControlVC.swift
//  AllCapabilitiesDemo
//
//  Created by Nihar Dudhat on 01/10/25.
//

import SwiftUI
import FamilyControls
import ManagedSettings

@available(iOS 16.0, *)
struct FamilyControlVC: View {
    @State private var isPickerPresented = false
    @State private var selection = FamilyActivitySelection()
    @State private var isAuthorized = false
    @State private var errorMessage: String?
    @State private var hasActiveRestrictions = false   // 🔑 Track restrictions
    
    private var hasAnySelection: Bool {
        !selection.applicationTokens.isEmpty ||
        !selection.categoryTokens.isEmpty ||
        !selection.webDomainTokens.isEmpty
    }
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [.blue.opacity(0.3), .purple.opacity(0.5)],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("App Restriction Manager")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                
                if isAuthorized {
                    Text("✅ Guardian Authorization Granted")
                        .foregroundColor(.green)
                        .font(.headline)
                    
                    Button(action: { isPickerPresented = true }) {
                        Label("Select Activities to Restrict", systemImage: "app.badge")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white.opacity(0.2))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .familyActivityPicker(isPresented: $isPickerPresented, selection: $selection)
                    
                    if hasAnySelection || hasActiveRestrictions {
                        VStack(spacing: 15) {
                            if hasAnySelection {
                                Button(action: { shieldSelected() }) {
                                    Label("Apply Restrictions", systemImage: "lock.fill")
                                        .font(.headline)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.red.opacity(0.8))
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                }
                            }
                            
                            Button(action: { removeShields() }) {
                                Label("Remove Restrictions", systemImage: "lock.open.fill")
                                    .font(.headline)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.green.opacity(0.8))
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                        }
                        .transition(.opacity.combined(with: .slide))
                        .animation(.easeInOut, value: hasAnySelection || hasActiveRestrictions)
                    }
                } else {
                    Button(action: { Task { await requestAuthorization() } }) {
                        Label("Request Guardian Authorization", systemImage: "person.crop.circle.badge.checkmark")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.top, 10)
                }
            }
            .padding()
            .onAppear {
                loadRestrictionState()
            }
        }
    }
    
    // MARK: - Authorization
    func requestAuthorization() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            isAuthorized = true
            errorMessage = nil
        } catch {
            errorMessage = "Authorization Failed: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Apply Shields
    func shieldSelected() {
        let store = ManagedSettingsStore()
        store.shield.applications = selection.applicationTokens
        store.shield.applicationCategories = selection.categoryTokens.isEmpty ? nil : ShieldSettings.ActivityCategoryPolicy.specific(selection.categoryTokens)
        store.shield.webDomains = selection.webDomainTokens
        
        hasActiveRestrictions = true
        UserDefaults.standard.set(true, forKey: "hasActiveRestrictions")   // ✅ Persist
        errorMessage = nil
    }
    
    // MARK: - Remove Shields
    func removeShields() {
        let store = ManagedSettingsStore()
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil
        
        hasActiveRestrictions = false
        UserDefaults.standard.set(false, forKey: "hasActiveRestrictions")  // ✅ Persist
        errorMessage = nil
    }
    
    // MARK: - Load State
    func loadRestrictionState() {
        hasActiveRestrictions = UserDefaults.standard.bool(forKey: "hasActiveRestrictions")
    }
}

