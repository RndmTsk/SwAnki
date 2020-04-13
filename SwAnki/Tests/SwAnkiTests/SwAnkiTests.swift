import XCTest
@testable import SwAnki

final class SwAnkiTests: XCTestCase {
    // MARK: - Data+LittleEndianSlice Tests
    static let testData = Data([0x0, 0x1, 0x2, 0x3, 0x4, 0x5, 0x6, 0x7, 0x8])
    func testDataSubscriptUInt16() {
        let data0 = UInt16(SwAnkiTests.testData[0])
        let data1 = UInt16(SwAnkiTests.testData[1])

        let expectedResult = data1 | (data0 << 8)
        let actualResult = SwAnkiTests.testData[UInt16.self, 0..<2]
        XCTAssertEqual(expectedResult, actualResult, "Expected: \(expectedResult), Got: \(actualResult)")
    }

    func testDataSubscriptUInt32() {
        let data0 = UInt32(SwAnkiTests.testData[0])
        let data1 = UInt32(SwAnkiTests.testData[1])
        let data2 = UInt32(SwAnkiTests.testData[2])
        let data3 = UInt32(SwAnkiTests.testData[3])

        let expectedResult = data3 | (data2 << 8) | (data1 << 16) | (data0 << 24)
        let actualResult = SwAnkiTests.testData[UInt32.self, 0..<4]
        XCTAssertEqual(expectedResult, actualResult, "Expected: \(expectedResult), Got: \(actualResult)")
    }

    // MARK: - AnkiAdvertisements Tests
    func testAnkiManufacturerInfo() {
        let rawBytes: [UInt8] = [0xbe, 0xef, 0x00, 0x0c, 0x00, 0x56, 0xb3, 0x65]
        let rawData = Data(rawBytes)
        let manufacturerInfo = AnkiManufacturerInfo(data: rawData)
        XCTAssertNotNil(manufacturerInfo, "Expected successful creation of `AnkiManufacturerInfo`")

        let expectedIdentifier: UInt32 = 0x56B365
        XCTAssertEqual(manufacturerInfo!.identifier, expectedIdentifier, "Expected Identifier: \(expectedIdentifier), got: \(String(describing: manufacturerInfo?.identifier))")

        let expectedModelId: UInt8 = 0xc
        XCTAssertEqual(manufacturerInfo!.modelId, expectedModelId, "Expected Model ID: \(expectedModelId), got: \(String(describing: manufacturerInfo?.modelId))")

        let expectedProductId: UInt16 = 0xbeef
        XCTAssertEqual(manufacturerInfo!.productId, expectedProductId, "Expected Product ID: \(expectedProductId), got: \(String(describing: manufacturerInfo?.productId))")
    }

    func testEmptyAnkiManufacturerInfo() {
        let manufacturerInfo = AnkiManufacturerInfo(data: nil)
        XCTAssertNil(manufacturerInfo, "Expected unsuccessful creation of `AnkiManufacturerInfo`")
    }

    func testAnkiVehicleStateFullBattery() {
        // Full Battery, nothing else
        let flag: UInt8 = .ankiFullBatteryFlag
        let vehicleState = AnkiVehicleState(data: flag)
        XCTAssertTrue(vehicleState.fullBattery, "Expected Full Battery flag set")
        XCTAssertFalse(vehicleState.lowBattery, "Expected Low Battery flag unset")
        XCTAssertFalse(vehicleState.onCharger, "Expected On Charger flag unset")
    }

    func testAnkiVehicleStateLowBattery() {
        // Low Battery, nothing else
        let flag: UInt8 = .ankiLowBatteryFlag
        let vehicleState = AnkiVehicleState(data: flag)
        XCTAssertFalse(vehicleState.fullBattery, "Expected Full Battery flag unset")
        XCTAssertTrue(vehicleState.lowBattery, "Expected Low Battery flag set")
        XCTAssertFalse(vehicleState.onCharger, "Expected On Charger flag unset")
    }

    func testAnkiVehicleStateFullBatteryOnCharger() {
        // Full Battery and On Charger
        let flag: UInt8 = .ankiOnChargerFlag | .ankiFullBatteryFlag
        let vehicleState = AnkiVehicleState(data: flag)
        XCTAssertTrue(vehicleState.fullBattery, "Expected Full Battery flag set")
        XCTAssertFalse(vehicleState.lowBattery, "Expected Low Battery flag unset")
        XCTAssertTrue(vehicleState.onCharger, "Expected On Charger flag set")
    }

    func testAnkiVehicleStateLowBatteryOnCharger() {
        // Low Battery and On Charger
        let flag: UInt8 = .ankiLowBatteryFlag | .ankiOnChargerFlag
        let vehicleState = AnkiVehicleState(data: flag)
        XCTAssertFalse(vehicleState.fullBattery, "Expected Full Battery flag set")
        XCTAssertTrue(vehicleState.lowBattery, "Expected Low Battery flag unset")
        XCTAssertTrue(vehicleState.onCharger, "Expected On Charger flag set")
    }

    func testInvalidAnkiVehicleState() {
        // Invalid flags
        let vehicleState = AnkiVehicleState(data: 0)
        XCTAssertFalse(vehicleState.fullBattery, "Expected Full Battery flag unset")
        XCTAssertFalse(vehicleState.lowBattery, "Expected Low Battery flag unset")
        XCTAssertFalse(vehicleState.onCharger, "Expected On Charger flag unset")
    }

    func testAnkiVehicleInfo() {
        let rawVehicleInfo = String(bytes: [0x10, 0x60, 0x30, 0x01, 0x20, 0x20, 0x20, 0x20, 0x44, 0x72, 0x69, 0x76, 0x65], encoding: .utf8)
        let vehicleInfo = AnkiVehicleInfo(string: rawVehicleInfo)
        XCTAssertNotNil(vehicleInfo, "Expected successful creation of `AnkiVehicleInfo`")
        XCTAssertTrue(vehicleInfo!.state.fullBattery, "Expected Full Battery flag set")
        XCTAssertFalse(vehicleInfo!.state.lowBattery, "Expected Low Battery flag unset")
        XCTAssertFalse(vehicleInfo!.state.onCharger, "Expected On Charger flag unset")
        XCTAssertEqual(vehicleInfo!.version, 96, "Expected vehicle version 96, got: \(String(describing: vehicleInfo?.version))")
        XCTAssertEqual(vehicleInfo!.name, "Drive", "Expected vehicle name 'Drive', got: \(String(describing: vehicleInfo?.name))")
    }

    func testEmptyAnkiVehicleInfo() {
        let vehicleInfo = AnkiVehicleInfo(string: nil)
        XCTAssertNil(vehicleInfo, "Expected unsuccessful creation of `AnkiVehicleInfo`")
    }
    // TODO: (TL) ...
    // AnkiAdvertisements
    // AnkiManufacturerInfo
    // AnkiServices

    static var allTests = [
        // Data+LittleEndianSlice Tests
        ("testDataSubscriptUInt16", testDataSubscriptUInt16),
        ("testDataSubscriptUInt32", testDataSubscriptUInt32),
        // ...
    ]
}
