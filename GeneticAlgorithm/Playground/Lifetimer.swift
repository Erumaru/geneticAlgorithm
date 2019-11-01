//
//  Lifetimer.swift
//  GeneticAlgorithm
//
//  Created by erumaru on 10/31/19.
//  Copyright © 2019 KBTU. All rights reserved.
//

import Foundation

protocol LifetimerDelegate: class {
    func tick()
    func newDay()
}

class Lifetimer {
    // MARK: - Variables
    static var shared = Lifetimer()
    var dayNumber = 0
    var ticksInDay = 10
    var currentTick = 0
    private var timer: Timer!
    weak var delegate: LifetimerDelegate?
    
    // MARK: - Methods
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
    }
    
    private func newDay() {
        dayNumber += 1
        currentTick = 0
        timer.invalidate()
        delegate?.newDay()
        startTimer()
    }
    
    @objc private func tick() {
        currentTick += 1
        if currentTick > ticksInDay {
            newDay()
        } else {
            delegate?.tick()
        }
    }
}
