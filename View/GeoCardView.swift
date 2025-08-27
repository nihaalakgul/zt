//
//  GeoCardView.swift
//  zt
//
//  Created by Nihal Akgül on 25.08.2025.
//

import SwiftUI

// Sadece gerekçe + delta gösteren ufak kart
struct GeoCardView: View {
    let delta: Int
    let justification: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Coğrafya Analizi")
                .font(.headline)
            if let j = justification, !j.isEmpty {
                Text("Gerekçe: \(j)")
                    .font(.subheadline)
            }
            Text("Puan etkisi: \(delta >= 0 ? "+" : "")\(delta)")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(delta >= 0 ? .green : .red)
        }
        .padding()
        .background(.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// Tüm coğrafya risk bölümünü yöneten kapsayıcı view
struct GeoRiskSection: View {
    @StateObject private var viewModel: GeoAnalysisController
    @State private var expanded = false

    init(
        nationality: String,
        residenceCountry: String,
        mismatchJustification: String?,
        debugMode: Bool = true
    ) {
        _viewModel = StateObject(wrappedValue: GeoAnalysisController(
            nationality: nationality,
            residenceCountry: residenceCountry,
            mismatchJustification: mismatchJustification,
            debugMode: debugMode
        ))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                withAnimation(.spring()) { expanded.toggle() }
            } label: {
                HStack {
                    Text("Coğrafi Risk")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    Text(headerLabel)
                        .font(.subheadline.bold())
                        .foregroundColor(.white.opacity(0.95))
                    Image(systemName: expanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.white)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(color(from: viewModel.result?.color ?? .neutral))
                .cornerRadius(16)
                .shadow(radius: 6)
            }
            .task(id: expanded) {
                if expanded && viewModel.result == nil {
                    await viewModel.run()
                }
            }

            if expanded {
                if viewModel.isLoading {
                    ProgressView("Yükleniyor...")
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)

                } else if let res = viewModel.result {
                    // Local değerlere çıkar → Binding/dynamicMember yok
                    let deltaValue: Int = viewModel.geoMismatchDelta
                    let justificationValue: String? = viewModel.mismatchJustification
                    GeoCardView(delta: deltaValue, justification: justificationValue)

                    // Detay deltalara ve toplama dair özet
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(res.deltas) { d in
                            HStack {
                                Text(d.title)
                                Spacer()
                                Text("\(d.delta >= 0 ? "+" : "")\(d.delta)")
                                    .foregroundColor(d.delta >= 0 ? .green : .red)
                                    .bold()
                            }
                        }
                        Divider()
                        HStack {
                            Text("Toplam")
                                .font(.headline)
                            Spacer()
                            Text("\(res.total >= 0 ? "+" : "")\(res.total)")
                                .font(.headline)
                                .foregroundColor(res.total >= 0 ? .green : .red)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)

                } else if let err = viewModel.errorMessage {
                    Text(err)
                        .foregroundColor(.yellow)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                }
            }
        }
        .animation(.spring(), value: expanded)
    }

    private var headerLabel: String {
        if let r = viewModel.result {
            let rl = r.residenceLevel ?? 0
            let nl = r.nationalityLevel ?? 0
            return "İkamet L\(rl) • Uyruk L\(nl)"
        }
        return "Değerlendirmek için dokun"
    }

    private func color(from c: GeoRiskResult.Color) -> Color {
        switch c {
        case .red: return .red
        case .yellow: return .yellow
        case .green: return .green
        case .neutral: return .gray
        }
    }
}

