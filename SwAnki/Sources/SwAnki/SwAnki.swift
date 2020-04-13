//
//  SwAnkiProtocol.swift
//  
//
//  Created by Terry Latanville on 2019-12-29.
//

import Foundation

// Adapted from
// https://github.com/anki/drive-sdk/blob/master/src/protocol.h

/* TODO: (TL)
//
// Bitwise masks applied to parsing_flags
//
// determine how many bits per code were read
#define PARSEFLAGS_MASK_NUM_BITS        0x0f

// determine if the track has an inverted code scheme
#define PARSEFLAGS_MASK_INVERTED_COLOR  0x80

// determine if the the code has been reverse parsed
#define PARSEFLAGS_MASK_REVERSE_PARSING 0x40

// determine if the current driving dir is reversed
#define PARSEFLAGS_MASK_REVERSE_DRIVING 0x20

 // Lights
 // The bits in the simple light message (ANKI_VEHICLE_MSG_C2V_SET_LIGHTS) corresponding to
 // each type of light.
 #define LIGHT_HEADLIGHTS    0
 #define LIGHT_BRAKELIGHTS   1
 #define LIGHT_FRONTLIGHTS   2
 #define LIGHT_ENGINE        3

 // Helper macros for parsing lights bits
 #define LIGHT_ANKI_VEHICLE_MSG_IS_VALID(messageBits, LIGHT_ID) (((messageBits >> LIGHT_ID)  & 1) == TRUE)
 #define LIGHT_ANKI_VEHICLE_MSG_GET_VALUE(messageBits, LIGHT_ID) ((messageBits >> (4 + LIGHT_ANKI_VEHICLE_MSG_HEADLIGHTS) & 1))

 #define ANKI_VEHICLE_MAX_LIGHT_INTENSITY 14
 #define ANKI_VEHICLE_MAX_LIGHT_TIME 11


 #define SUPERCODE_NONE          0
 #define SUPERCODE_BOOST_JUMP    1
 #define SUPERCODE_ALL           (SUPERCODE_BOOST_JUMP)



 */

public struct SwAnki {
    internal static let maxVehicleMessageSize: UInt8 = 20 // ANKI_VEHICLE_MSG_MAX_SIZE
    internal static let maxVehicleMessagePayloadSize: UInt8 = 18 // ANKI_VEHICLE_MSG_PAYLOAD_MAX_SIZE
    internal static let vehicleMessageBaseSize: UInt8 = 1 // ANKI_VEHICLE_MSG_BASE_SIZE

    enum VehicleTurnKind: UInt8 { // anki_vehicle_turn_type_t
        case none, left, right, uTurn, uTurnJump
    }

    enum VehicleTurnTrigger: UInt8 { // anki_vehicle_turn_trigger_t
        case immediate // Run immediately
        case intersection // Run at the next intersection
    }

    enum VehicleDrivingDirection: UInt8 { // anki_vehicle_driving_direction_t
        case forward, reverse
    }

    enum IntersectionCode: UInt8 { // anki_intersection_code_t
        case none, entryFirst, exitFirst, entrySecond, exitSecond
    }

    // LED channel definitions - for RGB engine, front, and tail lights
    enum VehicleLightChannel: UInt8 { // anki_vehicle_light_channel_t
        case red, tail, blue, green, frontL, frontR, count /* TODO: (TL) CaseIterable */
    }

    // Below is a description of the various effects used in SetLight(...)
    enum VehicleLightEffect: UInt8 { // anki_vehicle_light_effect_t
        case steady // Simply set the light intensity to 'start' value
        case fade // Fade intensity from 'start' to 'end'
        case throb // Fade intensity from 'start' to 'end' and back to 'start'
        case flash // Turn on LED between time 'start' and time 'end' inclusive
        case random // Flash the LED erratically - ignoring start/end
        case count // TODO: (TL) CaseIterable
    }

    enum TrackMaterial { // anki_track_material
        case plastic, vinyl
    }

    /// Not intended to be constructed
    private init() {}
}

