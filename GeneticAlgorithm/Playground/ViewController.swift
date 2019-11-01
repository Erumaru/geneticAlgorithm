//
//  ViewController.swift
//  GeneticAlgorithm
//
//  Created by erumaru on 10/31/19.
//  Copyright © 2019 KBTU. All rights reserved.
//

import UIKit
import SnapKit

class PlaygroundViewController: UIViewController {
    // MARK: - Variables
    var creatures: [Creature] = []
    var eatenCreatures: [Bool] = []
    var eatenFood: [Bool] = []
    var foods: [Food] = []
    private let initialCount = 10
    private var foodCount = 500
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    // MARK: - Outlets
    var avarageSpeedLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.text = ""
        label.textAlignment = .center
        
        return label
    }()
    
    var avarageSearchAreaLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.text = ""
        label.textAlignment = .center
        
        return label
    }()
    
    var numberOfCreaturesLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.text = ""
        
        return label
    }()
    
    var dayLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        label.textAlignment = .center
        label.text = ""
        
        return label
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        start()
        markup()
    }

    // MARK: - Game
    private func createFood() {
        for index in 0..<foods.count {
            foods[index].model.removeFromSuperview()
        }
        eatenFood.removeAll()
        foods.removeAll()
        
        for _ in 0..<foodCount {
            let food = Food.random(bounds: view.bounds.size)
            foods.append(food)
            eatenFood.append(false)
            view.insertSubview(food.model, at: 0)
        }
    }
    
    private func start() {
        for _ in 0..<initialCount {
            let creature = Creature.random(bounds: view.bounds.size)
            creatures.append(creature)
            eatenCreatures.append(false)
            view.addSubview(creature.model)
        }
        
        createFood()
        Lifetimer.shared.delegate = self
        Lifetimer.shared.startTimer()
    }
    
    private func moveCreatures() {
        for index in 0..<creatures.count {
            UIView.animate(withDuration: 0.2) {
                self.creatures[index].move(foods: self.foods, eatenFood: &self.eatenFood, creatures: self.creatures, eatenCreaures: &self.eatenCreatures, id: index)
            }
        }
    }
    
    private func clearEatenFood() {
        for index in 0..<eatenFood.count {
            foods[index].model.isHidden = eatenFood[index]
        }
    }
    
    private func killEatenCreatures() {
        let newCreatures = creatures.enumerated().compactMap { (index, creature) -> Creature? in
            if eatenCreatures[index] {
                self.creatures[index].model.removeFromSuperview()
                return nil
            }
            return creature
        }
        creatures = newCreatures
        
        eatenCreatures = creatures.map { _ in false }
    }
    
    // MARK: - Markup
    private func markup() {
        view.backgroundColor = .white
        
        [dayLabel, avarageSpeedLabel, avarageSearchAreaLabel, numberOfCreaturesLabel].forEach { view.addSubview($0) }
        
        dayLabel.snp.makeConstraints() {
            $0.top.equalTo(view.snp.topMargin)
            $0.left.right.equalToSuperview()
        }
        
        avarageSpeedLabel.snp.makeConstraints() {
            $0.bottom.equalTo(view.snp.bottomMargin)
            $0.left.equalToSuperview()
            $0.width.equalTo(avarageSearchAreaLabel.snp.width)
        }
        
        avarageSearchAreaLabel.snp.makeConstraints() {
            $0.bottom.equalTo(view.snp.bottomMargin)
            $0.left.equalTo(avarageSpeedLabel.snp.right)
            $0.width.equalTo(numberOfCreaturesLabel.snp.width)
        }
        
        numberOfCreaturesLabel.snp.makeConstraints() {
            $0.bottom.equalTo(view.snp.bottomMargin)
            $0.left.equalTo(avarageSearchAreaLabel.snp.right)
            $0.right.equalToSuperview()
        }
    }
}


extension PlaygroundViewController: LifetimerDelegate {
    func tick() {
        moveCreatures()
        clearEatenFood()
        killEatenCreatures()
    }
    
    func newDay() {
        createFood()
        
        var newCreatures: [Creature] = []
        
        creatures.forEach {
            for index in 0..<$0.eatCount {
                if index == 0 {
                    let newOne = Creature(position: $0.position)
                    newOne.searchArea = $0.searchArea
                    newOne.speed = $0.speed
                    newCreatures.append(newOne)
                } else {
                    let newTwo = $0.mutated()
                    newTwo.eatCount = 0
                    
                    newCreatures.append(newTwo)
                }
            }
        }
        
        for index in 0..<creatures.count {
            creatures[index].model.removeFromSuperview()
        }
        
        creatures = newCreatures.sorted { $0.eatArea < $1.eatArea }
        eatenCreatures = creatures.map { _ in false }
        
        for index in 0..<creatures.count {
            creatures[index].position = .random(bounds: view.bounds.size)
            view.insertSubview(creatures[index].model, at: 0)
        }
        
        var avarageSpeed: CGFloat = 0
        var minimumSpeed: CGFloat = CGFloat(MAXFLOAT)
        var maximumSpeed: CGFloat = CGFloat(-MAXFLOAT)
        var avarageSize: CGFloat = 0
        var minimumSize: CGFloat = CGFloat(MAXFLOAT)
        var maximumSize: CGFloat = CGFloat(-MAXFLOAT)
        
        creatures.forEach {
            minimumSpeed = min(minimumSpeed, $0.speed)
            maximumSpeed = max(maximumSpeed, $0.speed)
            avarageSpeed += $0.speed / CGFloat(self.creatures.count)
            avarageSize += ($0.searchArea / 2.0) / CGFloat(self.creatures.count)
            minimumSize = min(minimumSize, $0.searchArea / 2.0)
            maximumSize = max(maximumSize, $0.searchArea / 2.0)
        }
        
        avarageSpeedLabel.text = "speed\nmin: \(String(format: "%.2f", minimumSpeed))\navg:\(String(format: "%.2f", avarageSpeed))\nmax:\(String(format: "%.2f", maximumSpeed))"
        avarageSearchAreaLabel.text = "size\nmin: \(String(format: "%.2f", minimumSize))\navg:\(String(format: "%.2f", avarageSize))\nmax:\(String(format: "%.2f", maximumSize))"
        numberOfCreaturesLabel.text = "population:\n\(creatures.count)"
        dayLabel.text = "Day \(Lifetimer.shared.dayNumber)"
        foodCount = max(foodCount - 10, 100)
    }
}
