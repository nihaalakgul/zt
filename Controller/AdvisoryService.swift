//
//  AdvisoryService.swift
//  zt
//
//  Created by Nihal Akgül on 26.08.2025.
//

import Foundation

public struct AdvisoryService {
    public init() {}

    // TODO: kendi endpoint'ini koy
    private let allURL = URL(string: "https://cadataapi.state.gov/api/TravelAdvisories.json")!

    /// Tüm advisories JSON'unu indirir ve parse eder.
    public func fetchAll() async throws -> [AdvisoryPost] {
        let (data, resp) = try await URLSession.shared.data(from: allURL)
        guard (resp as? HTTPURLResponse)?.statusCode == 200 else { return [] }
        return try makeISO8601Decoder().decode([AdvisoryPost].self, from: data)
    }

    /// Tek ülkeye göre advisory bulur: input (ülke/uyruk/kod) -> ISO2 -> GEC->ISO eşleşmesi
    public func findAdvisory(
        for input: String,
        in posts: [AdvisoryPost],
        countryCodeResolver: (String) -> String? = CountryResolver.iso2
    ) -> AdvisoryPost? {
        guard let targetISO2 = countryCodeResolver(input)?.uppercased() else { return nil }
        return posts.first { post in
            let isoList = mapGECtoISO2(post.category.map { $0.uppercased() })
            return isoList.contains(targetISO2)
        }
    }
}
