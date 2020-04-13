//
//  AnkiVehicle.swift
//  
//
//  Created by Terry Latanville on 2020-01-13.
//

import CoreBluetooth

public final class AnkiVehicle: NSObject {
    // MARK: - Properties 
    public let metadata: AnkiVehicleMetadata
    public let peripheral: CBPeripheral
    public private(set) var isConnected = false
    private var readCharacteristic: CBCharacteristic?
    private var writeCharacteristic: CBCharacteristic?

    // MARK: - Lifecycle Functions
    public init(metadata: AnkiVehicleMetadata, peripheral: CBPeripheral) {
        self.metadata = metadata
        self.peripheral = peripheral
        super.init()
        self.peripheral.delegate = self
    }

    deinit {
        peripheral.delegate = nil
    }

    // MARK: - Functions
    public func discoverServices() {
        peripheral.discoverServices(nil) // All services
    }

    private func send(_ command: ControllerMessage) {
        precondition(writeCharacteristic != nil, "No valid write characteristic!")
        let data = Data(command.payload)
        print("Sending \(command) (Raw: \(command.payload))")
        peripheral.writeValue(data, for: writeCharacteristic!, type: .withoutResponse)
    }
}

// MARK: - <CBPeripheralDelegate>
extension AnkiVehicle: CBPeripheralDelegate {
    public func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
        print("peripheralDidUpdateName(_: \(peripheral))")
    }

    public func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        print("peripheral(_: \(peripheral), didReadRSSI: \(RSSI), error: \(String(describing: error)))")
    }

    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("peripheral(_: \(peripheral), didDiscoverServices: \(String(describing: error)))")
        guard error == nil else {
            print("Encountered error discovering peripheral services: \(error?.localizedDescription ?? "Unknown error")")
            return
        }
        // Only care about the first service as it contains the read and write characteristics in an Anki vehicle
        guard let ankiService = peripheral.services?.first else {
            print("Peripheral has no services")
            // TODO: (TL) Disconnect
            return
        }
        print("Discovered peripheral service: \(ankiService) [\(CBUUID.ankiService)]")
        peripheral.discoverCharacteristics([.ankiReadCharacteristic, .ankiWriteCharacteristic], for: ankiService)
    }

    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("peripheral(_: \(peripheral), didDiscoverCharacteristicsFor: \(service), error: \(String(describing: error)))")
        guard error == nil else {
            print("Encountered error: \(error!) while discovering services for: \(peripheral)")
            return
        }
        readCharacteristic = service.characteristics?.first { $0.uuid == .ankiReadCharacteristic }
        print("Read Characteristic: \(String(describing: readCharacteristic))")

        writeCharacteristic = service.characteristics?.first { $0.uuid == .ankiWriteCharacteristic }
        print("Write Characteristic: \(String(describing: writeCharacteristic))")
        guard let readCharacteristic = readCharacteristic else {
            // TODO: (TL) Disconnect
            print("No valid readCharacteristic found for service: \(service)")
            return
        }
        peripheral.setNotifyValue(true, for: readCharacteristic)
        isConnected = true
        // TODO: (TL) Set SDK mode
    }

    public func peripheral(_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService, error: Error?) {
        print("peripheral(_: \(peripheral), didDiscoverIncludedServicesFor: \(service), error: \(String(describing: error)))")
    }

    public func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        print("peripheral(_: \(peripheral), didModifyServices: \(invalidatedServices))")
    }

    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("peripheral(_: \(peripheral), didUpdateValueFor: \(characteristic), error: \(String(describing: error)))")
    }

    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print("peripheral(_: \(peripheral), didWriteValueFor: \(characteristic), error: \(String(describing: error)))")
    }

    public func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("peripheral(_: \(peripheral), didUpdateNotificationStateFor: \(characteristic), error: \(String(describing: error)))")
    }

    public func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        print("peripheral(_: \(peripheral), didDiscoverDescriptorsFor: \(characteristic), error: \(String(describing: error)))")
    }

    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        print("peripheral(_: \(peripheral), didUpdateValueFor: \(descriptor), error: \(String(describing: error)))")
    }

    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        print("peripheral(_: \(peripheral), didWriteValueFor: \(descriptor), error: \(String(describing: error)))")
    }

    public func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
        print("peripheral(_: \(peripheral), toSendWriteWithoutResponse: \(peripheral))")
    }

    public func peripheral(_ peripheral: CBPeripheral, didOpen channel: CBL2CAPChannel?, error: Error?) {
        print("peripheral(_: \(peripheral), didOpen: \(String(describing: channel)), error: \(String(describing: error)))")
    }
}
