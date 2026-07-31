//
//  StatusBadge.swift
//  iTrack
//
//  Created by lilit on 31.07.26.
//
import SwiftUI

struct StatusBadge: View {
    let isActive: Bool
    let title: String

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(isActive ? Color.green : Color.secondary)
                .frame(width: 6, height: 6)
            
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(isActive ? Color.primary : Color.secondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background {
            Capsule()
                .fill(isActive ? Color.green.opacity(0.15) : Color.primary.opacity(0.06))
        }
        .overlay {
            Capsule()
                .strokeBorder(isActive ? Color.green.opacity(0.3) : Color.clear, lineWidth: 1)
        }
    }
}

