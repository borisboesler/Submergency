//
//  ContentView.swift
//  Submergency
//
//  Created by Boris Boesler on 19.03.23.
//

import HealthKit
import SwiftUI
import Foundation

private let bundleVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "no build"
private let bundleShortVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "no version"

// MARK: - ContentView

struct ContentView: View {
  private var healthStore: HealthStoreInterface?

  var body: some View {
    VStack {
      Image(systemName: "globe")
        .imageScale(.large)
        .foregroundColor(.accentColor)
      Text("Hello, \(NSFullUserName())!")
      Text("Version: \(bundleShortVersion)")
      Text("Bundle version: \(bundleVersion)")
    }
    .padding()
  } // var body

  // MARK: - methods

  init() {
    smLogger.info("init")
    healthStore = HealthStoreInterface()
    initialization()
  }

  private func initialization() {
    smLogger.info("initialization")
    if let healthStore = healthStore {
      healthStore.requestAuthorization { success in
        if success {
          //healthStore.readGenderType()
          healthStore.readDepthType() { query in
//            for session in query {
//              session.log()
//            }
            query?.log()
          }
        } else {
          smLogger.info(" ContentView.requestAuthorization failed")
        }
      }
    }
  } // private func initilization()
}

// MARK: - ContentView_Previews

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
