//
//  AdvisoryModels.swift
//  zt
//
//  Created by Nihal Akgül on 26.08.2025.
//

import Foundation

/// CA Data list (feed) endpoint’i için ÇAKIŞMASIZ model.
/// (Önceden `AdvisoryPost` ismi başka bir yerde tanımlıydı.)
struct AdvisoryFeedPost: Decodable {
    let title: String
    let link: String
    let category: [String]?   // GEC/FIPS kodları: ["TU"], ["MX"], ...
    let summary: String?      // HTML olabilir
    let id: String
    let published: Date
    let updated: Date

    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case link  = "Link"
        case category = "Category"
        case summary = "Summary"
        case id     = "id"
        case published = "Published"
        case updated   = "Updated"
    }
}

/// CA feed tarihleri için toleranslı ISO8601 decoder (ÇAKIŞMASIZ isim).
func makeFeedISO8601Decoder() -> JSONDecoder {
    let dec = JSONDecoder()
    let fmt = ISO8601DateFormatter()
    fmt.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

    dec.dateDecodingStrategy = .custom { decoder in
        let c = try decoder.singleValueContainer()
        let s = try c.decode(String.self)

        if let d = fmt.date(from: s) { return d }

        // Fallback: fractional seconds yok
        let fallback = ISO8601DateFormatter()
        fallback.formatOptions = [.withInternetDateTime]
        if let d2 = fallback.date(from: s) { return d2 }

        throw DecodingError.dataCorruptedError(in: c, debugDescription: "Bad ISO8601 date: \(s)")
    }
    return dec
}

