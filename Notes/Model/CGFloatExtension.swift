//
//  CGFloatExtension.swift
//  Notes
//
//  Copyright © 2019 VIS Apps. All rights reserved.
//

import UIKit

extension CGFloat {
    static func deg2rad(_ number: CGFloat) -> CGFloat {
        return number * .pi / 180
    }
}
