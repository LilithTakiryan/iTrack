//
//  StepCounter.swift
//  iTrack
//
//  Created by lilit on 30.07.26.
//

import Foundation


protocol StepCounter {
    func start(from date: Date)
    func stop()
    var steps: Int { get }
}
