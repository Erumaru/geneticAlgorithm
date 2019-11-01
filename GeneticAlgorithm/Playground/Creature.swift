//
//  Creature.swift
//  GeneticAlgorithm
//
//  Created by erumaru on 10/31/19.
//  Copyright © 2019 KBTU. All rights reserved.
//

import Foundation
import UIKit

class Creature {
    // MARK: - Variables
    var speed: CGFloat = 10
    var eatCount = 0
    var searchArea: CGFloat = 60 {
        didSet {
            eatArea = self.searchArea / 3.0
        }
    }
    var eatArea: CGFloat = 20 {
        didSet {
            model.frame.size = CGSize(width: self.eatArea, height: self.eatArea)
            model.layer.cornerRadius = self.eatArea / 2.0
        }
    }
    var position: CGPoint {
        didSet {
            model.frame.origin = CGPoint(x: self.position.x - self.eatArea / 2.0, y: self.position.y - self.eatArea / 2.0)
        }
    }
    
    lazy var model: UIView = {
        let view = UIView()
        view.frame.size = CGSize(width: 20, height: 20)
        view.layer.cornerRadius = 10
        view.backgroundColor = .random
        
        return view
    }()
    
    // MARK: - Methods
    func move(foods: [Food], eatenFood: inout [Bool], creatures: [Creature], eatenCreaures: inout [Bool], id: Int) {
        if eatenCreaures[id] { return }
        var creatureAround: Creature?
        var leastDistanceToCreature = CGFloat(MAXFLOAT)
        for index in 0..<creatures.count {
            if index == id { continue }
            if creatures[index].eatArea * 4 > eatArea { continue }
            if eatenCreaures[index] { continue }
            let distance = creatures[index].position.distance(self.position)
            if distance < eatArea / 2.0 {
                self.eat(creatures: creatures, eatenCreatures: &eatenCreaures, index: index)
                return
            } else if distance < searchArea && distance < leastDistanceToCreature {
                creatureAround = creatures[index]
                leastDistanceToCreature = distance
            }
        }
        
        if let creature = creatureAround {
            var dx = creature.position.x - position.x
            var dy = creature.position.y - position.y
            let distance = CGPoint.zero.distance(CGPoint(x: dx, y: dy))
            dx = dx / distance * speed
            dy = dy / distance * speed
            
            if distance <= speed {
                position = creature.position
            } else {
                position = CGPoint(x: position.x + dx, y: position.y + dy)
            }
            return
        }
        
        var foodAround: Food?
        var leastDistance = CGFloat(MAXFLOAT)
        for index in 0..<foods.count {
            guard !eatenFood[index] else { continue }
            let distance = foods[index].position.distance(self.position)
            if distance < eatArea / 2.0 {
                self.eat(foods: foods, eatenFood: &eatenFood, index: index)
                return
            } else if distance < searchArea && distance < leastDistance {
                foodAround = foods[index]
                leastDistance = distance
            }
        }
    
        if let food = foodAround {
            var dx = food.position.x - position.x
            var dy = food.position.y - position.y
            let distance = CGPoint.zero.distance(CGPoint(x: dx, y: dy))
            dx = dx / distance * speed
            dy = dy / distance * speed
            
            if distance <= speed {
                position = food.position
            } else {
                position = CGPoint(x: position.x + dx, y: position.y + dy)
            }
            return
        }
        
        
        var dx = CGFloat.random(in: -100...100)
        var dy = CGFloat.random(in: -100...100)
        let distance = CGPoint.zero.distance(CGPoint(x: dx, y: dy))
        dx = dx / distance * speed
        dy = dy / distance * speed
        
        position = CGPoint(x: position.x + dx, y: position.y + dy)
    }
    
    func eat(creatures: [Creature], eatenCreatures: inout [Bool], index: Int) {
        eatenCreatures[index] = true
        eatCount += creatures[index].eatCount + 2
    }
    
    func eat(foods: [Food], eatenFood: inout [Bool], index: Int) {
        eatenFood[index] = true
        eatCount += 1
    }
    
    func mutated(mutation: Bool = .random()) -> Creature {
        let newCreature = Creature(position: self.position)
        
        if mutation {
            newCreature.speed = speed * 1.1
            newCreature.searchArea = searchArea * 0.9
        } else {
            newCreature.speed = speed * 0.9
            newCreature.searchArea = searchArea * 1.1
        }
        
        return newCreature
    }
    
    static func random(bounds: CGSize) -> Creature {
        return Creature(position: .random(bounds: bounds))
    }
    
    // MARK: - Init
    init(position: CGPoint) {
        self.position = position
        self.model.frame.origin = CGPoint(x: self.position.x - self.eatArea / 2.0, y: self.position.y - self.eatArea / 2.0)
    }
}

extension UIColor {
    static var random: UIColor {
        return .init(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1), alpha: 1)
    }
}

extension CGPoint {
    static func random(bounds: CGSize) -> CGPoint {
        return CGPoint(x: .random(in: 0..<bounds.width), y: .random(in: 0..<bounds.height))
    }
    
    func distance(_ to: CGPoint) -> CGFloat {
        let xDist = x - to.x
        let yDist = y - to.y
        return CGFloat(sqrt(xDist * xDist + yDist * yDist))
    }
}
