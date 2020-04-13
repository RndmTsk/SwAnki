//
//  Messages.swift
//  
//
//  Created by Terry Latanville on 2020-01-08.
//

import Foundation

public enum VehicleMessage: UInt8 { // All V2C prefixed commands
    // Ping request / response
    case ping = 0x17 // ANKI_VEHICLE_MSG_V2C_PING_RESPONSE // 23

    // Messages for checking vehicle version info
    case version = 0x19 // ANKI_VEHICLE_MSG_V2C_VERSION_RESPONSE // 25

    // Battery level
    case batteryLevel = 0x1b // ANKI_VEHICLE_MSG_V2C_BATTERY_LEVEL_RESPONSE // 27

    // Vehicle position updates
    case localizationPositionUpdate = 0x27 // ANKI_VEHICLE_MSG_V2C_LOCALIZATION_POSITION_UPDATE // 39
    case localizationTransitionUpdate = 0x29 // ANKI_VEHICLE_MSG_V2C_LOCALIZATION_TRANSITION_UPDATE // 41
    case localiationIntersectionUpdate = 0x2a // ANKI_VEHICLE_MSG_V2C_LOCALIZATION_INTERSECTION_UPDATE // 42
    case vehicleDelocalized = 0x2b // ANKI_VEHICLE_MSG_V2C_VEHICLE_DELOCALIZED // 43
    case offsetFromRoadCenterUpdate = 0x2d // ANKI_VEHICLE_MSG_V2C_OFFSET_FROM_ROAD_CENTER_UPDATE // 45
}

// TODO: (TL) Associated values where appropriate to construct payload
public enum ControllerMessage { // All C2V prefixed commands
    /// BLE disconnect
    case disconnect

    /// Ping request
    case ping

    // Messages for checking vehicle version info
    case version

    // Battery level
    case batteryLevel

    // Lights
    case setLights // (mask: UInt8)

    // Driving Commands
    case setSpeed
    case changeLane
    case cancelLaneChange

    // Vehicle position updates
    case setOffsetFromRoadCenter

    // Turn Command
    case turn

    // Light Patterns
    case lightsPattern

    // Vehicle Configuration Parameters
    case setConfigParams

    // SDK Mode
    case sdkMode

    internal var size: UInt8 { // TODO: (TL) Debug message
        switch self {
        case .setLights:
            // #define ANKI_VEHICLE_MSG_C2V_SET_LIGHTS_SIZE 2
            return 2
        case .turn, .setConfigParams, .sdkMode:
            // #define ANKI_VEHICLE_MSG_C2V_TURN_SIZE 3
            // #define ANKI_VEHICLE_MSG_C2V_SET_CONFIG_PARAMS_SIZE 3
            // #define ANKI_VEHICLE_MSG_SDK_MODE_SIZE 3
            return 3
        case .setOffsetFromRoadCenter:
            // #define ANKI_VEHICLE_MSG_C2V_SET_OFFSET_FROM_ROAD_CENTER_SIZE 5
            return 5
        case .setSpeed:
            // #define ANKI_VEHICLE_MSG_C2V_SET_SPEED_SIZE 6
            return 6
        case .changeLane:
            // #define ANKI_VEHICLE_MSG_C2V_CHANGE_LANE_SIZE 11
            return 11
        case .lightsPattern:
            // #define ANKI_VEHICLE_MSG_C2V_LIGHTS_PATTERN_SIZE 17
            return 17

        case .disconnect, .ping, .version, .batteryLevel, .cancelLaneChange:
            return SwAnki.vehicleMessageBaseSize
        }
    }

    internal var messageId: UInt8 { // TODO: (TL) Debug message
        switch self {
        case .disconnect:
            // ANKI_VEHICLE_MSG_C2V_DISCONNECT
            return 0x0d // 13
        case .ping:
             // ANKI_VEHICLE_MSG_C2V_PING_REQUEST
            return 0x16 // 22
        case .version:
            // ANKI_VEHICLE_MSG_C2V_VERSION_REQUEST
            return 0x18 // 24
        case .batteryLevel:
            // ANKI_VEHICLE_MSG_C2V_BATTERY_LEVEL_REQUEST
            return 0x1a // 26
        case .setLights:
            // ANKI_VEHICLE_MSG_C2V_SET_LIGHTS
            return 0x1d // 29
        case .setSpeed:
            // ANKI_VEHICLE_MSG_C2V_SET_SPEED
            return 0x24 // 36
        case .changeLane:
            // ANKI_VEHICLE_MSG_C2V_CHANGE_LANE
            return 0x25 // 37
        case .cancelLaneChange:
            // ANKI_VEHICLE_MSG_C2V_CANCEL_LANE_CHANGE
            return 0x26 // 38
        case .setOffsetFromRoadCenter:
            // ANKI_VEHICLE_MSG_C2V_SET_OFFSET_FROM_ROAD_CENTER
            return 0x2c // 44
        case .turn:
            // ANKI_VEHICLE_MSG_C2V_TURN
            return 0x32 // 50
        case .lightsPattern:
            // ANKI_VEHICLE_MSG_C2V_LIGHTS_PATTERN
            return 0x33 // 51
        case .setConfigParams:
            // ANKI_VEHICLE_MSG_C2V_SET_CONFIG_PARAMS
            return 0x45 // 69
        case .sdkMode:
            // ANKI_VEHICLE_MSG_C2V_SDK_MODE
            return 0x90 // 144
        }
    }

    internal var payload: [UInt8] {
        switch self {
        case .setLights:
            return [].packed() // TODO: (TL) raw data -> packed
        case .setSpeed:
            return [].packed() // TODO: (TL) raw data -> packed
        case .changeLane:
            return [].packed() // TODO: (TL) raw data -> packed
        case .setOffsetFromRoadCenter:
            return [].packed() // TODO: (TL) raw data -> packed
        case .turn:
            return [].packed() // TODO: (TL) raw data -> packed
        case .lightsPattern:
            return [].packed() // TODO: (TL) raw data -> packed
        case .setConfigParams:
            return [].packed() // TODO: (TL) raw data -> packed
        case .sdkMode:
            return [].packed() // TODO: (TL) raw data -> packed
        case .disconnect, .ping, .version, .batteryLevel, .cancelLaneChange:
            return []
        }

    }

    internal var bluetoothMessage: BluetoothMessage { BluetoothMessage(size: size, messageId: messageId, payload: payload) }
}

// NOTE: All message structs are "packed" in the C implementation
//       #define ATTRIBUTE_PACKED  __attribute__((packed))
/// A raw representation of a message sent to or received from an Anki vehicle
internal struct BluetoothMessage { // Adapted from anki_vehicle_msg and it's various subspecies
    let size: UInt8
    let messageId: UInt8
    let payload: [UInt8]
}
