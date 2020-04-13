//
//  CBManagerState+Debug.swift
//  
//
//  Created by Terry Latanville on 2020-01-10.
//

import CoreBluetooth

extension CBManagerState: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .unknown: return "Unknown"
        case .resetting: return "Resetting"
        case .unsupported: return "Unsupported"
        case .unauthorized: return "Unauthorized"
        case .poweredOff: return "Powered Off"
        case .poweredOn: return "Powered On"
        @unknown default:
            return "New, unsupported value: \(self.rawValue)"
        }
    }
}
