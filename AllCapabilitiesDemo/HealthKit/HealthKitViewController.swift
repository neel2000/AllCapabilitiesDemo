//
//  HealthKitViewController.swift
//  AllCapabilitiesDemo
//
//  Created by Nihar Dudhat on 27/06/25.
//


import SwiftUI
import Combine
import HealthKit

@available(iOS 16.0, *)
struct HealthSummaryView: View {
    
    @State private var steps: Double = 0
    @State private var heartRate: Double = 0
    @State private var energy: Double = 0
    @State private var distance: Double = 0
    @State private var selectedDate = Date()
    @StateObject private var manager = HealthKitManager()

    var body: some View {
        NavigationStack {
            ScrollView {
                ZStack {
                    LinearGradient(colors: [.blue.opacity(0.6), .purple],
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                    
                    VStack(spacing: 24) {
                        
                        // MARK: - Date Picker
                        DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .padding(.horizontal)
                            .background(.white.opacity(0.2))
                            .cornerRadius(10)
                            .colorMultiply(.white)
                        
                        // MARK: - Load Data Button
                        Button("Load Data") {
                            loadHealthData(for: selectedDate)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.green)
                        .cornerRadius(10)
                        
                        // MARK: - Save Workout Button
                        Button("Save Running Workout") {
                            //saveRunningWorkout(distance: 1000, // Convert km -> m
//                                               duration: 1200, // 15 mins example
//                                               energy: 0.52)
                            saveRunningWorkout(distance: distance * 1000, // Convert km -> m
                                               duration: 900, // 15 mins example
                                               energy: energy)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.orange)
                        .cornerRadius(10)
                        
                        // MARK: - Health Cards
                        healthCard(title: "👣 Steps", value: "\(Int(steps))", unit: "steps", color: .green)
                        healthCard(title: "❤️ Heart Rate", value: String(format: "%.0f", heartRate), unit: "BPM", color: .red)
                        healthCard(title: "🔥 Energy", value: String(format: "%.2f", energy), unit: "kcal", color: .orange)
                        healthCard(title: "📏 Distance", value: String(format: "%.2f", distance), unit: "km", color: .teal)
                        
                        Spacer()
                    }
                    .padding(.top, 22)
                    .padding()
                }
            }
            .background(
                LinearGradient(colors: [.blue.opacity(0.6), .purple],
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                .ignoresSafeArea()
            )
        }
        .onAppear {
            manager.requestAuthorization { _ in
                loadHealthData(for: selectedDate)
                manager.startObserving()
            }
        }
        // Listen for real-time HealthKit changes
        .onReceive(manager.stepsPublisher) { _ in loadHealthData(for: selectedDate) }
        .onReceive(manager.heartRatePublisher) { _ in loadHealthData(for: selectedDate) }
        .onReceive(manager.energyPublisher) { _ in loadHealthData(for: selectedDate) }
        .onReceive(manager.distancePublisher) { _ in loadHealthData(for: selectedDate) }
    }

    // MARK: - Load Health Data
    func loadHealthData(for date: Date) {
        manager.fetch(.stepCount, unit: .count(), for: date) { self.steps = $0 }
        manager.fetch(.heartRate, unit: HKUnit.count().unitDivided(by: .minute()), for: date) { self.heartRate = $0 }
        manager.fetch(.activeEnergyBurned, unit: .kilocalorie(), for: date) { self.energy = $0 }
        manager.fetch(.distanceWalkingRunning, unit: HKUnit.meterUnit(with: .kilo), for: date) { self.distance = $0 }
    }
    
    // MARK: - Save Workout
    func saveRunningWorkout(distance: Double, duration: TimeInterval, energy: Double) {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        let healthStore = HKHealthStore()
        let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        let workoutType = HKWorkoutActivityType.running

        let startDate = Date()
        let endDate = startDate.addingTimeInterval(duration)

        let distanceQuantity = HKQuantity(unit: HKUnit.meter(), doubleValue: distance)
        let energyQuantity = HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: energy)

        let workout = HKWorkout(activityType: workoutType,
                                start: startDate,
                                end: endDate,
                                workoutEvents: nil,
                                totalEnergyBurned: energyQuantity,
                                totalDistance: distanceQuantity,
                                metadata: nil)

        healthStore.save(workout) { success, error in
            if success {
                print("✅ Workout saved for recalibration use")
            } else {
                print("❌ Error saving workout:", error?.localizedDescription ?? "Unknown error")
            }
        }
    }

    // MARK: - UI Card
    func healthCard(title: String, value: String, unit: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            
            Text(value)
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(color)
            
            Text(unit)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.2), radius: 10)
    }
}

// MARK: - HealthKit Manager Class
class HealthKitManager: ObservableObject {
    let store = HKHealthStore()
    var stepsPublisher = PassthroughSubject<Void, Never>()
    var heartRatePublisher = PassthroughSubject<Void, Never>()
    var energyPublisher = PassthroughSubject<Void, Never>()
    var distancePublisher = PassthroughSubject<Void, Never>()
    private var observersAdded = false

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        let readTypes: Set = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.workoutType()
        ]
        store.requestAuthorization(toShare: [HKObjectType.workoutType()], read: readTypes) { success, _ in
            completion(success)
        }
    }

    func startObserving() {
        guard !observersAdded else { return }
        observe(.stepCount, publisher: stepsPublisher)
        observe(.heartRate, publisher: heartRatePublisher)
        observe(.activeEnergyBurned, publisher: energyPublisher)
        observe(.distanceWalkingRunning, publisher: distancePublisher)
        observersAdded = true
        enableBackgroundDelivery(for: .stepCount)
        enableBackgroundDelivery(for: .heartRate)
        enableBackgroundDelivery(for: .activeEnergyBurned)
        enableBackgroundDelivery(for: .distanceWalkingRunning)
    }

    private func observe(_ type: HKQuantityTypeIdentifier, publisher: PassthroughSubject<Void, Never>) {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: type) else { return }
        let query = HKObserverQuery(sampleType: quantityType, predicate: nil) { _, _, error in
            if error == nil {
                DispatchQueue.main.async {
                    publisher.send()
                }
            }
        }
        store.execute(query)
    }

    private func enableBackgroundDelivery(for type: HKQuantityTypeIdentifier) {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: type) else { return }
        store.enableBackgroundDelivery(for: quantityType, frequency: .immediate) { _, _ in }
    }

    func fetch(_ type: HKQuantityTypeIdentifier, unit: HKUnit, for date: Date, completion: @escaping (Double) -> Void) {
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: type) else { return }
        let start = Calendar.current.startOfDay(for: date)
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start)!
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        let option: HKStatisticsOptions = (type == .heartRate) ? .discreteAverage : .cumulativeSum
        let query = HKStatisticsQuery(quantityType: quantityType, quantitySamplePredicate: predicate, options: option) { _, result, _ in
            var value: Double = 0
            if type == .heartRate {
                value = result?.averageQuantity()?.doubleValue(for: unit) ?? 0
            } else {
                value = result?.sumQuantity()?.doubleValue(for: unit) ?? 0
            }
            completion(value)
        }
        store.execute(query)
    }
}

#Preview {
    if #available(iOS 16.0, *) {
        HealthSummaryView()
    }
}
