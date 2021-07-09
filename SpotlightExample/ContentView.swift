//
//  ContentView.swift
//  SpotlightExample
//
//  Created by tigi KIM on 2021/07/08.
//

import SwiftUI
import Intents
import CoreSpotlight
import CoreServices

// Remember to add this to the NSUserActivityTypes array in the Info.plist file
let aType = "com.tigi44.devices-selection"

struct Device: Identifiable {
    let id: Int
    let name: String
    let price: Float
    let image: String
}

let devices = [
    Device(id: 1, name: "Macpro", price: 1000.0, image: "macpro.gen1"),
    Device(id: 2, name: "Ipod", price: 100.45, image: "ipod"),
    Device(id: 3, name: "AppleWatch", price: 500.9, image: "applewatch")
]

struct ContentView: View {
    @State private var selection: Int? = nil

    var body: some View {
        NavigationView {
            List(devices) { device in
                NavigationLink(destination: DeviceDetail(device: device),
                               tag: device.id,
                               selection: $selection,
                               label: { DeviceRow(device: device) })
            }
            .navigationTitle("Apple Devices")
            .toolbar {
                Button("AllDelete") {
                    NSUserActivity.deleteAllSavedUserActivities {
                        print("done!")
                    }
                }
            }

        }
        .onContinueUserActivity(aType, perform: { userActivity in
            if let deviceId = userActivity.userInfo?["deviceId"] as? NSNumber {
                selection = deviceId.intValue
            }
        })
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct DeviceRow: View {
    let device: Device

    var body: some View {
        HStack {
            Image(systemName: device.image)
                .resizable()
                .frame(width: 80, height: 80)

            VStack(alignment: .leading) {
                Text("\(device.name)").font(.title).fontWeight(.bold)
                Text("$ \(String(format: "%0.2f", device.price))").font(.subheadline)
                Spacer()
            }
        }
    }
}

struct DeviceDetail: View {
    let device: Device

    var body: some View {
        VStack {
            Text("\(device.name)").font(.title).fontWeight(.bold)
            Text("$ \(String(format: "%0.2f", device.price))").font(.subheadline)

            Image(systemName: device.image)
                .resizable()
                .scaledToFit()

            Spacer()
        }
        .userActivity(aType) { userActivity in
            userActivity.isEligibleForSearch = true
            userActivity.title = "\(device.name)"
            userActivity.userInfo = ["deviceId": device.id]

            let attributes = CSSearchableItemAttributeSet(itemContentType: kUTTypeItem as String)

            attributes.contentDescription = "Get a Greate Device!"
            attributes.thumbnailData = UIImage(systemName: device.image)?.pngData()
            userActivity.contentAttributeSet = attributes

            print("Advertising: \(device.name)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
