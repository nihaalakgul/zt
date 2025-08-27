//
//  FirebaseService.swift
//  zt
//
//  Created by Nihal Akgül on 15.08.2025.
//  Updated with KYC helpers
//

import Foundation
import FirebaseFirestore

// DİKKAT: BURADA Customer MODELİ TANIMLAMA!
// Customer zaten Model/Customer.swift içinde var.
// Eğer burada tekrar tanımlarsan "Invalid redeclaration of 'Customer'" hatası alırsın.

// MARK: - FirebaseService

final class FirebaseService {

    // Singleton (KYCInfoController gibi yerlerde .shared ile kullanılacak)
    static let shared = FirebaseService()

    private init() {}

    private let db = Firestore.firestore()
    private var customers: CollectionReference { db.collection("customers") }

    // MARK: - CUSTOMER: TC ile daha önce kayıt var mı?
    func findByTC(_ tc: String) async throws -> Customer? {
        let snap = try await customers
            .whereField("nationalId", isEqualTo: tc)
            .limit(to: 1)
            .getDocuments()
        guard let doc = snap.documents.first else { return nil }
        return try mapDocToCustomer(doc)
    }

    // MARK: - CUSTOMER: DocID (müşteri no) var mı?
    func findById(_ id: String) async throws -> Customer? {
        let doc = try await customers.document(id).getDocument()
        guard doc.exists else { return nil }
        return try mapDocToCustomer(doc)
    }

    // MARK: - CUSTOMER: Kayıt oluştur/güncelle
    func upsertCustomer(_ c: Customer) async throws {
        let data: [String: Any] = [
            "nationalId": c.nationalId,
            "createdAt": Timestamp(date: c.createdAt),
            "riskScore": c.riskScore as Any,
            "riskFlags": c.riskFlags as Any
        ]
        try await customers.document(c.id).setData(data, merge: true)
    }

    // MARK: - CUSTOMER: Server timestamp (opsiyonel)
    func setServerTimestamp(_ id: String) async throws {
        try await customers.document(id)
            .setData(["serverCreatedAt": FieldValue.serverTimestamp()], merge: true)
    }

    // MARK: - CUSTOMER Mapping
    private func mapDocToCustomer(_ doc: DocumentSnapshot) throws -> Customer {
        let data = doc.data() ?? [:]
        let nationalId = data["nationalId"] as? String ?? ""
        let ts = data["createdAt"] as? Timestamp
        let createdAt = ts?.dateValue() ?? Date()
        let riskScore = data["riskScore"] as? Int
        let riskFlags = data["riskFlags"] as? [String]
        return Customer(
            id: doc.documentID,
            nationalId: nationalId,
            createdAt: createdAt,
            riskScore: riskScore,
            riskFlags: riskFlags
        )
    }
}

// MARK: - KYC EXTENSION
extension FirebaseService {

    // KYC koleksiyon yolu: customers/{id}/kyc/profile
    private func kycDocRef(for customerId: String) -> DocumentReference {
        customers
            .document(customerId)
            .collection("kyc")
            .document("profile")
    }

    /// KYC profilini oluştur/güncelle (merge).
    /// KYCProfile ve Gender üst-level tipler (namespace yok) varsayımıyla yazıldı.
    func upsertKYCProfile(_ profile: KYCProfile) async throws {
        let data: [String: Any] = [
            "customerId": profile.customerId,
            "nationalId": profile.nationalId,

            "firstName": profile.firstName,
            "lastName": profile.lastName,
            "birthDate": Timestamp(date: profile.birthDate),
            "phone": profile.phone,
            "email": profile.email,
            "address": profile.address,

            "nationality": profile.nationality,
            "residenceCountry": profile.residenceCountry,
            "gender": profile.gender.rawValue,
            "hasCriminalRecord": profile.hasCriminalRecord,

            // Türetilmiş alan (raporlama için faydalı olabilir)
            "age": profile.age,

            // Sunucu zamanı (en son güncelleme)
            "updatedAt": FieldValue.serverTimestamp()
        ]

        try await kycDocRef(for: profile.customerId).setData(data, merge: true)
    }

    /// KYC profilini oku.
    func fetchKYCProfile(customerId: String) async throws -> KYCProfile? {
        let doc = try await kycDocRef(for: customerId).getDocument()
        guard doc.exists, let data = doc.data() else { return nil }
        return try mapDocToKYCProfile(customerId: customerId, data: data)
    }

    /// KYC profilinden tek alanı güncelle (örnek kullanım: patch)
    func updateKYCField(customerId: String, key: String, value: Any) async throws {
        try await kycDocRef(for: customerId).setData(
            [key: value, "updatedAt": FieldValue.serverTimestamp()],
            merge: true
        )
    }

    // MARK: - KYC Mapping
    private func mapDocToKYCProfile(customerId: String, data: [String: Any]) throws -> KYCProfile {
        let nationalId = data["nationalId"] as? String ?? ""

        let firstName = data["firstName"] as? String ?? ""
        let lastName  = data["lastName"]  as? String ?? ""

        let birthTs = data["birthDate"] as? Timestamp
        let birthDate = birthTs?.dateValue() ?? Date(timeIntervalSince1970: 0)

        let phone  = data["phone"]  as? String ?? ""
        let email  = data["email"]  as? String ?? ""
        let address = data["address"] as? String ?? ""

        let nationality = data["nationality"] as? String ?? ""
        let residenceCountry = data["residenceCountry"] as? String ?? ""

        // Gender enum’un senin projende üst-level olduğunu varsaydım:
        let genderRaw = data["gender"] as? String ?? Gender.male.rawValue
        let gender = Gender(rawValue: genderRaw) ?? .male

        let hasCriminalRecord = data["hasCriminalRecord"] as? Bool ?? false
        
        

        return KYCProfile(
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
            hasCriminalRecord: hasCriminalRecord
        )
    }
}

