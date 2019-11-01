//
//  Food.swift
//  GeneticAlgorithm
//
//  Created by erumaru on 10/31/19.
//  Copyright © 2019 KBTU. All rights reserved.
//

import Foundation
import UIKit

class Food {
    // MARK: - Variables
    var position: CGPoint {
        didSet {
            model.frame.origin = CGPoint(x: self.position.x - 5, y: self.position.y - 5)
        }
    }
    var model: UIView = {
        let view = UIView()
        view.frame.size = CGSize(width: 10, height: 10)
        view.layer.cornerRadius = 5
        view.backgroundColor = .red
        
        return view
    }()
    
    // MARK: - Methods
    static func random(bounds: CGSize) -> Food {
        return .init(position: .random(bounds: bounds))
    }
    
    // MARK: - Lifecycle
    init(position: CGPoint) {
        self.position = position
        self.model.frame.origin = CGPoint(x: self.position.x - 5, y: self.position.y - 5)
    }
}
