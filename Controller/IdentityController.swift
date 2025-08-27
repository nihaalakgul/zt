//
//  IdentityController.swift
//  zt
//
//  Created by Nihal Akgül on 18.08.2025.



//
import Foundation
import SwiftUI

/// TC giriş akışını yöneten Controller:
/// - Input filtrasyonu (yalnız rakam + 11 hane)
/// - TCKN algoritmik doğrulama
/// - Müşteri numarası arama/üretme + çakışma kontrolü
/// - Hata / yükleniyor durumları
@MainActor
final class IdentityController: ObservableObject {
    // MARK: - UI State
    @Published var tc: String = "" // tc geliyo
    @Published var isTCValid: Bool = false // devam butonu geçerli mi
    @Published var customerNumber: String? = nil // set işlemi
    @Published var errorMessage: String? = nil
    @Published var isSubmitting: Bool = false

    // MARK: - Dependencies
    private let svc: FirebaseService

    init(service: FirebaseService = .shared) {
        self.svc = service
    } // servisi kullanıyoruz  

    // MARK: - TextField değişimi
    func onTCChanged(_ value: String) {
        // Yalnız rakam ve 11 haneyle sınırla
        let filtered = value.filter(\.isNumber)
        tc = String(filtered.prefix(11))

        // DEBUG'da hızlı geliştirme için sadece uzunluk; Release'te algoritmik doğrulama
        #if DEBUG
        isTCValid = (tc.count == 11)
        #else
        isTCValid = Self.isValidTCKN(tc)
        #endif

        // Kullanıcı yazmaya devam ettikçe eski hatayı temizle
        errorMessage = nil
    }

    // View tarafında pratik kullanım için Binding
    var tcBinding: Binding<String> {
        Binding(get: { self.tc }, set: { self.onTCChanged($0) })
    }

    // MARK: - Devam butonu akışı
    func submit() async {
        // Çifte tıklamayı yut
        guard !isSubmitting else { return }

        // Geçersizse ilerleme
        guard isTCValid else {
            errorMessage = "Geçersiz T.C. Kimlik Numarası"
            return
        }

        isSubmitting = true
        defer { isSubmitting = false }

        do {
            // 1) Aynı TC ile daha önce kayıt var mı?
            if let existing = try await svc.findByTC(tc) {
                customerNumber = existing.id
                return
            }

            // 2) Yoksa yeni müşteri no üret ve çakışmayı kontrol et
            var newId = Self.generateCustomerNumber(for: tc)
            while try await svc.findById(newId) != nil {
                newId = Self.generateCustomerNumber(for: tc)
            }

            // 3) Kaydı oluştur
            let customer = Customer(
                id: newId,
                nationalId: tc,
                createdAt: Date(),
                riskScore: nil,
                riskFlags: []
            )
            try await svc.upsertCustomer(customer)

            // 4) Sunucu zaman damgası vs. (opsiyonel)
            try? await svc.setServerTimestamp(newId)

            // 5) Başarı: Container bunu yakalayıp KYC ekranına geçer
            customerNumber = newId
        } catch {
            errorMessage = "Kayıt sırasında bir hata oluştu. Lütfen tekrar deneyin."
        }
    }

    // MARK: - Helpers (yalnızca bu sınıfta kullanıldığı için private static)
    /// TCKN algoritmik doğrulama
    private static func isValidTCKN(_ tc: String) -> Bool {
        guard tc.count == 11, tc.allSatisfy(\.isNumber), tc.first != "0" else { return false }
        let digits = tc.compactMap { Int(String($0)) }

        // 10. hane kuralı
        let oddSum  = digits[0] + digits[2] + digits[4] + digits[6] + digits[8]
        let evenSum = digits[1] + digits[3] + digits[5] + digits[7]
        let d10 = ((oddSum * 7) - evenSum) % 10

        // 11. hane kuralı
        let d11 = (digits[0...9].reduce(0, +)) % 10

        return digits[9] == d10 && digits[10] == d11
    }

    /// İnsan okunur müşteri numarası üretimi (düşük çakışma)
    /// Örn: ZB-123-48291  (TC son 3 + rastgele 5 hane)
    private static func generateCustomerNumber(for tc: String) -> String {
        let suffix = String(tc.suffix(3))
        let random = (0..<5).compactMap { _ in "0123456789".randomElement() }
        return "ZB-\(suffix)-\(String(random))"
    }
}
