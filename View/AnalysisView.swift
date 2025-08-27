//
//  AnalysisView.swift
//  zt
//
//  Created by Nihal Akgül on 25.08.2025.
//

import SwiftUI

struct AnalysisView: View {
    // INPUTS (KYCInfoView'den gelecek)
    let birthDate: Date
    let nationality: String              // "TR" (ISO-2)
    let residenceCountry: String         // "DE" (ISO-2)
    let mismatchJustification: String?   // uyruk ≠ ikamet ise opsiyonel metin

    // Age VM
    @State private var expandAge = true
    @StateObject private var vm: AgeAnalysisController

    init(
        birthDate: Date,
        nationality: String,
        residenceCountry: String,
        mismatchJustification: String?
    ) {
        self.birthDate = birthDate
        self.nationality = nationality.uppercased()
        self.residenceCountry = residenceCountry.uppercased()
        self.mismatchJustification = mismatchJustification
        _vm = StateObject(wrappedValue: AgeAnalysisController(birthDate: birthDate))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ageCard()   // Yaş kartı
                geoCard()   // Coğrafi risk kartı
            }
            .padding(.vertical, 20)
            .padding(.horizontal)
        }
        .navigationTitle("KYC Analizi")
    }

    // MARK: - Age Card (UI only)
    @ViewBuilder
    private func ageCard() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                withAnimation(.spring()) { expandAge.toggle() }
            } label: {
                HStack {
                    Text("Yaş")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    Text(vm.score.label)
                        .font(.subheadline.bold())
                        .foregroundColor(.white.opacity(0.95))
                    Image(systemName: expandAge ? "chevron.up" : "chevron.down")
                        .foregroundColor(.white)
                        .padding(.leading, 4)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(color(from: vm.colorToken))   // renk Controller’dan (yellow/green/neutral)
                .cornerRadius(16)
                .shadow(radius: 6)
            }

            if expandAge {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Doğum tarihi: \(birthDate.formatted(date: .long, time: .omitted))")
                    Text("Yaş: \(vm.score.ageYears) yıl")
                    let sign = vm.score.delta >= 0 ? "+" : ""
                    Text("Puan katkısı: \(sign)\(vm.score.delta)")
                        .foregroundColor(vm.score.delta >= 0 ? .green : .red)

                    if vm.score.hardStop {
                        Text("Karar: Olamaz (Yaş < 18)")
                            .font(.subheadline.bold())
                            .foregroundColor(.red)
                            .padding(.top, 4)
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
            }
        }
    }

    // MARK: - Geo Card (GeoRiskSection kullanır)
    @ViewBuilder
    private func geoCard() -> some View {
        GeoRiskSection(
            nationality: nationality,
            residenceCountry: residenceCountry,
            mismatchJustification: mismatchJustification,
            debugMode: true
        )
    }

    // AgeColorToken: .yellow | .green | .neutral
    private func color(from token: AgeAnalysisController.AgeColorToken) -> Color {
        switch token {
        case .yellow: return .yellow
        case .green:  return .green
        case .neutral: return .gray
        }
    }
}

#Preview {
    NavigationStack {
        AnalysisView(
            birthDate: Calendar.current.date(byAdding: .year, value: -30, to: .now)!,
            nationality: "TR",
            residenceCountry: "DE",
            mismatchJustification: "Eğitim için Almanya'dayım"
        )
    }
}

