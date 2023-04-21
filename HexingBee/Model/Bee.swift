//
//  Bee.swift
//

import Foundation

struct Bees: Codable {
    let today, yesterday: Bee
}

struct Bee: Codable {
    let expiration: Int?
    let displayWeekday, displayDate, printDate, centerLetter: String
    let outerLetters, validLetters, pangrams, answers: [String]
    let id, freeExpiration: Int
    let editor: String
}
