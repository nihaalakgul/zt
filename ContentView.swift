//
//  ContentView.swift
//  zt
//
//  Created by Nihal Akgül on 15.08.2025.
//

// +





import SwiftUI

struct ContentView: View {
    @State private var goNext = false

    var body: some View {
        NavigationStack {
            ZStack { // zstack cünkü Splash’ı arkaya koyup üstte görünmeyen NavigationLink ile geçişi yönetmek için. koymayadabilirdim.
                SplashScreenView()

                NavigationLink("", isActive: $goNext) { // buton yerine state kullanıyorum 
                    TCEntryContainer()
                        .navigationBarBackButtonHidden(true)
                        .toolbar(.hidden, for: .navigationBar)
                }
                .hidden()
            }
            .toolbar(.hidden, for: .navigationBar) // kökten gizle
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    goNext = true // 1.5 saniye bekle link i tetikle sonra tc entry e push et
                }
            }
        }
    }
}

#Preview { ContentView() }



 /*
  import SwiftUI

struct ContentView: View {
    @State private var goNext = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion // // Erişilebilirlik için

    var body: some View {
        NavigationStack {
            ZStack {
                SplashScreenView()

                NavigationLink("", isActive: $goNext) {
                    TCEntryContainer()
                        .navigationBarBackButtonHidden(true)
                        .toolbar(.hidden, for: .navigationBar)
                }
                .hidden()
            }
            .toolbar(.hidden, for: .navigationBar)
            .task {
                // // Erişilebilirlikte beklemeyi kısalt (kullanıcı deneyimi için iyi pratik)
                let delay: UInt64 = reduceMotion ? 300_000_000 : 1_500_000_000
                try? await Task.sleep(nanoseconds: delay) // // İptal edilebilir bekleme
                if !Task.isCancelled {
                    withAnimation(.easeInOut) {           // // Yumuşak geçiş
                        goNext = true
                    }
                }
            }
        }
    }
}

*/
