//
//  AgeScorer.swift
//  zt
//
//  Created by Nihal Akgül on 25.08.2025.
//



import Foundation

public struct AgeScore: Equatable {
    public let ageYears: Int
    public let delta: Int         // <18 için -9999 (hard-stop)
    public let hardStop: Bool
    public let label: String      // "Yaş < 18" | "Yaş 18–24" | "Yaş 25–65" | "Yaş > 65"
}

public enum AgeScorer {
    /// Doğum gününü dikkate alarak yıl cinsinden yaş hesaplar.
    public static func computeAgeYears(from birthDate: Date, now: Date = Date(), calendar: Calendar = .current) -> Int {
        let comps = calendar.dateComponents([.year], from: birthDate, to: now)
        return max(0, comps.year ?? 0)
    }

    /// <18 -> HARD-STOP, 18–24 -> -8, 25–65 -> 0, >65 -> -5
    public static func score(birthDate: Date, now: Date = Date()) -> AgeScore {
        let years = computeAgeYears(from: birthDate, now: now)
        if years <= 24 { return .init(ageYears: years, delta: -8,    hardStop: false, label: "Yaş 18–24") }
        if years <= 65 { return .init(ageYears: years, delta: 0,     hardStop: false, label: "Yaş 25–65") }
        return .init(ageYears: years, delta: -5, hardStop: false, label: "Yaş > 65")
    }
}

