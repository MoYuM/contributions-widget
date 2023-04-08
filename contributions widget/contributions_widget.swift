//
//  contributions_widget.swift
//  contributions widget
//
//  Created by 韩宝昌 on 2023/4/2.
//

import WidgetKit
import SwiftUI
import Intents

// 提供一系列供 widgetKit 使用的方法
// placeholder: 在没有内容的时候，显示的东西
// getSnapshot: 提供这个 widget 在小组件库中的预览样式
// getTimeline:
// widgetKit 按照 timeline 的策略去更新 widget，
// getTimeline 就是提供这个 timeline 的方法，timeline 是包含了一系列 timelineEntry 的数组，
// 每个 timelineEntry 代表了某个时间下，渲染 widget 所需要的数据。
struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            today: Date(),
            gridItemsDate: [[Date()]],
            configuration: ConfigurationIntent()
        )
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry =  SimpleEntry(
            date: Date(),
            today: Date(),
            gridItemsDate: [[Date()]],
            configuration: ConfigurationIntent()
        )
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(
                date: entryDate,
                today: Date(),
                gridItemsDate: [[Date()]],
                configuration: configuration
            )
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

// 代表某个时间下，渲染 widget 所需要的数据
struct SimpleEntry: TimelineEntry {
    // 更新时间
    let date: Date
    // 今天的日期
    let today: Date
    // 每个格子代表的日期
    let gridItemsDate: [[Date]]
    let configuration: ConfigurationIntent
}

// 渲染
struct contributions_widgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var widgetFamily  // 环境变量
   
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

// 主入口
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
        contributions_widgetEntryView(
            entry: SimpleEntry(date: Date(),
            configuration: ConfigurationIntent())
        )
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
