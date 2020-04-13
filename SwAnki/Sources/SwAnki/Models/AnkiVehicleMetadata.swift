//
//  File.swift
//  
//
//  Created by Terry Latanville on 2020-01-10.
//

import CoreBluetooth

public typealias AnkiAdvertisement = String
public extension AnkiAdvertisement {
    static let services = "kCBAdvDataServiceUUIDs"
    static let isConnectable = "kCBAdvDataIsConnectable"
    static let localName = "kCBAdvDataLocalName"
    static let txPowerLevel = "kCBAdvDataTxPowerLevel"
    static let timestamp = "kCBAdvDataTimestamp"
    static let manufacturer = "kCBAdvDataManufacturerData"
}

public struct AnkiVehicleMetadata: CustomDebugStringConvertible {
    // MARK: - Properties
    public var identifier: UInt32 { manufacturerInfo.identifier }
    public let manufacturerInfo: AnkiManufacturerInfo
    public let services: AnkiServices
    public let vehicleInfo: AnkiVehicleInfo
    public let txPowerLevel: Int
    public let isConnectable: Bool

    // MARK: - <CustomDebugStringConvertible> Properties
    /// Descriptions for `manufacturerInfo`, `services`, and `vehicleInfo` are self-formatting
    public var debugDescription: String { "\(manufacturerInfo)\n\(services)\n\(vehicleInfo)" }

    // MARK: - Lifecycle Functions
    public init?(advertisementData: [AnkiAdvertisement: Any]) {
/*
  [x] "kCBAdvDataServiceUUIDs": [BE15BEEF-6186-407E-8381-0BD89C4D8DF4]
  [x] "kCBAdvDataManufacturerData": <beef000c 0056b365>,
  [x] "kCBAdvDataIsConnectable": 1,
  [x] "kCBAdvDataTxPowerLevel": 0,
  [x] "kCBAdvDataLocalName": `0    Drive
  kCBAdvDataTimestamp": 600353227.4441251
*/
        guard let manufacturerInfo = AnkiManufacturerInfo(data: advertisementData[.manufacturer] as? Data),
            let services = AnkiServices(uuids: advertisementData[.services] as? [CBUUID]),
            let vehicleInfo = AnkiVehicleInfo(string: advertisementData[.localName] as? String),
            let txPowerLevel = advertisementData[.txPowerLevel] as? Int,
            let isConnectable = advertisementData[.isConnectable] as? Bool
            else {
                return nil
        }
        self.manufacturerInfo = manufacturerInfo
        self.services = services
        self.vehicleInfo = vehicleInfo
        self.txPowerLevel = txPowerLevel
        self.isConnectable = isConnectable
    }
}

/*
/**
 * Vehicle information present in Bluetooth LE advertising packets.
 *
 * flags: EIR / AD flags
 * tx_power: transmission power
 * mfg_data: parsed data from the MANUFACTURER_DATA bytes
 * local_name: parsed data from the LOCAL_NAME string bytes
 * service_id: Anki Vehicle UUID (128-bit)
 */
typedef struct anki_vehicle_adv {
    uint8_t                     flags;
    uint8_t                     tx_power;
    anki_vehicle_adv_mfg_t      mfg_data;
    anki_vehicle_adv_info_t     local_name;
    uuid128_t                   service_id;
} anki_vehicle_adv_t;

 */

// MARK: - anki_vehicle_adv_mfg_t / anki_vehicle_parse_mfg_data
public struct AnkiManufacturerInfo: CustomDebugStringConvertible {
    // MARK: - Constants
    private struct Constants {
        static let packetSize = 8
    }

    // MARK: - Properties
    public let identifier: UInt32
    public let modelId: UInt8
    private let _reserved: UInt8
    public let productId: UInt16

    // MARK: - <CustomDebugStringConvertible> Properties
    public var debugDescription: String {"== AnkiManufacturerInfo ==\n  Identifier: \(identifier)\n  Model ID: \(modelId)\n  _reserved: \(_reserved)\n  Product ID: \(productId)" }

    // MARK: - Lifecycle Functions
    public init?(data: Data?) {
        guard let data = data, data.count == Constants.packetSize else { return nil }
        let productId = data[UInt16.self, 0..<2]
        self.identifier = data[UInt32.self, 4..<8]
        self.modelId = data[3]
        self._reserved = data[2]
        self.productId = productId
    }
}

public struct AnkiServices: CustomDebugStringConvertible {
    // MARK: - Properties
    public let uuids: [CBUUID]

    // MARK: - <CustomDebugStringConvertible> Properties
    public var debugDescription: String { "== AnkiServices ==\n  Service UUIDs: \(uuids)" }

    // MARK: - Lifecycle Functions
    public init?(uuids: [CBUUID]?) {
        guard let uuids = uuids  else { return nil }
        self.uuids = uuids
    }
}

