//
//  SpellingViewModel.swift
//
//  All the game logic lives here
//

import Foundation
import Combine
import Factory

class HexingBeeViewModel {

    @Injected(Container.spellinBeAPI)
    private var HexingBeeAPI: HexingBeeAPI

    @PublishedOnMain
    private(set) var foundWords = Set<String>()

    @PublishedOnMain
    private(set) var bee: Bee? = nil

    @PublishedOnMain
    private(set) var validLetters = Set<Character>()

    // Publish a congratulatory message every time a valid word is provided
    let congrats = PassthroughSubject<(message: String, delta: Int), Never>()

    @PublishedOnMain
    private(set) var errorMessage: String?

    @PublishedOnMain
    private(set) var score: Int = 0

    @PublishedOnMain
    private(set) var rank: Rank = .beginner

    private var ranks: [Int] = []

    init() {
        Task {
            bee = try await HexingBeeAPI.fetchBee()
            if let bee = bee {
                validLetters = Set<Character>(bee.validLetters.map { $0.first! })

                let maxScore = bee.answers.reduce(0, { score, word in
                    score + self.calculateScore(for: word)
                })
                
                print("maxScore: \(maxScore)")

                for rank in Rank.allCases {
                    ranks.append(rank.getTarget(maxScore: maxScore))
                }
                print(ranks)
            }
        }
    }

    func resetGame() {
        rank = .beginner
        score = 0
        foundWords.removeAll()
    }

    func validateWord(_ word: String) -> Bool {
        guard let bee = bee else {
            return false
        }
        let wordMap = Set<Character>(word.map { $0 })
        if word.count < 4 {
            errorMessage = "word too short"
            return false
        }
        if foundWords.contains(word) {
            errorMessage = "word already found"
            return false
        }
        let invalids = wordMap.subtracting(validLetters)
        if invalids.count > 0 {
            errorMessage = "invalid letters: \(invalids)"
            return false
        }
        if word.firstIndex(of: bee.centerLetter.first!) == nil {
            errorMessage = "missing center letter"
            return false
        }
        if bee.answers.firstIndex(of: word) == nil {
            errorMessage = "invalid word"
            return false
        }
        errorMessage = nil
        return true
    }

    func calculateScore(for word: String) -> Int {
        var result = 0

        switch word.count {
        case 4:
            result += 1
        case 4...:
            result += word.count
        default: break
        }

        let uniqueLetters = word.reduce(NSMutableSet()) { letterSet, letter in
            letterSet.add(letter)
            return letterSet
        }

        if uniqueLetters.count == 7 {
            result += 7
        }

        return result
    }

    func add(word: String) {
        guard rank != .queen_bee else {
            return
        }

        if validateWord(word) {
            foundWords.insert(word)

            let delta = calculateScore(for: word)
            score += delta

            let message =  bee?.pangrams.contains(word) ?? false ?
            "Pangram!" : "Good job!"
            congrats.send((message: message, delta: delta))

            if score == ranks.last {
                rank = .queen_bee
                return
            }

            for i in stride(from: Rank.genius.rawValue, through: rank.rawValue+1, by: -1) {

                if score > ranks[i] {
                    rank = Rank(rawValue: i) ?? rank
                    break
                }
            }
        }
    }

}
