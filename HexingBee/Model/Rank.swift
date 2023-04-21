//
//  Rank.swift
//

import Foundation

enum Rank: Int, CaseIterable, RawRepresentable {
    case beginner
    case good_start
    case moving_up
    case good
    case solid
    case nice
    case great
    case amazing
    case genius
    case queen_bee

    func getTarget(maxScore: Int) -> Int {
        // Each rank score is done by a fixed percentage of the total possible score
        let multipliers = [0, 0.02, 0.05, 0.08, 0.15, 0.25, 0.40, 0.50, 0.70, 1.0]
        return Int(round(multipliers[rawValue] * Double(maxScore)))
    }

    func string() -> String {
        switch(self) {
        case .beginner: return "Beginner"
        case .good_start: return "Good Start"
        case .moving_up: return "Moving Up"
        case .good: return "Good"
        case .solid: return "Solid"
        case .nice: return "Nice"
        case .great: return "Great"
        case .amazing: return "Amazing"
        case .genius: return "Genius"
        case .queen_bee: return "Queen Bee"
        }
    }
}
