//
//  AppLogger.swift
//  iTrack
//
//  Created by lilit on 01.08.26.
//
import Foundation

final class AppLogger {
    static let shared = AppLogger()
    
    private init() {}
    
    nonisolated func debug(_ message: String) {
        #if DEBUG
        print("DEBUG: \(message)")
        #endif
    }
    
    nonisolated func error(_ message: String) {
        #if DEBUG
        print("ERROR: \(message)")
        #endif
    }
}