// MARK: - anki_vehicle_adv_info_t / anki_vehicle_parse_local_name
public struct AnkiVehicleInfo: CustomDebugStringConvertible {
    // MARK: - Properties
    public let state: AnkiVehicleState
    public let version: UInt16
    private let _reserved: [UInt8] = [] // Length: 5
    public let name: String // unsigned char, Length: 13, UTF8: 12 bytes + NULL

    // MARK: - <CustomDebugStringConvertible> Properties
    public var debugDescription: String { "== AnkiVehicleInfo ==\nState: \(state)\nVersion: \(version)\nName: \(name)" }

    // MARK: - Lifecycle Functions
    public init?(string: String?) {
        guard let asciiBytes = string?.compactMap({ $0.asciiValue }),
            asciiBytes.count > 0
            else { return nil }
        self.state = AnkiVehicleState(data: asciiBytes[0])

        var version: UInt16 = 0
        if asciiBytes.count > 1 {
            version = UInt16(asciiBytes[1])
        }
        if asciiBytes.count > 2 {
            version |= UInt16(asciiBytes[2] << 8)
        }
        self.version = version

        var name: String?
        if asciiBytes.count > 8 { // Length is 13
            let nameBytes = Data(asciiBytes[8..<asciiBytes.count])
            name = String(data: nameBytes, encoding: .utf8)
        }
        self.name = name ?? "Unknown"
    }
}

// MARK: - anki_vehicle_adv_state_t
public struct AnkiVehicleState: CustomDebugStringConvertible {
    // MARK: - Properties
    // The properties below serialize from less bits than the underlying types
    private let reserved: UInt8 = 0 // only 4 bits are used
    public let fullBattery: Bool // uint8_t, but only 1 bit
    public let lowBattery: Bool // uint8_t, but only 1 bit used
    public let onCharger: Bool // uint8_t, but only 1 bit used
    private let unavailable: UInt8 = 0 // only 1 bit used

    // MARK: - <CustomDebugStringConvertible> Properties
    public var debugDescription: String { "TODO" }

    // MARK: - Lifecycle Functions
    public init(data: UInt8) {
        let state = data & 0xff;
        self.fullBattery = state.contains(.ankiFullBatteryFlag)
        self.lowBattery = state.contains(.ankiLowBatteryFlag)
        self.onCharger = state.contains(.ankiOnChargerFlag)
    }
}

/*

/**
 * Vehicle information packed in the LOCAL_NAME string record
 * of an advertising packet.
 *
 * - state: Current vehicle state.
 *   NOTE: Changes to the vehicle state will cause the LOCAL_NAME value
 *   to change.
 * - version: Firmware version running on the vehicle
 * - name: User-defined name in UTF-8 encoding
 */
typedef struct anki_vehicle_adv_info {
    anki_vehicle_adv_state_t state;
    uint16_t            version;
    uint8_t             _reserved[5];
    unsigned char       name[13]; // UTF8: 12 bytes + NULL.
} anki_vehicle_adv_info_t;

/**
 * The state of a vehicle recorded in the advertising packet.
 *
 * - full_battery: The vehicle battery is fully charged
 * - low_battery: The vehicle battery has a low charge and will die soon
 * - on_charger: The vehicle is currently on the charger
 */
typedef struct anki_vehicle_adv_state {
  uint8_t _reserved:4;
  uint8_t full_battery:1;      // 4: TRUE if Car has full battery
  uint8_t low_battery:1;       // 5: TRUE if Car has low battery
  uint8_t on_charger:1;        // 6: TRUE if Car is on Charger
  uint8_t _unavailable:1;    // 7: Cannot be used due to BTLE character set constraint
} anki_vehicle_adv_state_t;


uint8_t anki_vehicle_parse_local_name(const uint8_t *bytes, uint8_t len, anki_vehicle_adv_info_t *local_name)
{
    if (len == 0)   return 1;

    uint8_t state = (uint8_t)bytes[0] & 0xff;
    local_name->state.full_battery = IS_VEHICLE_STATE_SET(state, VEHICLE_STATE_FULL_BATTERY);
    local_name->state.low_battery = IS_VEHICLE_STATE_SET(state, VEHICLE_STATE_LOW_BATTERY);
    local_name->state.on_charger = IS_VEHICLE_STATE_SET(state, VEHICLE_STATE_ON_CHARGER);

    if (len > 1) {
        local_name->version = bytes[1];
    }

    if (len > 2) {
        local_name->version |= (bytes[2] << 8);
    }

    if (len > 8) {
        uint8_t name_len = len - 8;
        memset(local_name->name, 0, (sizeof local_name->name));
        memmove(local_name->name, &bytes[8], name_len);
    }

    return 0;
}
 */
