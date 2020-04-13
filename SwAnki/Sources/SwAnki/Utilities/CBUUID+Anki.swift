//
//  CBUUID+Anki.swift
//  
//
//  Created by Terry Latanville on 2020-01-10.
//

import CoreBluetooth

public extension CBUUID {
    // Bluetooth Service UUID in various representations
    static let ankiService = CBUUID(string: "BE15BEEF-6186-407E-8381-0BD89C4D8DF4") // ANKI_STR_SERVICE_UUID
    static let ankiServiceBytes: [UInt8] = [0xbe, 0x15, 0xbe, 0xef, 0x61, 0x68, 0x40, 0x7e, 0x83, 0x81, 0x0b, 0xd8, 0x9c, 0x4d, 0x8d, 0xf4] // ANKI_SERVICE_UUID
    static let ankiServiceLEBytes: [UInt8] = [0xf4, 0x8d, 0x4d, 0x9c, 0xd8, 0x0b, 0x81, 0x83, 0x7e, 0x40, 0x86, 0x61, 0xef, 0xbe, 0x15, 0xbe] // ANKI_SERVICE_UUID_LE

    // Bluetooth Characteristic UUIDs in various representations
    static let ankiReadCharacteristic = CBUUID(string: "BE15BEE0-6186-407E-8381-0BD89C4D8DF4") // ANKI_STR_CHR_READ_UUID
    static let ankiReadCharacteristicBytes: [UInt8] = [0xbe, 0x15, 0xbe, 0xe0, 0x61, 0x68, 0x40, 0x7e, 0x83, 0x81, 0x0b, 0xd8, 0x9c, 0x4d, 0x8d, 0xf4] // ANKI_CHR_READ_UUID

    static let ankiWriteCharacteristic = CBUUID(string: "BE15BEE1-6186-407E-8381-0BD89C4D8DF4") // ANKI_STR_CHR_WRITE_UUID
    static let ankiWriteCharacteristicBytes: [UInt8] = [0xbe, 0x15, 0xbe, 0xe1, 0x61, 0x68, 0x40, 0x7e, 0x83, 0x81, 0x0b, 0xd8, 0x9c, 0x4d, 0x8d, 0xf4] // ANKI_CHR_WRITE_UUID
}

extension CBUUID: Identifiable {
    public var id: CBUUID { self }
}
