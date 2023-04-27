//
//  ConfigView.swift
//  Submergency
//
//  Created by Boris Boesler on 27.04.23.
//

import SwiftUI

// MARK: - User settings

let defaults = UserDefaults.standard
let defaultDiveSessionBreak: Double = defaults.object(forKey: "DiveSessionBreak") as? Double ?? 15.0

// MARK: - ConfigView

struct ConfigView: View {
  /// some constants
  let minDiveSessionBreak = 0.0
  let maxDiveSessionBreak = 60.0

  /// session break from ContentView
  @Binding var diveSessionBreakMinutes: Double

  var body: some View {
    VStack {
      Text("Dive Session Break: \(diveSessionBreakMinutes, specifier: "%2.1f")min")
      Slider(value: $diveSessionBreakMinutes, in: minDiveSessionBreak ... maxDiveSessionBreak, step: 1.0,
             onEditingChanged: { _ in
               // store value in user defaults
               defaults.set(diveSessionBreakMinutes, forKey: "DiveSessionBreak")
             })
             .accentColor(Color.green)
    } // VStack
    .padding(10)
  }
}

#if false

  // MARK: - ConfigView_Previews

  struct ConfigView_Previews: PreviewProvider {
    @State private var diveSessionBreakMinutes = 15.0

    static var previews: some View {
      ConfigView(diveSessionBreakMinutes: $diveSessionBreakMinutes)
    }
  }
#endif
