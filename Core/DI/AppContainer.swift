//
//  AppContainer.swift
//  iTrack
//
//  Created by lilit on 01.08.26.
//

import Foundation
import Swinject

final class AppContainer {
    static let shared = AppContainer()
    let container = Container()
    
    private init() {
        registerDependencies()
    }
    
    private func registerDependencies() {
        registerCoreDataDependencies()
        registerUseCases()
        registerViewModels()
    }
}
