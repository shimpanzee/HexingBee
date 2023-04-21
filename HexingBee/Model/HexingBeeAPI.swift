//
//  HexingBeeAPI.swift
//
//  API to pull today's puzzle
//

import Foundation

class HexingBeeAPI {
    func fetchBee() async throws -> Bee {
        let url = URL(string: "https://www.nytimes.com/puzzles/spelling-bee")!
        let urlRequest = URLRequest(url: url)
        let (data, _) = try await URLSession.shared.data(for : urlRequest)

        // Json data is embedded in page.  Scrape it out
        let str = String(data: data, encoding: String.Encoding.utf8)!
        let range = str.range(of: "window.gameData = ")!
        let idx = range.upperBound
        let substr = str[idx...]

        var depth = 0
        var charCount = 0

        // print(substr)
        for c in substr {
            charCount += 1
            if c == "{" {
                depth += 1
                continue
            } else if c == "}" {
                depth -= 1
                if depth == 0 {
                    break
                }
            }
        }
        
        let jsonStr = str[idx..<(str.index(idx, offsetBy: charCount))]

        let bees: Bees = try JSONDecoder().decode(Bees.self, from: jsonStr.data(using: .utf8)!)

        return bees.today
    }
}
