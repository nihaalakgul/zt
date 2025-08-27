//
//  TCEntryView.swift
//  zt
//
//  Created by Nihal Akgül on 15.08.2025.
//


/* import SwiftUI

struct TCEntryView: View {
    @Binding var tc: String
    var isValid: Bool
    var customerNumber: String?         // altta gösterilir
    var onSubmit: () -> Void
    var onClose: (() -> Void)? = nil

    @FocusState private var focused: Bool
    private var canContinue : Bool{
        isValid && !focused
    }

    var body: some View {
        ZStack {
            // Arka plan
            Color(red: 0.84, green: 0.0, blue: 0.0).ignoresSafeArea()

            // İÇERİK: Dikey ortalı
            VStack {
                Spacer(minLength: 0)

                VStack(spacing: 24) {
                    Text("Müşteri Kayıt")
                        .font(.system(.title, design: .rounded).bold())
                        .foregroundColor(.white)

                    // Kart
                    VStack(alignment: .leading, spacing: 10) {
                        Text("T.C. Kimlik Numarası")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.white.opacity(0.9))

                        TextField("T.C. Kimlik Numaranızı Girin", text: $tc)
                            .keyboardType(.numberPad)
                            .focused($focused)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                            .textContentType(.oneTimeCode)
                            .padding(.horizontal, 14)
                            .frame(height: 52)
                            .background(.white.opacity(0.14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(.white.opacity(0.18), lineWidth: 1)
                            )
                            .cornerRadius(14)
                            .foregroundColor(.white)

                        if tc.count == 11 && !isValid {
                            Text("TC formatı/algoritması hatalı.")
                                .font(.footnote)
                                .foregroundColor(.yellow)
                                .padding(.top, 4)
                        }

                        Button(action: onSubmit) {
                            Text("Devam")
                                .font(.headline)
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .background(isValid ? .white : .white.opacity(0.4))
                                .foregroundColor(Color(red: 0.84, green: 0.0, blue: 0.0))
                                .cornerRadius(14)
                        }
                        .disabled(!canContinue)
                        .padding(.top, 4)
                    }
                    .padding(16)
                    .background(.white.opacity(0.08))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.white.opacity(0.12), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                }
                .onAppear { focused = true }

                Spacer(minLength: 0)

                // SADECE ALTA: Müşteri numarası toast
                if let cn = customerNumber {
                    Text("Müşteri Numaranız: \(cn)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color.black.opacity(0.35))
                        .clipShape(Capsule())
                        .padding(.bottom, 16)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        // ÜST SAĞ X: safe area İÇİNDE, ikonlarla çakışmaz
        .safeAreaInset(edge: .top) {
            HStack {
                Spacer()
                if let onClose {
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .bold))
                            .padding(12)
                            .background(.white.opacity(0.25))
                            .clipShape(Circle())
                            .foregroundColor(.white)
                            .accessibilityLabel("Kapat")
                    }
                    .padding(.trailing, 12)   // sağdan boşluk
                }
            }
            .padding(.top, 4)                 // status bar’ın hemen altı
        }
    }
}

*/

import SwiftUI

struct TCEntryView: View {
    @Binding var tc: String
    var isValid: Bool
    var customerNumber: String?
    var onSubmit: () -> Void
    var onClose: (() -> Void)? = nil

    @FocusState private var focused: Bool

    // Devam yalnızca GEÇERLİ + YAZMIYOR iken aktif
    private var canContinue: Bool { isValid && !focused } // focused = true iken devam daima pasif  is valid : true focused : false oldugunda devam eder

    var body: some View {
        ZStack {
            Color(red: 0.84, green: 0.0, blue: 0.0).ignoresSafeArea()

            VStack {
                Spacer(minLength: 0)

                VStack(spacing: 24) {
                    Text("Müşteri Kayıt")
                        .font(.system(.title, design: .rounded).bold())
                        .foregroundColor(.white)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("T.C. Kimlik Numarası")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.white.opacity(0.9))

                        TextField("T.C. Kimlik Numaranızı Girin", text: $tc)
                            .keyboardType(.numberPad)
                            .focused($focused) // klavye acık kapalı
                            .textInputAutocapitalization(.never) // büuük harf kapalı
                            .autocorrectionDisabled(true) // otomatik düzenleme kapalı
                            .textContentType(.none)                 // oneTimeCode yerine
                            .submitLabel(.done)
                            .onSubmit { if canContinue { onSubmit() } }
                            .onChange(of: tc) { _, new in           // 11’e gelince yazmayı bitir
                                if new.count == 11 { focused = false }
                            }
                            .padding(.horizontal, 14)
                            .frame(height: 52)
                            .background(.white.opacity(0.14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(.white.opacity(0.18), lineWidth: 1)
                            )
                            .cornerRadius(14)
                            .foregroundColor(.white)

                        if tc.count == 11 && !isValid {
                            Text("TC formatı/algoritması hatalı.")
                                .font(.footnote)
                                .foregroundColor(.yellow)
                                .padding(.top, 4)
                                .transition(.opacity)
                        }

                        Button(action: onSubmit) {
                            Text("Devam")
                                .font(.headline)
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .background(canContinue ? .white : .white.opacity(0.4)) // görsel = davranış
                                .foregroundColor(Color(red: 0.84, green: 0.0, blue: 0.0))
                                .cornerRadius(14)
                                .shadow(radius: canContinue ? 3 : 0)
                        }
                        .disabled(!canContinue) // yazarken veya geçersizken tıklanamaz
                        .padding(.top, 4)
                    }
                    .padding(16)
                    .background(.white.opacity(0.08))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.white.opacity(0.12), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                }
                .onAppear { focused = true }

                Spacer(minLength: 0)

                if let cn = customerNumber {
                    Text("Müşteri Numaranız: \(cn)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color.black.opacity(0.35))
                        .clipShape(Capsule())
                        .padding(.bottom, 16)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        // Ekrana dokununca klavyeyi kapatmak istersen:
        .contentShape(Rectangle())
        .onTapGesture { focused = false }

        // Üst sağ X (Container’dan onClose nil gelirse görünmez)
        .safeAreaInset(edge: .top) {
            HStack {
                Spacer()
                if let onClose {
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .bold))
                            .padding(12)
                            .background(.white.opacity(0.25))
                            .clipShape(Circle())
                            .foregroundColor(.white)
                            .accessibilityLabel("Kapat")
                    }
                    .padding(.trailing, 12)
                }
            }
            .padding(.top, 4)
        }
    }
}

