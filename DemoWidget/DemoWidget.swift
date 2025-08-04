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
        switch widgetFamily {
        case .systemSmall:
            VStack {
                Text("Shared Text:")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                Text(entry.text)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
            }
            .padding()
        case .systemLarge:
            VStack {
                Text("Shared Text:")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                Text(entry.text)
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .padding()
                Text("Updated: \(entry.date, style: .time)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
        case .systemExtraLarge:
            VStack {
                Text("Shared Text:")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                Text(entry.text)
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding()
                Text("Updated: \(entry.date, style: .date) \(entry.date, style: .time)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
        default:
            Text("Unsupported Size")
        }
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
