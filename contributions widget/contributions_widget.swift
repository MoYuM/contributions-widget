//
//  contributions_widget.swift
//  contributions widget
//
//  Created by 韩宝昌 on 2023/4/2.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
}

struct contributions_widgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var widgetFamily
   
    var body: some View {
        let gridSize = self.getGridItemSize()
        
           VStack(spacing: 4) {
               ForEach(0..<7) { row in
                   HStack(spacing: 4) {
                       ForEach(0..<21) { column in
                           RoundedRectangle(cornerRadius: 2)
                               .fill(Color.red)
                               .frame(width: gridSize, height: gridSize)
                       }
                   }
               }
           }
           .padding(2)
       }
    
    
    func getGridItemSize() -> CGFloat {
           let gridWidth = widgetFamily == .systemSmall ? 110.0 : 230.0
           let gridItemSize = (gridWidth - 20.0) / 21.0
           return gridItemSize
       }
}

struct contributions_widget: Widget {
    let kind: String = "contributions_widget"

    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: ConfigurationIntent.self,
            provider: Provider()
        ) { entry in
            contributions_widgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([.systemLarge, .systemMedium, .systemSmall])
    }
    
    
}

struct contributions_widget_Previews: PreviewProvider {
    static var previews: some View {
        contributions_widgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
