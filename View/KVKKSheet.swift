//
//  KVKKSheet.swift
//  zt
//
//  Created by Nihal Akgül on 20.08.2025.
//

import SwiftUI

struct CheckboxRow: View {
    @Binding var isOn: Bool
    var title: String
    var body: some View {
        Button {
            isOn.toggle()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: isOn ? "checkmark.square.fill" : "square")
                    .imageScale(.large)
                Text(title).bold()
                Spacer()
            }
            .foregroundColor(.primary)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.vertical, 4)
    }
}

struct KVKKSheet: View {
    let text: String
    var onConfirm: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var isAgreed = false

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text("KVKK Aydınlatma Metni")
                    .font(.title3.bold())

                ScrollView {
                    Text(text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
                .frame(height: 260)
                .background(Color.gray.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                CheckboxRow(isOn: $isAgreed, title: "Okudum, anladım.")
                    .padding(.top, 4)

                Button {
                    onConfirm()
                    dismiss()
                } label: {
                    Text("Onayla")
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(isAgreed ? Color.red : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(!isAgreed)

                Spacer(minLength: 0)
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") { dismiss() }
                }
            }
        }
    }
}
