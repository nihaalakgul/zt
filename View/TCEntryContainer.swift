//  TCEntryContainer.swift
//  zt
//
//  Created by Nihal Akgül on 15.08.2025.
//


// +

import SwiftUI


struct TCEntryContainer: View {
    @StateObject private var controller = IdentityController()
    @Environment(\.dismiss) private var dismiss

    @State private var goKYC = false // kyc ekranına push icin

    private var tcBinding: Binding<String> {
        Binding(get: { controller.tc }, set: { controller.onTCChanged($0) })
    } // direkt controller manipüle etmesin diye köprü set

    var body: some View {
        
        //tc entry de ki gerekli verileri enjekte
        ZStack {
            TCEntryView(
                tc: tcBinding,
                isValid: controller.isTCValid,
                customerNumber: controller.customerNumber,
                onSubmit: { Task { await controller.submit() } },
                onClose: { dismiss() } // kapatma icin 
            )

            // hata bandı
            if let err = controller.errorMessage {
                VStack {
                    Spacer()
                    Text(err)
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color.black.opacity(0.35))
                        .clipShape(Capsule())
                        .padding(.bottom, 16)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            } // animasyonlu hata bandı

           
            NavigationLink("", isActive: $goKYC) {
                KYCInfoView(
                    customerId: controller.customerNumber ?? "",
                    nationalId: controller.tc // başarıyla alınan id yi tasıma
                )
                .navigationBarBackButtonHidden(true)
                .toolbar(.hidden, for: .navigationBar)
            }
            .hidden()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        // customerNumber set edilince otomatik geç
        .onChange(of: controller.customerNumber) { _, newVal in
            if newVal != nil { goKYC = true }
        }
        .animation(.easeInOut(duration: 0.2), value: controller.errorMessage)
    }
}

