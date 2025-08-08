//
//  DemoWidget.swift
//  DemoWidget
//
//  Created by Nihar Dudhat on 31/07/25.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    
    let groupID = "group.com.allcaps"
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), text: "Placeholder Text")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), text: getSharedText())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let entry = SimpleEntry(date: Date(), text: getSharedText())
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
        completion(timeline)
    }

    private func getSharedText() -> String {
        if let sharedDefaults = UserDefaults(suiteName: groupID) {
            return sharedDefaults.string(forKey: "sharedText") ?? "No text set"
        }
        return "Failed to access shared defaults"
    }

//    func relevances() async -> WidgetRelevances<Void> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let text: String
}

struct DemoWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var widgetFamily // Correct key path syntax

    var body: some View {
        ZStack {
            // Modern blue-to-gray gradient background
            LinearGradient(
                gradient: Gradient(colors: [Color(#colorLiteral(red: 0.1, green: 0.3, blue: 0.6, alpha: 1)), Color(#colorLiteral(red: 0.9, green: 0.9, blue: 0.95, alpha: 1))]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            // Content
            switch widgetFamily {
            case .systemSmall:
                VStack(spacing: 8) {
                    Text("✍️ Shared Text:")
                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                        .foregroundColor(.white)
                    Text(entry.text)
                        .font(.system(.caption, design: .rounded, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                }
                .padding()
                .shadow(radius: 4, x: 2, y: 2)

            case .systemLarge:
                VStack(spacing: 12) {
                    Text("✍️ Shared Text:")
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .foregroundColor(.white)
                    Text(entry.text)
                        .font(.system(.headline, design: .rounded, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 12)
                    Text("Updated: \(entry.date, style: .time)")
                        .font(.system(.caption2, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.black.opacity(0.1))
                        .shadow(radius: 6, x: 3, y: 3)
                )
                .padding()

            case .systemExtraLarge:
                VStack(spacing: 16) {
                    Text("✍️ Shared Text")
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                        .foregroundColor(.white)
                    Text(entry.text)
                        .font(.system(.title, design: .rounded, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                    Text("Updated: \(entry.date, style: .date) \(entry.date, style: .time)")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.black.opacity(0.15))
                        .shadow(radius: 8, x: 4, y: 4)
                )
                .padding()

            default:
                Text("Unsupported Size")
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.white)
            }
        }
        .widgetBackground(Color.clear)
    }
}

struct DemoWidget: Widget {
    let kind: String = "DemoWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            DemoWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Demo Widget")
        .description("Displays text shared from the main app.")
        .supportedFamilies([.systemSmall, .systemLarge, .systemExtraLarge])
    }
    
}

struct DemoWidget_Previews: PreviewProvider {
    
    static var previews: some View {
        
        DemoWidgetEntryView(entry: SimpleEntry(date: Date(), text: "Preview Text"))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        
    }
}

extension View {
    func widgetBackground(_ backgroundView: some View) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            return containerBackground(for: .widget) {
                backgroundView
            }
        } else {
            return background(backgroundView)
        }
    }
}
