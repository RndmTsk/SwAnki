//
//  VehicleView.swift
//  SwAnki Client
//
//  Created by Terry Latanville on 2020-01-16.
//  Copyright © 2020 Rndm Studio. All rights reserved.
//

import SwiftUI
import SwAnki

struct VehicleStatusView: View {
    let vehicle: AnkiVehicle
    var connectionStateView: some View {
        if vehicle.isConnected {
            return AnyView(Color(.blue))
        } else {
            return AnyView(Color(.green))
        }
    }
    var body: some View {
        HStack {
            connectionStateView
                .frame(width: 44)
                .cornerRadius(8)
            Text(vehicle.metadata.vehicleInfo.name)
            Spacer()
        }
        .frame(height: 44)
        .padding()
    }
}

struct VehicleStatusView_Previews: PreviewProvider {
    static var previews: some View {
        Text("TODO: Preview not implemented")
        // TODO: T(L) VehicleView()
    }
}
