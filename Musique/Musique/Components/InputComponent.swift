//
//  InputComponent.swift
//  Musique
//
//  Created by Gustavo De Mello Crivelli on 08/11/17.
//  Copyright © 2017 Gustavo De Mello Crivelli. All rights reserved.
//

import Foundation
import GameplayKit

class InputComponent : GKComponent {

    func jump() {
        if let moveComponent = entity?.component(ofType: MoveComponent.self) {
            moveComponent.setVelocity(velocity: float2(x: 0, y: 10))
        }
    }
}
