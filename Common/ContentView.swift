//
//  ContentView.swift
//  SwAnki Client
//
//  Created by Terry Latanville on 2019-12-29.
//  Copyright © 2019 Rndm Studio. All rights reserved.
//

import SwiftUI
import SwAnki

struct ContentView: View {
    @EnvironmentObject var vehicleController: VehicleController
    private var trackedVehicleKeys: [UUID] { vehicleController.trackedVehicles.map { $0.key }}

    var disconnectButton: some View {
        Button(action: {
            self.vehicleController.stopScanning()
        }) {
            Text("Disconnect")
        }
    }

    var connectButton: some View {
        Button(action: {
            self.vehicleController.startScanning()
        }) {
            Text("Connect")
        }
    }

    var connectionButton: some View {
        if self.vehicleController.isScanning {
            return AnyView(disconnectButton)
        } else {
            return AnyView(connectButton)
        }
    }

    var body: some View {
        NavigationView {
            ForEach(trackedVehicleKeys, id: \.self) { vehicleKey in
                NavigationLink(destination: VehicleInfoView(vehicle: self.trackedVehicle(for: vehicleKey))) {
                    VehicleStatusView(vehicle: self.trackedVehicle(for: vehicleKey))
                }
            }
            Text(self.vehicleController.latestStatusMessage)
                .padding()
                .navigationBarItems(trailing: connectionButton)
        }
    }

    private func trackedVehicle(for key: UUID) -> AnkiVehicle { vehicleController.trackedVehicles[key]! }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(VehicleController())
    }
}
