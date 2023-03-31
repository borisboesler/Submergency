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
  @EnvironmentObject var diveSessionManager: DiveSessionManager
  /// TODO: make maxSecondDelta editable in GUI
  let maxSecondDelta = 15.0 * 60.0
  var body: some View {
    VStack {
      Image(systemName: "globe")
        .imageScale(.large)
        .foregroundColor(.accentColor)
      // Text("Hello, \(NSFullUserName())!")
      Text("Version: \(bundleShortVersion)")
      Text("Bundle version: \(bundleVersion)")

      Spacer()
      Button("Dump") {
        print("dump")
        diveSessionManager.log()
      }
      Spacer()

      if diveSessionManager.sessions.count > 0 {
        List(diveSessionManager.sessions, id: \.self) { diveSession in
          // NavigationLink(destination: DiveExportView(dive: dive, temps: HKViewModel.temps)) {
          DiveSessionRowView(diveSession: diveSession)
          // }
        }
      } else {
        Spacer()
        Text("No dive data in HealthKit").fontWeight(.bold)
        Spacer()
      }
    }
    .padding()
    .onAppear {
      diveSessionManager.readDiveDepths(maxSecondDelta: maxSecondDelta)
    }
  } // var body

  // MARK: - methods
}

// MARK: - ContentView_Previews

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView().environmentObject(DiveSessionManager())
  }
}
