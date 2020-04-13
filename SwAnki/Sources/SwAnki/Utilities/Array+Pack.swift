//
//  File.swift
//  
//
//  Created by Terry Latanville on 2020-01-10.
//

import Foundation

public extension Array where Element == UInt8 {
    mutating func pack() {
        guard self.count > 0 else { return }
        // TODO: (TL) actually mutate `mutableSelf`
    }

    func packed() -> [UInt8] {
        var mutableSelf = self
        guard mutableSelf.count > 0 else { return mutableSelf }
        // TODO: (TL) actually mutate `mutableSelf`
        return mutableSelf
    }
}
