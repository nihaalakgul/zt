import SwiftUI

private struct FieldBox<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        content
            .tint(.white)
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .frame(minHeight: 44)
            .background(Color.white.opacity(0.14))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct KYCInfoView: View {
    @StateObject private var vm: KYCInfoController
    @FocusState private var focusedField: Bool
    @State private var goNext = false
    @State private var showKVKK = false

    init(customerId: String, nationalId: String) {
        _vm = StateObject(wrappedValue: KYCInfoController(customerId: customerId, nationalId: nationalId))
    }

    var body: some View {
        ZStack {
            Color(red: 0.84, green: 0.0, blue: 0.0).ignoresSafeArea()

            VStack(spacing: 12) {
                header()
                formScroll()
                kvkkButton()
                if let err = vm.errorMessage { errorText(err) }
            }

            // Navigation
            NavigationLink("", isActive: $goNext) {
                AnalysisView(
                    birthDate: vm.birthDate,
                    nationality: vm.nationality,
                    residenceCountry: vm.residenceCountry,
                    // ⬇️ DÜZELTME: normalize edilmiş durumu kullan
                    mismatchJustification: vm.hasGeoMismatch ? vm.geoJustification : nil
                )
            }
            .hidden()
        }
        // ⬇️ DÜZELTME: ekran açılır açılmaz bir kez hesaplat
        .onAppear { vm.recomputeGeoMismatch() }
        .safeAreaInset(edge: .bottom) { bottomBar() }
        .animation(.easeInOut, value: vm.isSaving)
        .animation(.easeInOut, value: vm.isValid)
    }

    // MARK: - Pieces

    @ViewBuilder
    private func header() -> some View {
        Text("Müşteri Bilgileri")
            .font(.title.bold())
            .foregroundColor(.white)
            .padding(.top, 8)
    }

    @ViewBuilder
    private func formScroll() -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                referenceLabels()

                nameFields()
                birthdateField()
                phoneField()
                emailField()
                addressField()
                nationalityPickers()
                mismatchExplanationIfNeeded()
                genderAndCriminal()
                Color.clear.frame(height: 84) // bottom padding for button
            }
            .padding(16)
            .background(Color.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
            .padding(.horizontal, 20)
            .scrollDismissesKeyboard(.interactively)
        }
    }

    @ViewBuilder
    private func referenceLabels() -> some View {
        // Müşteri No etiketi istersen geri açabilirsin
        Label("TC No: \(vm.nationalId)", systemImage: "person.badge.key")
            .font(.footnote)
            .foregroundColor(.white.opacity(0.9))
    }

    @ViewBuilder
    private func nameFields() -> some View {
        FieldBox { TextField("Ad", text: $vm.firstName).focused($focusedField) }
        FieldBox { TextField("Soyad", text: $vm.lastName).focused($focusedField) }
    }

    @ViewBuilder
    private func birthdateField() -> some View {
        FieldBox {
            HStack {
                Text("Doğum Tarihi")
                Spacer()
                DatePicker("", selection: $vm.birthDate, displayedComponents: .date)
                    .labelsHidden()
                    .datePickerStyle(.compact)
            }
            .accessibilityElement(children: .combine)
        }
    }

    @ViewBuilder
    private func phoneField() -> some View {
        FieldBox {
            TextField("Telefon", text: $vm.phone)
                .keyboardType(.phonePad)
                .focused($focusedField)
        }
    }

    @ViewBuilder
    private func emailField() -> some View {
        FieldBox {
            TextField("E-posta", text: $vm.email)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .focused($focusedField)
        }
    }

    @ViewBuilder
    private func addressField() -> some View {
        FieldBox {
            TextField("Adres", text: $vm.address, axis: .vertical)
                .focused($focusedField)
        }
    }

    @ViewBuilder
    private func nationalityPickers() -> some View {
        // Uyruk & Ülke
        SearchablePicker(title: "Uyruk", options: Lists.nationalities, selection: $vm.nationality)
            .onChange(of: vm.nationality) { _ in vm.recomputeGeoMismatch() }

        SearchablePicker(title: "Yaşadığı Ülke", options: Lists.countries, selection: $vm.residenceCountry)
            .onChange(of: vm.residenceCountry) { _ in vm.recomputeGeoMismatch() }
    }

    @ViewBuilder
    private func mismatchExplanationIfNeeded() -> some View {
        if vm.hasGeoMismatch {
            VStack(alignment: .leading, spacing: 8) {
                Text("Uyruk ve yaşadığınız ülke farklı. Lütfen nedeni belirtiniz:")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white.opacity(0.95))

                FieldBox {
                    TextField("Örn: Eğitim/iş sebebiyle geçici ikamet ...",
                              text: $vm.geoJustification, axis: .vertical)
                        .focused($focusedField)
                }
                .onChange(of: vm.geoJustification) { _ in vm.recomputeGeoMismatch() }

                HStack(spacing: 8) {
                    Image(systemName: vm.geoMismatchDelta < 0 ? "exclamationmark.triangle.fill" : "checkmark.seal.fill")
                   // Text("Coğrafya puan etkisi: \(vm.geoMismatchDelta)").bold()
                }
                .font(.footnote)
                .foregroundColor(.white.opacity(0.9))
                .padding(.top, 2)
            }
        }
    }

    @ViewBuilder
    private func genderAndCriminal() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Cinsiyet")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.white.opacity(0.9))
            Picker("Cinsiyet", selection: $vm.gender) {
                ForEach(Gender.allCases, id: \.self) { g in
                    Text(g.rawValue).tag(g)
                }
            }
            .pickerStyle(.segmented)
        }

        Toggle("Herhangi bir suç geçmişim var", isOn: $vm.hasCriminalRecord)
            .tint(.white)
            .foregroundColor(.white)
    }

    @ViewBuilder
    private func kvkkButton() -> some View {
        Button {
            showKVKK = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: vm.kvkkAccepted ? "checkmark.seal.fill" : "exclamationmark.shield")
                Text(vm.kvkkAccepted ? "KVKK Onayı Alındı" : "KVKK Metnini Oku ve Onayla")
                    .bold()
                Spacer()
            }
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .frame(minHeight: 44)
            .background(Color.white.opacity(0.18))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .sheet(isPresented: $showKVKK) {
            KVKKSheet(
                text:
"""
6698 sayılı Kişisel Verilerin Korunması Kanunu kapsamında...
"""
            ) {
                vm.markKVKKAccepted()
            }
        }
    }

    @ViewBuilder
    private func errorText(_ msg: String) -> some View {
        Text(msg)
            .foregroundColor(.yellow)
            .font(.footnote)
            .padding(.horizontal, 20)
    }

    @ViewBuilder
    private func bottomBar() -> some View {
        if vm.isValid {
            Button {
                Task {
                    await vm.save()
                    if vm.didSave { goNext = true }
                }
            } label: {
                Text("Devam")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .disabled(vm.isSaving)
            .background(vm.isSaving ? Color.white.opacity(0.4) : Color.white)
            .foregroundColor(Color(red: 0.84, green: 0.0, blue: 0.0))
            .cornerRadius(12)
            .padding(.horizontal, 16)
            .padding(.bottom, 2)
        } else {
            Color.clear.frame(height: 0)
        }
    }
}

