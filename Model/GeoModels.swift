//
//  GeoModels.swift
//  zt
//
//  Created by Nihal Akgül on 25.08.2025.
//

import Foundation

// MARK: - Travel Advisory (API model)
public struct TravelAdvisory: Decodable {
    public let countryCode: String?
    public let countryName: String?
    public let advisoryLevel: Int?
    public let publishedAt: Date?

    enum CodingKeys: String, CodingKey {
        case CountryCode, CountryName, AdvisoryLevel, Date, Published, PublishedDate, Level, ISO2
        case countryCode, countryName, advisoryLevel, publishedAt, iso2
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)

        // --- Ülke kodu (parçalara böl)
        let code1 = try? c.decodeIfPresent(String.self, forKey: .CountryCode)
        let code2 = try? c.decodeIfPresent(String.self, forKey: .iso2)
        let code3 = try? c.decodeIfPresent(String.self, forKey: .ISO2)
        let code4 = try? c.decodeIfPresent(String.self, forKey: .countryCode)
        self.countryCode = code1 ?? code2 ?? code3 ?? code4

        // --- Ülke adı
        let name1 = try? c.decodeIfPresent(String.self, forKey: .CountryName)
        let name2 = try? c.decodeIfPresent(String.self, forKey: .countryName)
        self.countryName = name1 ?? name2

        // --- Seviye (1..4) hem Int hem String gelebilir
        if let lvlInt = try? c.decode(Int.self, forKey: .AdvisoryLevel) {
            self.advisoryLevel = lvlInt
        } else if let lvlInt = try? c.decode(Int.self, forKey: .Level) {
            self.advisoryLevel = lvlInt
        } else if let lvlStr = try? c.decode(String.self, forKey: .AdvisoryLevel),
                  let val = Int(lvlStr) {
            self.advisoryLevel = val
        } else if let lvlStr = try? c.decode(String.self, forKey: .Level),
                  let val = Int(lvlStr) {
            self.advisoryLevel = val
        } else {
            self.advisoryLevel = nil
        }

        // --- Tarih (ISO8601 benzeri birkaç alandan biri)
        let dateStrA = try? c.decodeIfPresent(String.self, forKey: .Date)
        let dateStrB = try? c.decodeIfPresent(String.self, forKey: .Published)
        let dateStrC = try? c.decodeIfPresent(String.self, forKey: .PublishedDate)
        let dateStr = dateStrA ?? dateStrB ?? dateStrC

        if let ds = dateStr {
            let iso = ISO8601DateFormatter()
            if let d = iso.date(from: ds) {
                self.publishedAt = d
            } else {
                // Bazı feed'ler ISO değilse basit bir fallback
                let f = DateFormatter()
                f.locale = Locale(identifier: "en_US_POSIX")
                f.timeZone = TimeZone(secondsFromGMT: 0)
                f.dateFormat = "yyyy-MM-dd"
                self.publishedAt = f.date(from: ds)
            }
        } else {
            self.publishedAt = nil
        }
    }
}

// MARK: - Puanlama politikası (senin kuralların)
public enum GeoScorePolicy {
    public static func residenceDelta(for level: Int?) -> Int {
        switch level {
        case 4: return -15      // Do Not Travel
        case 3: return -10      // Reconsider Travel
        default: return 0       // 1-2 => nötr / bilinmiyor
        }
    }
    public static func nationalityDelta(for level: Int?) -> Int {
        switch level {
        case 4: return -10
        case 3: return -5
        default: return 0
        }
    }
    public static let mismatchCrimeDelta = -5
    public static let mismatchNonCrimeDelta = 0
}

// Basit "suç/illegal" gerekçe yakalayıcı (MVP)
public enum CrimeReasonDetector {
    static let keywords: [String] = [
        "suç","illegal","kaçak","yasal değil","sabıka","aranıyorum","kaçıyorum","kaçakçılık","uyuşturucu","hırsızlık"
    ]
    public static func isCrimeReason(_ text: String?) -> Bool {
        guard let t = text?.lowercased(),
              !t.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        return keywords.contains { t.contains($0) }
    }
}

// MARK: - Geo sonucu (Controller View'a bunu verir)
public struct GeoDeltaItem: Identifiable {
    public let id = UUID()
    public let title: String
    public let delta: Int
}

public struct GeoResult {
    public let residenceLevel: Int?
    public let nationalityLevel: Int?
    public let deltas: [GeoDeltaItem]
    public var total: Int { deltas.reduce(0) { $0 + $1.delta } }

    public enum Color { case red, yellow, green, neutral }
    public var color: Color {
        if (residenceLevel ?? 0) >= 4 && (nationalityLevel ?? 0) >= 4 { return .red }
        if total < 0 { return .yellow }
        return .green
    }
}