/*
extension VehicleMessage {
    init(fromCar bytes: [UInt8]) { // TODO: (TL) packed data -> something useful
        self.size = 0
        self.messageId = 0
        self.payload = []
    }
    // TODO: (TL) This probably won't be a great way to represent a vehicle response
    init(fromCar kind: SwAnki.VehicleMessageKind) {
        self.size = kind.size
        self.messageId = kind.rawValue
        self.payload = [] // TODO: (TL) deserialize from raw data
    }
}
 */


// #define ANKI_VEHICLE_MSG_V2C_VERSION_RESPONSE_SIZE 3
struct VehicleMessageVersionResponse { // anki_vehicle_msg_version_response, ATTRIBUTE_PACKED
    let size: UInt8
    let messageId: UInt8
    let version: UInt16
}

// #define ANKI_VEHICLE_MSG_V2C_BATTERY_LEVEL_RESPONSE_SIZE 3
struct VehicleMessageBatteryLevelResponse { // anki_vehicle_msg_battery_level_response, ATTRIBUTE_PACKED
    let size: UInt8
    let messageId: UInt8
    let batteryLevel: UInt16
}

// TODO: (TL) #define ANKI_VEHICLE_SDK_OPTION_OVERRIDE_LOCALIZATION 0x1

// #define ANKI_VEHICLE_MSG_SDK_MODE_SIZE 3
struct VehicleMessageSDKMode { // anki_vehicle_msg_sdk_mode, ATTRIBUTE_PACKED
    let size: UInt8
    let messageId: UInt8
    let on: UInt8
    let flags: UInt8
}

// #define ANKI_VEHICLE_MSG_C2V_SET_SPEED_SIZE 6
struct VehicleMessageSetSpeed { // anki_vehicle_msg_set_speed, ATTRIBUTE_PACKED
    let size: UInt8
    let messageId: UInt8
    let speedMMPerSec: Int16 // mm/sec
    let accelMMPerSec2: Int16 // mm/sec^2
    let respectRoadPieceSpeedLimit: UInt8
}

// #define ANKI_VEHICLE_MSG_C2V_TURN_SIZE 3
struct VehicleMessageTurn { // anki_vehicle_msg_turn, ATTRIBUTE_PACKED
    let size: UInt8
    let messageId: UInt8
    let kind: UInt8
    let trigger: UInt8
}

// #define ANKI_VEHICLE_MSG_C2V_SET_OFFSET_FROM_ROAD_CENTER_SIZE 5
struct VehicleMessageSetOffsetFromRoadCenter { // anki_vehicle_msg_set_offset_from_road_center, ATTRIBUTE_PACKED
    let size: UInt8
    let messageId: UInt8
    let offsetMM: Float
}

// #define ANKI_VEHICLE_MSG_C2V_CHANGE_LANE_SIZE 11
struct VehicleMessageChangeLane { // anki_vehicle_msg_change_lane, ATTRIBUTE_PACKED
    let size: UInt8
    let messageId: UInt8
    let horizontalSpeedMMPerSec: Int8 // mm/sec
    let horizontalAccelMMPerSec2: Int8 // mm/sec^2
    let offsetFromRoadCenterMM: Float // mm
    let hopIntent: UInt8
    let tag: UInt8
}

// #define ANKI_VEHICLE_MSG_V2C_LOCALIZATION_POSITION_UPDATE_SIZE 16
struct VehicleMessageLocalizationPositionUpdate { // anki_vehicle_msg_localization_position_update, ATTRIBUTE_PACKED
    let size: UInt8
    let messageId: UInt8
    let locationId: UInt8
    let roadPieceId: UInt8
    let offsetFromRoadCenterMM: Float
    let speedMMPerSec: UInt16 // mm/sec
    let parsingFlags: UInt8

    // ACK Commands received //
    let lastRecvLaneChangeCmdId: UInt8
    let lastExecLaneChangeCmdId: UInt8
    let lastDesiredLaneChangeSpeedMMPerSec: UInt16 // mm/sec
    let lastDesiredSpeedMMPerSec: UInt16 // mm/sec
}

