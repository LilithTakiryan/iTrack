//
//  StatusBadge.swift
//  iTrack
//
//  Created by lilit on 31.07.26.
//
import SwiftUI

struct MapTagView: View {
    enum Icon {
        case system(String)
        case statusDot(isActive: Bool)
    }

    let title: String
    var icon: Icon? = nil
    var isActiveStyle: Bool = false

    var body: some View {
        HStack(spacing: 6) {
            iconView
            
            Text(title)
                .font(.caption)
                .fontWeight(isActiveStyle ? .semibold : .bold)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5.5)
        .background(
            Capsule().fill(
                isActiveStyle ?
                AnyShapeStyle(Color.green.opacity(0.1)) :
                AnyShapeStyle(.ultraThinMaterial)
            )
        )
        .shadow(
            color: isActiveStyle ? .clear : .black.opacity(0.1),
            radius: 4, y: 2
        )
    }

    @ViewBuilder
    private var iconView: some View {
        switch icon {
        case let .system(name):
            Image(systemName: name)
                .font(.caption)
                .foregroundStyle(.secondary)
        case let .statusDot(isActive):
            Circle()
                .fill(isActive ? Color.green : Color.secondary)
                .frame(width: 6, height: 6)
        case .none:
            EmptyView()
        }
    }
}
