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
    var speed: CGFloat = 20
    var eatCount = 0
    var searchArea: CGFloat = 50 {
        didSet {
            eatArea = self.searchArea / 2.0
        }
    }
    var eatArea: CGFloat = 25 {
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
        view.frame.size = CGSize(width: 25, height: 25)
        view.layer.cornerRadius = 12.5
        view.backgroundColor = .random
        
        return view
    }()
    
    // MARK: - Methods
    func move(foods: [Food], eaten: inout [Bool]) {
        var foodAround: Food?
        var leastDistance = CGFloat(MAXFLOAT)
        for index in 0..<foods.count {
            guard !eaten[index] else { continue }
            let distance = foods[index].position.distance(self.position)
            if distance < eatArea / 2.0 {
                self.eat(foods: foods, eaten: &eaten, index: index)
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
        } else {
            var dx = CGFloat.random(in: -100...100)
            var dy = CGFloat.random(in: -100...100)
            let distance = CGPoint.zero.distance(CGPoint(x: dx, y: dy))
            dx = dx / distance * speed
            dy = dy / distance * speed
            
            position = CGPoint(x: position.x + dx, y: position.y + dy)
        }
    }
    
    func eat(foods: [Food], eaten: inout [Bool], index: Int) {
        eaten[index] = true
        eatCount += 1
//        print("\(self.position) \(foods[index].position) \(self.eatArea)")
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