// #define ANKI_VEHICLE_MSG_V2C_LOCALIZATION_TRANSITION_UPDATE_SIZE 17
struct VehicleMessageLocalizationTransitionUpdate { // anki_vehicle_msg_localization_transition_update, ATTRIBUTE_PACKED
    let size: UInt8
    let messageId: UInt8
    let roadPieceIdx: Int8
    let roadPieceIdxPrev: Int8
    let offsetFromRoadCenterMM: Float

    // ACK commands received //
    let lastRecvLaneChangeId: UInt8
    let lastExecLaneChangeId: UInt8
    let lastDesiredLaneChangeSpeedMMPerSec: UInt16
    let aveFollowLineDriftPixels: Int8
    let hadLaneChangeActivity: UInt8

    // Track grade detection //
    let uphillCounter: UInt8
    let downhillCounter: UInt8

    // Wheel displacement (cm) since last transition bar //
    let leftWheelDistCM: UInt8
    let rightWheelDistCM: UInt8
}

// #define ANKI_VEHICLE_MSG_V2C_LOCALIZATION_INTERSECTION_UPDATE_SIZE 12
struct VehicleMessageLocalizationIntersectionUpdate { // anki_vehicle_msg_localization_intersection_update, ATTRIBUTE_PACKED
    let size: UInt8
    let messageId: UInt8
    let roadPieceIndex: Int8
    let offsetFromRoadCenterMM: Float
    let intersectionCode: UInt8
    let isExiting: UInt8
    let mmSinceLastTransitionBar: UInt16
    let mmSinceLastIntersectionCode: UInt16
}

// #define ANKI_VEHICLE_MSG_V2C_OFFSET_FROM_ROAD_CENTER_UPDATE_SIZE 6
struct VehicleMessageOffsetFromRoadCenterUpdate { // anki_vehicle_msg_offset_from_road_center_update, ATTRIBUTE_PACKED
    let size: UInt8
    let messageId: UInt8
    let offsetFromRoadCenterMM: Float
    let laneChangeId: UInt8
}

// #define ANKI_VEHICLE_MSG_C2V_SET_LIGHTS_SIZE 2
struct VehicleMessageSetLights { // anki_vehicle_msg_set_lights, ATTRIBUTE_PACKED
    let size: UInt8
    let messageId: UInt8
    let lightMask: UInt8 // Valid and value bits for lights (see above)
}

// #define ANKI_VEHICLE_MSG_C2V_LIGHTS_PATTERN_SIZE 17
struct VehicleMessageLightsPattern { // anki_vehicle_msg_lights_pattern, ATTRIBUTE_PACKED
    // #define LIGHT_CHANNEL_COUNT_MAX 3
    struct VehicleLightConfig { // anki_vehicle_light_config, ATTRIBUTE_PACKED
        let channel: UInt8
        let effect: UInt8
        let start: UInt8
        let end: UInt8
        let cyclesPer10Sec: UInt8
    }

    let size: UInt8
    let messageId: UInt8
    let channelCount: UInt8
    let channelConfig: [VehicleLightConfig] // LIGHT_CHANNEL_COUNT_MAX
}

// #define ANKI_VEHICLE_MSG_C2V_SET_CONFIG_PARAMS_SIZE 3
struct VehicleMessageSetConfigParams { // anki_vehicle_msg_set_config_params, ATTRIBUTE_PACKED
    let size: UInt8
    let messageId: UInt8
    let superCodeParseMask: UInt8
    let trackMaterial: UInt8
}

/* TODO: (TL) CONTINUE --v

/**
 * Create a message for setting the SDK mode.
 *
 * Note that in order to set the speed and change lanes in the current SDK,
 * the ANKI_VEHICLE_SDK_OPTION_OVERRIDE_LOCALIZATION flag must be set
 * when enabling the SDK mode.
 *
 * @param msg A pointer to the vehicle message struct to be written.
 * @param on Whether to turn SDK mode on (1) or off (0).
 * @param flags Option flags to specify vehicle behaviors while SDK mode is enabled.
 *
 * @return size of bytes written to msg
 */
uint8_t anki_vehicle_msg_set_sdk_mode(anki_vehicle_msg_t *msg, uint8_t on, uint8_t flags);

