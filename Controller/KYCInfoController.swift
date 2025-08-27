//
//  KYCInfoController.swift
//  zt
//
//  Created by Nihal Akgül on 25.08.2025.

import Foundation
import SwiftUI

@MainActor
final class KYCInfoController: ObservableObject {
    // Referanslar
    let customerId: String
    let nationalId: String
    
    // Form alanları
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var birthDate = Date(timeIntervalSince1970: 0)
    @Published var phone = ""
    @Published var email = ""
    @Published var address = ""
    @Published var nationality = ""         // ISO-2 bekleniyor (örn. "TR")
    @Published var residenceCountry = ""    // ISO-2 (örn. "DE")
    @Published var gender: Gender = .male
    @Published var hasCriminalRecord = false
    
    // Uyruk ≠ ikamet gerekçesi (formdan alınıyor)
    @Published var geoJustification: String = ""
    
    // Mismatch anlık puanı (KYCInfoView canlı gösterecek)
    @Published private(set) var geoMismatchDelta: Int = 0
    @Published private(set) var hasGeoMismatch: Bool = false
    
    // UI durumları
    @Published var isSaving = false
    @Published var errorMessage: String?
    @Published var didSave = false
    
    // KVKK
    @Published var kvkkAccepted: Bool = false
    let kvkkVersion = "v1.0"
    
    // Servis bağımlılığı
    private let svc: FirebaseService
    
    // Mismatch gerekçesinde riskli anahtar kelimeler
    private let riskyKeywords: [String] = [
        "suç", "ihlal", "gasp", "illegal", "kaçak", "yasal değil", "sabıka",
        "aranıyorum", "kaçıyorum", "kaçakçılık", "uyuşturucu", "hırsızlık"
    ]
    
    init(customerId: String, nationalId: String, service: FirebaseService = .shared) {
        self.customerId = customerId
        self.nationalId = nationalId
        self.svc = service
    }
    
    // Hesaplananlar
    var age: Int {
        Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year ?? 0
    }
    
    // Basit validasyon
    var isValid: Bool {
        guard !firstName.trimmingCharacters(in: .whitespaces).isEmpty,
              !lastName.trimmingCharacters(in: .whitespaces).isEmpty,
              !phone.trimmingCharacters(in: .whitespaces).isEmpty,
              !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !nationality.isEmpty,
              !residenceCountry.isEmpty
        else { return false }
        
        let phoneDigitsOK = phone.filter(\.isNumber).count >= 10
        let emailLikeOK = email.contains("@") && email.contains(".")
        let isAdultOK = age >= 18
        
        return phoneDigitsOK && emailLikeOK && isAdultOK && kvkkAccepted
    }
    
    func save() async {
        guard isValid else { return }
        isSaving = true
        errorMessage = nil
        defer { isSaving = false }
        
        let profile = KYCProfile(
            customerId: customerId,
            nationalId: nationalId,
            firstName: firstName,
            lastName: lastName,
            birthDate: birthDate,
            phone: phone,
            email: email,
            address: address,
            nationality: nationality,
            residenceCountry: residenceCountry,
            gender: gender,
            hasCriminalRecord: hasCriminalRecord,
            kvkkAccepted: kvkkAccepted,
            kvkkAcceptedAt: kvkkAccepted ? Date() : nil,
            kvkkVersion: kvkkVersion
        )
        
        do {
            try await svc.upsertKYCProfile(profile)
            didSave = true
        } catch {
            errorMessage = "Bilgiler kaydedilemedi. Lütfen tekrar deneyin."
        }
    }
    
    func markKVKKAccepted() {
        kvkkAccepted = true
    }
    
    // MARK: - Coğrafya mismatch canlı hesap
    /// Uyruk–ikamet uyuşmazlığı puanlaması:
    /// - Mismatch yok: 0
    /// - Mismatch var + riskli kelime yok: +2 (geçerli/nötr)
    /// - Mismatch var + riskli kelime var: -10
    // KYCInfoController.swift
    
    
    private func normalizeISO2(_ s: String) -> String {
        let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines)
        return (CountryResolver.iso2(from: trimmed) ?? trimmed).uppercased()
    }

    func recomputeGeoMismatch() {
        let n = normalizeISO2(nationality)       // “Turkish” -> TR
        let r = normalizeISO2(residenceCountry)  // “Turkey”  -> TR
        hasGeoMismatch = !n.isEmpty && !r.isEmpty && n != r
        guard hasGeoMismatch else { geoMismatchDelta = 0; return }
        let risky = ["suç","ihlal","gasp","illegal","kaçak","yasal değil","sabıka","aranıyorum","kaçıyorum","kaçakçılık","uyuşturucu","hırsızlık"]
        let hasRisk = geoJustification.lowercased().contains { _ in risky.contains { geoJustification.lowercased().contains($0) } }
        geoMismatchDelta = hasRisk ? -10 : +2
    }

}
