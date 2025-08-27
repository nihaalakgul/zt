//
//  GeoAnalysisController.swift
//  zt
//
//  Created by Nihal Akgül on 25.08.2025.
//

import Foundation

@MainActor
final class GeoAnalysisController: ObservableObject {
    // INPUTS
    @Published var nationality: String
    @Published var residenceCountry: String
    @Published var mismatchJustification: String?

    // OUTPUTS (UI)
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var result: GeoRiskResult?

    // Geo mismatch (uyruk ≠ ikamet)
    @Published private(set) var geoMismatchDelta: Int = 0
    @Published private(set) var hasGeoMismatch: Bool = false

    // DEBUG
    private let debugMode: Bool

    // Riskli anahtar kelimeler (mismatch gerekçesi için)
    private let riskyKeywords: [String] = [
        "suç", "ihlal", "gasp", "illegal", "kaçak", "yasal değil", "sabıka",
        "aranıyorum", "kaçıyorum", "kaçakçılık", "uyuşturucu", "hırsızlık"
    ]

    init(
        nationality: String,
        residenceCountry: String,
        mismatchJustification: String?,
        debugMode: Bool = true
    ) {
        self.nationality = nationality.uppercased()
        self.residenceCountry = residenceCountry.uppercased()
        self.mismatchJustification = mismatchJustification
        self.debugMode = debugMode
        recomputeGeoMismatch()
    }

    /// Ana hesap: ülke seviyelerini basit politika ile puanla ve toplam skoru üret.
    func run() async {
        guard !nationality.isEmpty, !residenceCountry.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        // (Gerekirse burada gerçek API çağrısı yapılır. Şimdilik senkron politika.)
        let natLevel = levelForCountryCode(nationality)
        let resLevel = levelForCountryCode(residenceCountry)

        let natDelta = deltaForLevel(natLevel, isNationality: true)
        let resDelta = deltaForLevel(resLevel, isNationality: false)

        var deltas: [GeoRiskDelta] = [
            .init(id: UUID(), title: "Uyruk riski (Level \(natLevel))", delta: natDelta),
            .init(id: UUID(), title: "İkamet riski (Level \(resLevel))", delta: resDelta),
            .init(id: UUID(), title: nationality == residenceCountry ? "Uyruk = İkamet" : "Uyruk ≠ İkamet", delta: geoMismatchDelta)
        ]

        let total = deltas.reduce(0) { $0 + $1.delta }
        let color: GeoRiskResult.Color = {
            if total <= -10 { return .red }
            if total <= -2  { return .yellow }
            if total >= 5   { return .green }
            return .neutral
        }()

        self.result = GeoRiskResult(
            deltas: deltas,
            total: total,
            color: color,
            nationalityLevel: natLevel,
            residenceLevel: resLevel
        )
    }

    /// Uyruk–ikamet uyuşmazlığı puanlaması

    private func normalizeISO2(_ s: String) -> String {
        // Boşlukları temizle + büyük harfe çevir
        let raw = s.trimmingCharacters(in: .whitespacesAndNewlines)
        // Elinde CountryResolver.iso2(from:) varsa onu kullan
        let iso = CountryResolver.iso2(from: raw) ?? raw
        return iso.uppercased()
    }

    func recomputeGeoMismatch() {
        let n = normalizeISO2(nationality)
        let r = normalizeISO2(residenceCountry)

        hasGeoMismatch = !n.isEmpty && !r.isEmpty && n != r
        guard hasGeoMismatch else { geoMismatchDelta = 0; return }

        let text = (mismatchJustification ?? "").lowercased()
        let hasRisk = riskyKeywords.contains { text.contains($0) }
        geoMismatchDelta = hasRisk ? -10 : +2
    }



    // MARK: - Basit politika

    /// Örnek ülke kodu → seviye (1–4)
    private func levelForCountryCode(_ iso2: String) -> Int {
        switch iso2.uppercased() {
        case "SY", "IQ", "AF", "YE", "LY": return 4   // çok yüksek
        case "TR", "IN", "EG", "TH", "MX": return 3   // yüksek-orta
        case "US", "DE", "FR", "NL", "SE": return 1   // düşük
        default: return 2                             // orta
        }
    }

    /// Seviye → delta (ayrı ayrı ayarlanabilir)
    private func deltaForLevel(_ level: Int, isNationality: Bool) -> Int {
        // Basit örnek: seviye arttıkça negatif etki
        switch level {
        case 4: return isNationality ? -12 : -15
        case 3: return isNationality ?  -8 :  -6
        case 2: return  -2
        default: return  +1
        }
    }
}

// MARK: - Modeller (benzersiz isimler)

struct GeoRiskDelta: Identifiable, Hashable {
    let id: UUID
    let title: String
    let delta: Int
}

struct GeoRiskResult {
    enum Color { case red, yellow, green, neutral }
    let deltas: [GeoRiskDelta]
    let total: Int
    let color: Color
    let nationalityLevel: Int?
    let residenceLevel: Int?
}