/**
 * Create a message for setting the vehicle speed.
 *
 * @param msg A pointer to the vehicle message struct to be written.
 * @param speed_mm_per_sec The requested vehicle speed in mm/sec.
 * @param accel_mm_per_sec2 The acceleration in mm/sec^2.
 *
 * @return size of bytes written to msg
 */
uint8_t anki_vehicle_msg_set_speed(anki_vehicle_msg_t *msg,
                                   uint16_t speed_mm_per_sec,
                                   uint16_t accel_mm_per_sec2);

/**
 * Create a message for setting vehicle's internal offset from road center.
 *
 * This value is stored internally in the vehicle and is used during a
 * lane change request to determine the target location. In the current
 * version of the SDK, this message is always sent to set the current offset
 * to zero before a lane change message. This allows the lane change to control
 * the relative horizontal movement of the vehicle
 *
 * @param msg A pointer to the vehicle message struct to be written.
 * @param offset_mm The offset from the road center in mm.
 *
 * @return size of bytes written to msg
 *
 * @see anki_vehicle_msg_change_lane
 */
uint8_t anki_vehicle_msg_set_offset_from_road_center(anki_vehicle_msg_t *msg, float offset_mm);

/**
 * Create a message to change the lane of driving vehicle.
 *
 * The vehicle must be moving in order for this command to be
 * executed.
 *
 * @param msg A pointer to the vehicle message struct to be written.
 * @param horizontal_speed_mm_per_sec The horizontal speed at for the lane change in mm/sec.
 * @param horizontal_accel_mm_per_sec The horizontal acceleration for the lane change in mm/sec.
 * @param offset_from_center_mm The target offset from the road center in mm.
 *
 * @return size of bytes written to msg
 */
uint8_t anki_vehicle_msg_change_lane(anki_vehicle_msg_t *msg,
                                     uint16_t horizontal_speed_mm_per_sec,
                                     uint16_t horizontal_accel_mm_per_sec2,
                                     float offset_from_center_mm);

/**
 * Create a message to set vehicle light directly using a mask.
 *
 * @param msg A pointer to the vehicle message struct to be written.
 * @param mask Mask byte representing the desired lights.
 *
 * @return size of bytes written to msg
 *
 * @see anki_vehicle_msg_set_lights_t
 */
uint8_t anki_vehicle_msg_set_lights(anki_vehicle_msg_t *msg, uint8_t mask);

/**
 * Create a vehicle lights configuration.
 *
 * @param config A pointer to the light channel configuration.
 * @param channel The target lights. See anki_vehicle_light_channel_t.
 * @param effect The type of desired effect. See anki_vehicle_light_effect_t.
 * @param start The starting intensity of the LED.
 * @param end The end intensity of the LED.
 * @param cycles_per_min The frequency repeated start->end transition phases (according to effect).
 *
 * @see anki_vehicle_light_channel_t, anki_vehicle_light_effect_t
 */
void anki_vehicle_light_config(anki_vehicle_light_config_t *config,
                               anki_vehicle_light_channel_t channel,
                               anki_vehicle_light_effect_t effect,
                               uint8_t start,
                               uint8_t end,
                               uint16_t cycles_per_min);

/**
 * Create a message to set a vehicle lights pattern.
 *
 * @param msg A pointer to the vehicle message struct to be written.
 * @param channel The target lights. See anki_vehicle_light_channel_t.
 * @param effect The type of desired effect. See anki_vehicle_light_effect_t.
 * @param start The starting intensity of the LED.
 * @param end The end intensity of the LED.
 * @param cycles_per_min The frequency repeated start->end transition phases (according to effect).
 *
 * @return size of bytes written to msg
 *
 * @see anki_vehicle_light_channel_t, anki_vehicle_light_effect_t
 */
uint8_t anki_vehicle_msg_lights_pattern(anki_vehicle_msg_t *message,
                                        anki_vehicle_light_channel_t channel,
                                        anki_vehicle_light_effect_t effect,
                                        uint8_t start,
                                        uint8_t end,
                                        uint16_t cycles_per_min);

