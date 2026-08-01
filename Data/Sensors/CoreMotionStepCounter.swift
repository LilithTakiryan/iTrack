//
//  CoreMotionStepCounter.swift
//  iTrack
//
//  Created by lilit on 30.07.26.
//

import CoreMotion

final class CoreMotionStepCounter: StepCounterService {
    
    private let pedometer = CMPedometer()
    
    private(set) var steps = 0
    
    var onStepsChanged: ((Int) -> Void)?
    
    func start(from date: Date) {
        guard CMPedometer.isStepCountingAvailable() else {
            return
        }
        
        pedometer.startUpdates(from: date) { [weak self] data, _ in
            guard let count = data?.numberOfSteps.intValue else {
                return
            }
            
            Task { @MainActor in
                self?.steps = count
                self?.onStepsChanged?(count)
            }
        }
    }
    
    func stop() -> Int {
        pedometer.stopEventUpdates()
        pedometer.stopUpdates()
        return steps
    }
}
