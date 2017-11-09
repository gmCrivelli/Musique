//
//  TypeComponent.swift
//  Musique
//
//  Created by Gustavo De Mello Crivelli on 06/11/17.
//  Copyright © 2017 Gustavo De Mello Crivelli. All rights reserved.
//

import Foundation
import GameplayKit

enum ObstacleType : Int {
    case fence = 1
    case lake = 2
    case vine = 3
    
    static let allValues = [fence, lake, vine]
    
    func getName() -> String {
        switch self {
        case .fence:
            return "fence"
        case .lake:
            return "lake"
        case .vine:
            return "vine"
        default:
            return ""
        }
    }
}

class TypeComponent : GKComponent {
    let obstacleType : ObstacleType
    
    init(obstacleType: ObstacleType) {
        self.obstacleType = obstacleType
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
