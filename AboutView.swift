//
//  AboutView.swift
//  Submergency
//
//  Created by Boris Boesler on 02.04.23.
//

import SwiftUI

private let bundleVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "no build"
private let bundleShortVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "no version"

// MARK: - AboutView

struct AboutView: View {
  var body: some View {
    VStack {
      Spacer()
      Text(appName)
        .font(.title)
      Spacer()
      Text("Copyright ©2023 Boris Boesler")
        .font(.title2)
      Spacer()
      Text("Version: \(bundleShortVersion)")
        .font(.title2)
      #if DEBUG
        Spacer()
        VStack {
          Text("DEBUG Build")
          Text("Bundle version: \(bundleVersion)")
        }
        .padding(5)
        .background(Color.red)
        .cornerRadius(10)
      #endif
      Spacer()
    }
    .padding(5)
    .navigationBarTitle("About " + appName, displayMode: .inline)
  }
}

// MARK: - AboutView_Previews

struct AboutView_Previews: PreviewProvider {
  static var previews: some View {
    AboutView()
  }
}
