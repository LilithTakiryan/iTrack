//
//  StepCounter.swift
//  iTrack
//
//  Created by lilit on 30.07.26.
//

import Foundation


public protocol StepCounterService: AnyObject {
    var steps: Int { get }
    var onStepsChanged: ((Int) -> Void)? { get set }

    func start(from date: Date)
    func stop() -> Int
}
