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
    let query = DataQuery()
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            today: Date(),
            contributions: query.mock(),
            configuration: ConfigurationIntent()
        )
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry =  SimpleEntry(
            date: Date(),
            today: Date(),
            contributions: query.mock(),
            configuration: ConfigurationIntent()
        )
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        query.fetch { result in
            if case .success(let success) = result {
                let currentDate = Date()
                let entryData = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
                let entry = SimpleEntry(
                    date: entryData,
                    today: Date(),
                    contributions: success,
                    configuration: configuration
                )
                entries.append(entry)
                let timeline = Timeline(entries: entries, policy: .atEnd)
                completion(timeline)
            }
        }
    }
}

// 代表某个时间下，渲染 widget 所需要的数据
struct SimpleEntry: TimelineEntry {
    // 更新时间
    let date: Date
    // 今天的日期
    let today: Date
    // 每个格子代表的日期
    let contributions: ContributionsData
    let configuration: ConfigurationIntent
}

// 渲染
struct contributions_widgetEntryView : View {
    
    @Environment(\.widgetFamily) var widgetFamily  // 环境变量
    @State var responseText: String = "Waiting for response..."
    
    var entry: Provider.Entry
    
    init(entry: Provider.Entry) {
        self.entry = entry
    }
   
    var body: some View {
        let gridSize = self.getGridItemSize()
        let weeks = self.getWeeks()
           VStack(spacing: 4) {
               ForEach(0..<7) { row in
                   HStack(spacing: 4) {
                       ForEach(weeks) { column in
                           
                           let day = column.contributionDays.safe(at: row)
                           
                           
                           if let safeDay = day {
                               let color = self.adjustColorBrightness(
                                number: safeDay.contributionCount,
                                color: UIColor.green)
                               RoundedRectangle(cornerRadius: 2)
                                   .fill(Color(color))
                                   .frame(width: gridSize, height: gridSize)
                               
                                   
                           } else {
                               RoundedRectangle(cornerRadius: 2)
                                   .fill(Color.green)
                                   .frame(width: gridSize, height: gridSize)
                           }
                       }
                   }
               }
           }
           .padding(2)
       }
    
    func getWeeks() -> [ContributionDay] {
        return self.entry.contributions.data.user.contributionsCollection.contributionCalendar.weeks
    }
    
    func getGridItemSize() -> CGFloat {
           let gridWidth = widgetFamily == .systemSmall ? 110.0 : 230.0
           let gridItemSize = (gridWidth - 20.0) / 21.0
           return gridItemSize
       }
    
    func adjustColorBrightness(number: Int, color: UIColor) -> UIColor {
        // 将数字映射到透明度范围（0.0 - 1.0）
        let alpha = CGFloat(number) / 100.0
        // 根据透明度创建新的颜色
        let newColor = color.withAlphaComponent(alpha)
        return newColor
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
            entry: SimpleEntry(
                date: Date(),
                today: Date(),
                contributions: DataQuery().mock(),
                configuration: ConfigurationIntent()
            )
        )
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}

extension Array {
    func safe (at index:Int) -> Element? {
        return (0..<count).contains(index) ? self[index] : nil
    }
}
