//
//  GuitarScale.swift
//  FreestyleWithViews
//
//  Created by Rafael Prado on 28/10/17.
//  Copyright © 2017 DoM7. All rights reserved.
//

import Foundation

class GuitarScale{
    static let c3 = Sound(url: URL(fileURLWithPath: Bundle.main.path(forResource: "guitar_scale/c3", ofType: "mp3")!))
    static let d3 = Sound(url: URL(fileURLWithPath: Bundle.main.path(forResource: "guitar_scale/d3", ofType: "mp3")!))
    static let e3 = Sound(url: URL(fileURLWithPath: Bundle.main.path(forResource: "guitar_scale/e3", ofType: "mp3")!))
    static let f3 = Sound(url: URL(fileURLWithPath: Bundle.main.path(forResource: "guitar_scale/f3", ofType: "mp3")!))
    static let g3 = Sound(url: URL(fileURLWithPath: Bundle.main.path(forResource: "guitar_scale/g3", ofType: "mp3")!))
    static let a3 = Sound(url: URL(fileURLWithPath: Bundle.main.path(forResource: "guitar_scale/a3", ofType: "mp3")!))
    static let b3 = Sound(url: URL(fileURLWithPath: Bundle.main.path(forResource: "guitar_scale/b3", ofType: "mp3")!))
    static let c4 = Sound(url: URL(fileURLWithPath: Bundle.main.path(forResource: "guitar_scale/c4", ofType: "mp3")!))
    static let d4 = Sound(url: URL(fileURLWithPath: Bundle.main.path(forResource: "guitar_scale/d4", ofType: "mp3")!))
    static let e4 = Sound(url: URL(fileURLWithPath: Bundle.main.path(forResource: "guitar_scale/e4", ofType: "mp3")!))
    
    static func playChord(_ array: [Bool]){
        if array[9]{
            GuitarScale.c3!.play{ completed in
                print("c3")
            }
        }
        if array[8]{
            GuitarScale.d3!.play{ completed in
                print("d3")
            }
            
        }
        if array[7]{
            GuitarScale.e3!.play{ completed in
                print("e3")
            }
            
        }
        if array[6]{
            GuitarScale.f3!.play{ completed in
                print("f3")
            }
            
        }
        if array[5]{
            GuitarScale.g3!.play{ completed in
                print("g3")
            }
            
        }
        if array[4]{
            GuitarScale.a3!.play{ completed in
                print("a3")
            }
            
        }
        if array[3]{
            GuitarScale.b3!.play{ completed in
                print("b3")
            }
            
        }
        if array[2]{
            GuitarScale.c4!.play{ completed in
                print("c4")
            }
            
        }
        if array[1]{
            GuitarScale.d4!.play{ completed in
                print("d4")
            }
            
        }
        if array[0]{
            GuitarScale.e4!.play{ completed in
                print("e4")
            }
        }
    }
}
