//
//  CountryResolver.swift
//  zt
//
//  Created by Nihal Akgül on 26.08.2025.
//

import Foundation

/// Ülke adı / uyruk / ISO-2 / ISO-3 -> ISO-2 normalizasyonu.
/// Burayı istersen kendi `Lists` dosyandaki ülke/uyruk dizilerine göre genişletebilirsin.
public struct CountryResolver {

    // Mini örnek tablo (hemen çalışsın diye). Projende bunu kendi tam listenle değiştir.
    private static let demo: [(iso2: String, iso3: String, country: String, nationality: String)] = [
        ("TR","TUR","Turkey","Turkish"),
        ("MX","MEX","Mexico","Mexican"),
        ("YE","YEM","Yemen","Yemeni"),
        ("DE","DEU","Germany","German"),
        ("ES","ESP","Spain","Spanish"),
        ("AE","ARE","United Arab Emirates","Emirati")
    ]

    public static func iso2(from input: String) -> String? {
        let key = input.trimmingCharacters(in: .whitespacesAndNewlines)
                       .replacingOccurrences(of: "İ", with: "I")
                       .replacingOccurrences(of: "ı", with: "I")
                       .uppercased()

        // zaten ISO-2 geldiyse
        if key.count == 2 { return key }

        // ISO-3 yakala
        if let hit3 = demo.first(where: { $0.iso3.uppercased() == key }) {
            return hit3.iso2
        }

        // ülke adı veya uyruk
        if let hit = demo.first(where: {
            $0.country.uppercased() == key || $0.nationality.uppercased() == key
        }) {
            return hit.iso2
        }
        return nil
    }
}
