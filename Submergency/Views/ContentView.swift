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
  /// TODO: make maxSecondDelta editable in GUI
  let maxSecondDelta = 15.0 * 60.0
  @EnvironmentObject var diveSessionManager: DiveSessionManager
  var body: some View {
    NavigationView {
      VStack {
        if diveSessionManager.diveSessions.count > 0 {
          List(diveSessionManager.diveSessions, id: \.self) { diveSession in
            NavigationLink(destination: DiveSessionView(diveSession: diveSession)) {
              DiveSessionRowView(diveSession: diveSession)
            }
          }
        } else {
          Spacer()
          Text("No dive data in HealthKit").fontWeight(.bold)
          Spacer()
        }
      }
      #if DEBUG
        .background(Color.red)
      #endif
        .padding()
        .onAppear {
          // FIXME: this does a repeated reload of data
          diveSessionManager.readDiveSamples(maxSecondDelta: maxSecondDelta)
          diveSessionManager.readDiveTemperatures()
        }
        .navigationBarTitle(appName)
      #if DEBUG
        .navigationBarItems(
          leading:
          Button(action: {
            diveSessionManager.log()
          }, label: { Text("Dump") }),
          trailing:
          NavigationLink(destination: AboutView()) {
            HStack {
              Image(systemName: "info.circle")
                .imageScale(.large)
            }
          }
        )
      #else
          .navigationBarItems(
            trailing:
            NavigationLink(destination: AboutView()) {
              HStack {
                Image(systemName: "info.circle")
                  .imageScale(.large)
              }
            }
          )
      #endif
    } // NavigationView
  } // var body

  // MARK: - methods
}

// MARK: - ContentView_Previews

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView().environmentObject(DiveSessionManager())
  }
}
