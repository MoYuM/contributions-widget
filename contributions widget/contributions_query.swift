//
//  contributions_query.swift
//  Github Contributions
//
//  Created by 韩宝昌 on 2023/6/17.
//

import Foundation

class DataQuery {
    
    let GITHUB_TOKEN = "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"
    
    // 设置 GraphQL 查询
    let graphQLQuery = """
       query($userName:String!) {
         user(login: $userName){
           contributionsCollection {
             contributionCalendar {
               totalContributions
               weeks {
                 contributionDays {
                   contributionCount
                   date
                 }
               }
             }
           }
         }
       }
    """
    
    let variables = """
        {
          "userName": "MoYuM"
        }
    """
    
    var cacheData: ContributionsData?
    
    func updateCache(newCache: ContributionsData) {
        self.cacheData = newCache
    }
    
    func fetch(completion: @escaping (Result<ContributionsData, Error>) -> Void) {
        
        var request = URLRequest(url: URL(string: "https://api.github.com/graphql")!)
        
        let graphQLRequestBody = [
            "query": graphQLQuery,
            "variables": variables,
        ]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: graphQLRequestBody, options: [])
        
        request.httpBody = jsonData
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(GITHUB_TOKEN)", forHTTPHeaderField: "Authorization")
        
        // 发送请求并解析响应数据
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            do {
                let decodedResponse = try JSONDecoder().decode(ContributionsData.self, from: data)
                self.updateCache(newCache: decodedResponse)
                completion(.success(decodedResponse))
            } catch {
                if let lastCacheData = self.cacheData {
                    completion(.success(lastCacheData))
                } else {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    func mock() -> ContributionsData {
        var total = 0
        
        func mockWeeks(inLast: Int = 21) -> [ContributionDay] {
            var weeks:[ContributionDay] = []
            for w in 0...inLast {
                var days: [ContributionCount] = []
                for d in 0...7 {
                    let count = Int.random(in: 0...100)
                    total += count
                    let mockDay = Calendar.current.date(byAdding: .weekOfYear, value: -Int(w), to: Date())!
                    let day = ContributionCount(contributionCount: count, date: mockDay.formatted())
                    days.append(day)
                }
                weeks.append(ContributionDay(contributionDays: days))
            }
            return weeks
        }
        
        let mockData = ContributionsData(
            data: DataClass(
                user: User(
                    contributionsCollection: ContributionsCollection(
                        contributionCalendar: ContributionCalendar(
                            totalContributions: total,
                            weeks: mockWeeks()
                        )))))
        return mockData
    }
}
