//
//  VehicleInfoView.swift
//  SwAnki Client
//
//  Created by Terry Latanville on 2020-01-16.
//  Copyright © 2020 Rndm Studio. All rights reserved.
//

import SwiftUI
import SwAnki
import CoreBluetooth

struct VehicleInfoView: View {
    let vehicle: AnkiVehicle
    var batteryConditionView: some View {
        HStack {
            Text("Battery Level:")
            Spacer()
            if vehicle.metadata.vehicleInfo.state.fullBattery {
                Color(.green)
                    .frame(width: 38)
                    .cornerRadius(8)
            } else if vehicle.metadata.vehicleInfo.state.lowBattery {
                Color(.red)
                    .frame(width: 38)
                    .cornerRadius(8)
            }
        }
    }

    var body: some View {
        Form {
            Section(header: Text("Vehicle Info")) {
                Text("Identifier: \(vehicle.metadata.manufacturerInfo.identifier)")
                Text("Name: \(vehicle.metadata.vehicleInfo.name)")
                Text("Version: \(vehicle.metadata.vehicleInfo.version)")
            }
            Section(header: Text("Manufacturer Info")) {
                Text("Product ID: \(vehicle.metadata.manufacturerInfo.productId)")
                Text("Model ID: \(vehicle.metadata.manufacturerInfo.modelId)")
            }
            Section(header: Text("State Info")) {
                // TODO: (TL) Toggle?
                Text("State: \(vehicle.peripheral.state == .connected ? "Connected" : "Not Connected")")
                batteryConditionView
                HStack {
                    Text("Charging:")
                    Spacer()
                    if vehicle.metadata.vehicleInfo.state.onCharger {
                        Color(.green)
                            .frame(width: 38)
                            .cornerRadius(8)
                    } else {
                        Color(.lightGray)
                            .frame(width: 38)
                            .cornerRadius(8)
                    }
                }
            }
        }
    }
}

struct VehicleInfoView_Previews: PreviewProvider {
    static var previews: some View {
        // TODO: (TL) VehicleInfoView()
        Text("TODO: VehicleInfoView preview")
    }
}
