//
//  ContributionsData.swift
//  Github Contributions
//
//  Created by 韩宝昌 on 2023/6/17.
//

import Foundation

// 响应数据的结构体
struct ContributionCount: Codable {
    let contributionCount: Int
    let date: String
}

struct ContributionDay: Codable, Identifiable {
    let id: UUID
    let contributionDays: [ContributionCount]
    
    init(contributionDays: [ContributionCount]) {
        self.id = UUID()
        self.contributionDays = contributionDays
    }
}

struct ContributionCalendar: Codable {
    let totalContributions: Int
    let weeks: [ContributionDay]
}

struct ContributionsCollection: Codable {
    let contributionCalendar: ContributionCalendar
}

struct User: Codable {
    let contributionsCollection: ContributionsCollection
}

struct DataClass: Codable {
    let user: User
}

public struct ContributionsData: Codable {
    let data: DataClass
}
