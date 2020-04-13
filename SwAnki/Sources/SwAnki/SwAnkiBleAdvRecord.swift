//
//  SwAnkiBleAdvRecord.swift
//
//
//  Created by Terry Latanville on 2019-12-29.
//

// Adapted from
// https://github.com/anki/drive-sdk/blob/master/src/eir.h

enum BleAdvRecordType: UInt8 { // ble_adv_record_type
    case invalid = 0 // ADV_TYPE_INVALID
    case flags = 0x1 // ADV_TYPE_FLAGS
    case uuid = 0x7 // ADV_TYPE_UUID_128
    case localName = 0x9 // ADV_TYPE_LOCAL_NAME
    case txPower = 0xa // ADV_TYPE_TX_POWER
    case manufacturerData = 0xff // ADV_TYPE_MANUFACTURER_DATA
}

/*
int ble_adv_parse_scan(const uint8_t *data, const size_t data_len, size_t *record_count, ble_adv_record_t records[])
{
    // no data to parse
    if (data == NULL)
        return 1;

    uint8_t record_index = 0;
    int i = 0;
    while (i < data_len) {
        uint8_t len = data[i++];
        if (len == 0)   break;

        ble_adv_record_type_t type = data[i];
        if (type == ADV_TYPE_INVALID)   break;

        if (records != NULL) {
            ble_adv_record_t *record = &records[record_index];
            record->type = type;
            record->length = (len-1);
            memmove(record->data, &data[i+1], len-1);
        }

        record_index++;
        i += len;
    }

    if (record_count != NULL) {
        *record_count = record_index;
    }

    return 0;
}
 */

struct BleAdvRecord { // ble_adv_record
    static let maxLength = 32 // BLE_ADV_RECORD_MAX_LEN
    let recordType: UInt8
    let length: UInt8
    let data: [UInt8] // Max length == 30
}
