//
//  UInt8+BitManipulation.swift
//  
//
//  Created by Terry Latanville on 2020-01-13.
//

import Foundation

public extension UInt8 {
    static let ankiFullBatteryFlag: UInt8 = (1 << 4)
    static let ankiLowBatteryFlag: UInt8 = (1 << 5)
    static let ankiOnChargerFlag: UInt8 = (1 << 6)

    func contains(_ value: UInt8) -> Bool {
        return (self & value) == value
    }
}
