//
//  Operators+extension.swift
//  HomeBudget
//
//  Created by Maxim Grigoriev on 18/02/2018.
//  Copyright © 2018 Maxim Grigoriev. All rights reserved.
//

import Foundation


public func |= (leftSide : inout Bool, rightSide : Bool) {
    leftSide = leftSide || rightSide
}

public func &= (leftSide : inout Bool, rightSide : Bool) {
    leftSide = leftSide && rightSide
}

public func ^= (leftSide : inout Bool, rightSide : Bool) {
    leftSide = leftSide != rightSide
}
