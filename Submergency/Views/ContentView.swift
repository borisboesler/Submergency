//
//  ContentView.swift
//  Submergency
//
//  Created by Boris Boesler on 19.03.23.
//

import Foundation
import HealthKit
import SwiftUI

// MARK: - ContentView

struct ContentView: View {
  /// dive session break in minutes
  @State private var diveSessionBreakMinutes: Double = defaultDiveSessionBreak
  /// the dive session manager
  @EnvironmentObject var diveSessionManager: DiveSessionManager

  var body: some View {
    NavigationStack {
      VStack {
        if diveSessionManager.diveSessions.count > 0 {
          List(diveSessionManager.diveSessions.sorted(by: { $0.start > $1.start }), id: \.self) { diveSession in
            NavigationLink(destination: DiveSessionView(diveSession: diveSession)) {
              DiveSessionRowView(diveSession: diveSession)
            }
          }
        } else {
          Spacer()
          Text("No dive data in HealthKit").fontWeight(.bold)
          Spacer()
        }
      } // VStack
      #if DEBUG
        .background(Color.red)
      #endif
        .padding()
        .onAppear {
          diveSessionManager.readSource()
          diveSessionManager.readDiveSamples(maxSecondDelta: diveSessionBreakMinutes * 60.0)
          diveSessionManager.readDiveTemperatures()
        }
        .navigationTitle(appName)
        .toolbar {
          #if DEBUG
            ToolbarItem(placement: .navigationBarLeading) {
              Button(action: { diveSessionManager.log() }, label: { Text("Dump") })
            }
          #endif
          ToolbarItem(placement: .navigationBarTrailing) {
            NavigationLink(destination: ConfigView(diveSessionBreakMinutes: $diveSessionBreakMinutes)) {
              Image(systemName: "gearshape").imageScale(.large)
            }
          }
          ToolbarItem(placement: .navigationBarTrailing) {
            NavigationLink(destination: AboutView()) {
              Image(systemName: "info.circle").imageScale(.large)
            }
          }
        } // toolbar
    } // NavigationStack
  } // var body

  // MARK: - Methods
}

// MARK: - ContentView_Previews

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView().environmentObject(DiveSessionManager())
  }
}
