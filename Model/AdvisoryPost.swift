//
//  AdvisoryPost.swift
//  zt
//
//  Created by Nihal Akgül on 26.08.2025.
//
import Foundation

public struct AdvisoryPost : Decodable {
    public let title: String
    public let link: String
    public let category: [String]   // GEC/FIPS kodları: ["TU"], ["MX"]...
    public let summary: String      // HTML
    public let id: String
    public let published: Date
    public let updated: Date

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

public func makeISO8601Decoder() -> JSONDecoder {
    let dec = JSONDecoder()
    let fmt = ISO8601DateFormatter()
    fmt.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    dec.dateDecodingStrategy = .custom { decoder in
        let c = try decoder.singleValueContainer()
        let s = try c.decode(String.self)
        if let d = fmt.date(from: s) { return d }
        let fallback = ISO8601DateFormatter()
        fallback.formatOptions = [.withInternetDateTime]
        if let d2 = fallback.date(from: s) { return d2 }
        throw DecodingError.dataCorruptedError(in: c, debugDescription: "Bad ISO8601 date: \(s)")
    }
    return dec
}

