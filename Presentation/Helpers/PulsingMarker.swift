//
//  PulsingMarker.swift
//  iTrack
//
//  Created by lilit on 30.07.26.
//

import SwiftUI

struct PulsingMarker: View {
    let icon: String
    let color: Color
    
    @State private var animate = false
    
    var body: some View {
        Image(systemName: icon)
            .font(.title)
            .foregroundStyle(color)
            .scaleEffect(animate ? 1.2 : 1.0)
            .opacity(animate ? 0.7 : 1.0)
            .animation(
                .easeInOut(duration: 1)
                .repeatForever(autoreverses: true),
                value: animate
            )
            .onAppear {
                animate = true
            }
    }
}