/**
 * Create a message to set vehicle lights using light channel configurations.
 *
 * Up to 3 channel configurations can be added to a single lights_pattern message.
 *
 * @param message A pointer to the vehicle message struct to be written.
 * @param config A pointer to the light channel config to append to the message.
 *
 * @return size of appended config object or zero if nothing was appended.
 */
uint8_t anki_vehicle_msg_lights_pattern_append(anki_vehicle_msg_lights_pattern_t* message,
                                               anki_vehicle_light_config_t* config);

/**
 * Create a message to request that the vehicle disconnect.
 *
 * This is often a more reliable way to disconnect compared to closing
 * the connection to a vehicle from the central.
 *
 * @param msg A pointer to the vehicle message struct to be written.
 *
 * @return size of bytes written to msg
 */
uint8_t anki_vehicle_msg_disconnect(anki_vehicle_msg_t *msg);

/**
 * Create a message to send the vehicle a ping request.
 *
 * This will cause the vehicle to response with a message of type
 * ANKI_VEHICLE_MSG_V2C_PING_RESPONSE.
 *
 * @param msg A pointer to the vehicle message struct to be written.
 *
 * @return size of bytes written to msg
 */
uint8_t anki_vehicle_msg_ping(anki_vehicle_msg_t *msg);

/**
 * Create a message to request the vehicle firmware version.
 *
 * The vehicle will response with a anki_vehicle_msg_version_response_t message.
 *
 * @param msg A pointer to the vehicle message struct to be written.
 *
 * @return size of bytes written to msg
 */
uint8_t anki_vehicle_msg_get_version(anki_vehicle_msg_t *msg);

/**
 * Create a message to request the vehicle battery level.
 *
 * The vehicle will respond with a anki_vehicle_msg_battery_level_response_t
 * message.
 *
 * @param msg A pointer to the vehicle message struct to be written.
 *
 * @return size of bytes written to msg
 */
uint8_t anki_vehicle_msg_get_battery_level(anki_vehicle_msg_t *msg);

/**
 * Create a message to cancel a requested lane change.
 *
 * @param msg A pointer to the vehicle message struct to be written.
 *
 * @return size of bytes written to msg
 */
uint8_t anki_vehicle_msg_cancel_lane_change(anki_vehicle_msg_t *msg);

/**
 * Create a message to request a turn.
 *
 * @param msg A pointer to the vehicle message struct to be written.
 * @param type Enum value specifying the type of turn to execute. (see `see anki_vehicle_turn_type_t`)
 *             The default value is `VEHICLE_TURN_TYPE_NONE`, which is a no-op (no turn executed).
 * @param trigger Enum value specifying when to execute the turn. (see `anki_vehicle_turn_trigger_t`)
 *                The only supported value is currently `VEHICLE_TURN_TRIGGER_IMMEDIATE`,
 *                which causes the turn to be executed immediately.
 *
 * @return size of bytes written to msg
 */
uint8_t anki_vehicle_msg_turn(anki_vehicle_msg_t *msg,
                              anki_vehicle_turn_type_t type,
                              anki_vehicle_turn_trigger_t trigger);

/**
 * Create a message to request a 180 degree turn.
 *
 * @param msg A pointer to the vehicle message struct to be written.
 *
 * @return size of bytes written to msg
 */
uint8_t anki_vehicle_msg_turn_180(anki_vehicle_msg_t *msg);


/**
 * Create a message to set vehicle config parameters
 *
 * Specify parameters that modify scan-parsing or change the way that track codes are
 * iterpreted.
 *
 * This message is experimental and may change in the future.
 *
 * @param msg A pointer to the vehicle message struct to be written.
 * @param super_code_parse_mask Mask byte specifying super codes that should be parsed.
 * @param track_material Enum value specifying the material on which codes are printed.
 *
 * @return size of bytes written to msg
 */
uint8_t anki_vehicle_msg_set_config_params(anki_vehicle_msg_t* msg,
                                           uint8_t super_code_parse_mask,
                                           anki_track_material_t track_material);

ANKI_END_DECL

#endif

 */
