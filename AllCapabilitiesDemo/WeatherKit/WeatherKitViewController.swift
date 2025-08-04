//
//  WeatherKitViewController.swift
//  AllCapabilitiesDemo
//
//  Created by Nihar Dudhat on 26/06/25.
//

import UIKit
import CoreLocation
import WeatherKit
import SwiftUI

import SwiftUI
import WeatherKit

@available(iOS 16.0, *)
struct WeatherView: View {
    @StateObject private var viewModel = WeatherViewModel()

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient (colors: [.blue.opacity(0.7), .indigo]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 28) {
                    if let weather = viewModel.weather {
                        VStack(spacing: 8) {
                            Text("🌤 Weather Now")
                                .font(.largeTitle.weight(.bold))
                                .foregroundColor(.white)

                            Text(weather.currentWeather.date.formatted(date: .abbreviated, time: .shortened))
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }

                        VStack(spacing: 16) {
                            Image(systemName: weather.currentWeather.symbolName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(.white, .yellow)

                            Text(weather.currentWeather.temperature.formatted(.measurement(width: .abbreviated)))
                                .font(.system(size: 45, weight: .bold))
                                .foregroundColor(.white)

                            Text(weather.currentWeather.condition.description)
                                .font(.title3)
                                .foregroundColor(.white)

                            Text("💨 Wind: \(weather.currentWeather.wind.speed.formatted(.measurement(width: .abbreviated)))")
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(25)
                        .shadow(radius: 10)
                        .padding(.horizontal)

                        // Hourly
                        VStack(alignment: .leading, spacing: 16) {
                            Text("🕒 Hourly Forecast")
                                .font(.title3.bold())
                                .foregroundColor(.white)
                                .padding(.leading)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(weather.hourlyForecast.forecast.prefix(6), id: \.date) { hour in
                                        VStack(spacing: 6) {
                                            Text(hour.date.formatted(date: .omitted, time: .shortened))
                                                .font(.caption2)
                                            Image(systemName: hour.symbolName)
                                                .symbolRenderingMode(.palette)
                                                .foregroundStyle(.white, .blue)
                                            Text(hour.temperature.formatted(.measurement(width: .abbreviated)))
                                        }
                                        .foregroundColor(.white)
                                        .padding(12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 15)
                                                .fill(Color.white.opacity(0.15))
                                                .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 4)
                                        )
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }

                        // Daily
                        VStack(alignment: .leading, spacing: 12) {
                            Text("📅 Daily Forecast")
                                .font(.title3.bold())
                                .foregroundColor(.white)
                                .padding(.leading)

                            ForEach(weather.dailyForecast.forecast.prefix(5), id: \.date) { day in
                                HStack {
                                    Text(day.date.formatted(date: .abbreviated, time: .omitted))
                                        .frame(width: 100, alignment: .leading)
                                    Image(systemName: day.symbolName)
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text(day.highTemperature.formatted(.measurement(width: .abbreviated)))
                                        .foregroundColor(.white)
                                    Text("↓" + day.lowTemperature.formatted(.measurement(width: .abbreviated)))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white.opacity(0.1))
                                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 4)
                                )
                            }
                        }
                        .padding(.horizontal)

                    } else if let error = viewModel.error {
                        Text("❌ Error: \(error.localizedDescription)")
                            .foregroundColor(.red)
                            .padding()
                    } else {
                        ProgressView("Loading weather...")
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .padding()
                    }
                }
                .padding(.top)
            }
        }
        .onAppear {
            viewModel.requestLocationAndFetchWeather()
        }
    }
}


@available(iOS 16.0, *)
class WeatherKitViewController: UIViewController {
    
    let locationManager = LocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.locationHandler = { [weak self] location in
            Task {
                await self?.fetchWeather(for: location)
            }
        }
    }
    
    func fetchWeather(for location: CLLocation) async {
        let service = WeatherService()
        do {
            let weather = try await service.weather(for: location)
            print("Current temperature: \(weather.currentWeather.temperature.description)")
            print("Conditions: \(weather.currentWeather.condition.description)")
        } catch {
            print("Failed to fetch weather: \(error)")
        }
    }
    
    
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    private let manager = CLLocationManager()
    var locationHandler: ((CLLocation) -> Void)?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            manager.stopUpdatingLocation()
            locationHandler?(location)
        }
    }
}

@available(iOS 16.0, *)
class WeatherViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var weather: Weather?
    @Published var error: Error?

    private let locationManager = CLLocationManager()
    private let weatherService = WeatherService()

    override init() {
        super.init()
        locationManager.delegate = self
    }

    func requestLocationAndFetchWeather() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        manager.stopUpdatingLocation()

        Task {
            do {
                let fullWeather = try await weatherService.weather(for: location)
                await MainActor.run {
                    self.weather = fullWeather
                }
            } catch {
                await MainActor.run {
                    self.error = error
                }
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.error = error
    }
}
