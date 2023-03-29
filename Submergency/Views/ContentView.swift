//
//  ContentView.swift
//  Submergency
//
//  Created by Boris Boesler on 19.03.23.
//

import Foundation
import HealthKit
import SwiftUI

private let bundleVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "no build"
private let bundleShortVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "no version"

// MARK: - ContentView

struct ContentView: View {
  private var healthStore: HealthStoreInterface?
  private var diveSessionManager: DiveSessionManager?
  /// TODO: make maxSecondDelta editable in GUI
  let maxSecondDelta = 15.0 * 60.0
  var body: some View {
    VStack {
      Image(systemName: "globe")
        .imageScale(.large)
        .foregroundColor(.accentColor)
      Text("Hello, \(NSFullUserName())!")
      Text("Version: \(bundleShortVersion)")
      Text("Bundle version: \(bundleVersion)")

      Spacer()

      Button("Dump") {
        print("dump")
        diveSessionManager!.log()
      }

      Spacer()
    }
    .padding()
  } // var body

  // MARK: - methods

  init() {
    smLogger.info("init")
    healthStore = HealthStoreInterface()
    diveSessionManager = DiveSessionManager()

    if let healthStore = healthStore {
      if var diveSessionManager = diveSessionManager {
        healthStore.requestAuthorization { success in
          if success {
            healthStore.readDepthType { query in
              // TODO: use maxSecondDelta here
              diveSessionManager.add(sample: query, maxSecondDelta: 15.0 * 60.0)
            }
          } else {
            smLogger.info(" ContentView.requestAuthorization failed")
          }
        }
      }
    }
  }
}

// MARK: - ContentView_Previews

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
