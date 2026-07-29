//
//  TrackingMode.swift
//  iTrack
//
//  Created by lilit on 29.07.26.
//
import Foundation

public enum TrackingMode: String, CaseIterable, Identifiable, Sendable {
    case foreground
    case background

    public var id: String { rawValue }
    public var title: String { rawValue.capitalized }
}
