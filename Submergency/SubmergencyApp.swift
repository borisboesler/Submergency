//
//  SubmergencyApp.swift
//  Submergency
//
//  Created by Boris Boesler on 19.03.23.
//

import SwiftUI
import XCGLogger

// MARK: - Global Variables

/// Global logger
let smLogger = XCGLogger(identifier: "Submergency")

// MARK: - SubmergencyApp

@main
struct SubmergencyApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}
