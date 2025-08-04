//
//  HealthKitViewController.swift
//  AllCapabilitiesDemo
//
//  Created by Nihar Dudhat on 27/06/25.
//


import HealthKit
import SwiftUI

@available(iOS 16.0, *)
struct HealthSummaryView: View {
    @State private var steps: Double = 0
    @State private var heartRate: Double = 0
    @State private var energy: Double = 0
    @State private var distance: Double = 0
    @State private var selectedDate = Date()

    let manager = HealthKitManager()

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [.blue.opacity(0.6), .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()

                VStack(spacing: 24) {
                    DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .padding(.horizontal)
                        .background(.white.opacity(0.2))
                        .cornerRadius(10)
                        .colorMultiply(.white)

                    Button("Load Data") {
                        loadHealthData(for: selectedDate)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.green)
                    .cornerRadius(10)

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
        .onAppear {
            loadHealthData(for: selectedDate)
        }
    }

    func loadHealthData(for date: Date) {
        manager.requestAuthorization { _ in
            manager.fetch(.stepCount, unit: .count(), for: date) { self.steps = $0 }
            manager.fetch(.heartRate, unit: HKUnit.count().unitDivided(by: .minute()), for: date) { self.heartRate = $0 }
            manager.fetch(.activeEnergyBurned, unit: .kilocalorie(), for: date) { self.energy = $0 }
            manager.fetch(.distanceWalkingRunning, unit: .meterUnit(with: .kilo), for: date) { self.distance = $0 }
        }
    }

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

class HealthKitManager {
    let store = HKHealthStore()

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        let readTypes: Set = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!
        ]
        store.requestAuthorization(toShare: [], read: readTypes) { success, _ in
            completion(success)
        }
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
    } else {
        // Fallback on earlier versions
    }
}
