//
//  SplashScreenView.swift
//  zt
//
//  Created by Nihal Akgül on 15.08.2025.
//


// +

import SwiftUI

struct SplashScreenView: View {
    var body: some View {
        ZStack {
            
            Color(red:0.84, green:0.0, blue:0.0).ignoresSafeArea() // arka plan rengini burda hallediyorum
            VStack {
                Image(systemName:"building.columns.fill") // logo apple ın kendi kütüphanesinden
                    .resizable() // boyutlandır
                    .scaledToFit() // orantılı kücültme veya büyütme
                    .frame(width: 120, height: 120) // sabit ölcü
                    .foregroundColor(.white) // rengi

                Text("Ziraat Bankası")
                    .font(.largeTitle.bold()) //büyük kalın yazı tipi
                    .foregroundColor(.white) 
            }
        }
    }
}

#Preview { SplashScreenView() }
