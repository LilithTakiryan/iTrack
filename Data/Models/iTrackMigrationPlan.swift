//
//  iTrackMigrationPlan.swift
//  iTrack
//
//  Created by lilit on 03.08.26.
//

import Foundation
import SwiftData

public enum iTrackMigrationPlan: SchemaMigrationPlan {
    public static var schemas: [any VersionedSchema.Type] = [
        iTrackSchemaV1.self
    ]
    
    public static var stages: [MigrationStage] = [
        // no migration needed yet
    ]
}
