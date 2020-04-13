//
//  Data+LittleEndianSlice.swift
//  
//
//  Created by Terry Latanville on 2020-01-10.
//

import Foundation

public extension Data {
    /// Allows subscripting an arbitrary, contiguous range of `Data` which is then decoded from Little Endian.
    /// - Parameters
    ///   - kind: The resulting `Type` into which we decode the data, also used for validting sizing
    ///   - range: The range of bytes to pull out of `self`.
    /// - Returns: An `UnsignedInteger` of `T` containing decoded data from `range`
    subscript<T: UnsignedInteger>(kind: T.Type, range: Range<Int>) -> T {
        // Ensure we don't go off the end of our data and are requesting "right-sized" values
        precondition(range.endIndex <= count)
        precondition(range.count <= MemoryLayout<T>.size)
        let indexBeforeEndIndex = range.index(before: range.endIndex)
        return range.reversed().reduce(0) { result, index in
            let shift = 8 * (indexBeforeEndIndex - index)
            return result | (T(self[index]) << shift)
        }
    }
}
