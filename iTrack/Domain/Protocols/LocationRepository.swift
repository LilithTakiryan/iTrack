//
//  LocationRepository.swift
//  iTrack
//
//  Created by lilit on 29.07.26.
//


import Foundation

public protocol LocationRepository: Sendable {
    func createRoute() async throws -> Route
    func addLocation(_ location: LocationPoint, to routeId: UUID) async throws
    func fetchRoutes() async throws -> [Route]
    func deleteRoute(id: UUID) async throws
    func updateSteps(_ steps: Int, routeId: UUID) async throws
}
