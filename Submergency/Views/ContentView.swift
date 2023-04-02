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
    NavigationView {
      VStack {
        if diveSessionManager.sessions.count > 0 {
          List(diveSessionManager.sessions, id: \.self) { diveSession in
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
          diveSessionManager.readDiveDepths(maxSecondDelta: maxSecondDelta)
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
