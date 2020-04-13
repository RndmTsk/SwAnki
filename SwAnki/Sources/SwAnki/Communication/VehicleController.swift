//
//  VehicleController.swift
//  SwAnki
//
//  Created by Terry Latanville on 2020-01-08.
//  Copyright © 2020 Rndm Studio. All rights reserved.
//

import CoreBluetooth
import Combine

// TODO: (TL) Better logging in all functions
// TODO: (TL) Refactor VehicleControllerDelegate to use Result in some cases?

public protocol VehicleControllerDelegate: AnyObject {
    func controllerDidStartScanning(_ vehicleController: VehicleController)
    func controller(_ vehicleController: VehicleController, didStartTracking vehicle: AnkiVehicle)
    func controller(_ vehicleController: VehicleController, didStopTracking vehicle: AnkiVehicle)
    func controller(_ vehicleController: VehicleController, didConnectTo vehicle: AnkiVehicle)
    func controller(_ vehicleController: VehicleController, failedConnectingTo vehicle: AnkiVehicle, error: Error)
    func controller(_ vehicleController: VehicleController, didEncounter error: Error)
}

public final class VehicleController: NSObject, ObservableObject {
    // MARK: - Errors
    public enum Error: Swift.Error {
        case unspecified
        case message(String)
    }

    // MARK: - Properties
    @Published public var trackedVehicles: [UUID: AnkiVehicle] = [:]
    @Published public var latestStatusMessage: String = ""
    public var isScanning: Bool { manager.isScanning }
    public weak var delegate: VehicleControllerDelegate?
    private lazy var dispatchQueue = DispatchQueue(label: "com.swanki.command.queue")
    private lazy var manager = CBCentralManager(delegate: self, queue: dispatchQueue, options: nil)
    private var scanWasRequested = false

    public func startScanning() {
        guard manager.state == .poweredOn else {
            scanWasRequested = true
            return
        }
        delegate?.controllerDidStartScanning(self)
        manager.scanForPeripherals(withServices: [.ankiService], options: nil)
    }

    public func stopScanning() {
        scanWasRequested = false
        guard manager.state == .poweredOn else { return }
        manager.stopScan()
    }
}

// MARK: - <CBCentralManagerDelegate>
extension VehicleController: CBCentralManagerDelegate {
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard central.state == .poweredOn else {
            delegate?.controller(self, didEncounter: Error.message("Central Manager State: \(central.state.debugDescription)"))
            return
        }
        if scanWasRequested {
            scanWasRequested = false
            startScanning()
        }
    }

    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard let metadata = AnkiVehicleMetadata(advertisementData: advertisementData) else {
            delegate?.controller(self, didEncounter: Error.message("Unrecognized advertisement data: \(advertisementData)"))
            return
        }
        guard trackedVehicles[peripheral.identifier] == nil else {
            delegate?.controller(self, didEncounter: Error.message("Already tracking \(peripheral.identifier), ignoring"))
            return
        }
        let newVehicle = AnkiVehicle(metadata: metadata, peripheral: peripheral)
        print("== Found new vehicle ==\n\(newVehicle)")
        DispatchQueue.main.async {
            self.trackedVehicles[peripheral.identifier] = newVehicle
        }
        delegate?.controller(self, didStartTracking: newVehicle)
        central.connect(newVehicle.peripheral, options: nil) // TODO: (TL) What are valid `options`?
    }

    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        guard let trackedVehicle = trackedVehicles[peripheral.identifier] else {
            delegate?.controller(self, didEncounter: Error.message("Connected to an untracked vehicle: \(peripheral), aborting."))
            central.cancelPeripheralConnection(peripheral)
            return
        }
        delegate?.controller(self, didConnectTo: trackedVehicle)
        trackedVehicle.discoverServices()
    }

    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Swift.Error?) {
        guard let trackedVehicle = trackedVehicles.removeValue(forKey: peripheral.identifier) else {
            delegate?.controller(self, didEncounter: Error.message("Skipping attempt to disconnect untracked peripheral: \(peripheral)"))
            return
        }
        delegate?.controller(self, didStopTracking: trackedVehicle)
    }

    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Swift.Error?) {
        guard let trackedVehicle = trackedVehicles.removeValue(forKey: peripheral.identifier) else {
            delegate?.controller(self, didEncounter: Error.message("Failed to connect untracked vehicle: \(peripheral)"))
            return
        }
        delegate?.controller(self, failedConnectingTo: trackedVehicle, error: error ?? Error.unspecified)
    }
}
