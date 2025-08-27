//
//  AgeAnalysisController.swift
//  zt
//
//  Created by Nihal Akgül on 25.08.2025.
//

import Foundation

@MainActor
final class AgeAnalysisController: ObservableObject {
    @Published var birthDate: Date { didSet { recompute() } }
    @Published private(set) var score: AgeScore = .init(ageYears: 0, delta: 0, hardStop: false, label: "—")
    @Published private(set) var colorToken: AgeColorToken = .neutral

    enum AgeColorToken { case yellow, green, neutral }

    private let nowProvider: () -> Date   // test/preview için

    init(birthDate: Date, now: @escaping () -> Date = { Date() }) {
        self.birthDate = birthDate
        self.nowProvider = now
        recompute()
    }

    func recompute() {
        let s = AgeScorer.score(birthDate: birthDate, now: nowProvider())
        self.score = s
        self.colorToken = color(for: s.ageYears)
    }

    private func color(for years: Int) -> AgeColorToken {
        if years <= 24 { return .yellow }
        if years <= 65 { return .green }
        return .yellow
    }
}
