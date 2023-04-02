//
//  DiveRowView.swift
//  Submergency
//
//  Created by Boris Boesler on 29.03.23.
//

import SwiftUI

// MARK: - DiveSessionRowView

struct DiveSessionRowView: View {
  let diveSession: DiveSession

  /// local date formatter for this view
  static let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale.autoupdatingCurrent
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
  }()

  var body: some View {
    // TODO: this looks different in the simulator and on the device
    let duration = Int((diveSession.duration() + 59.0) / 60.0)
    HStack {
      Text(DiveSessionRowView.dateFormatter.string(from: diveSession.start))
        .frame(width: 150, alignment: .leading)

      Text("\(duration)min")
        .frame(width: 70, alignment: .trailing)

      Text(String(format: "%.1fm", diveSession.maxDepth()))
        .frame(width: 60, alignment: .trailing)
    }
    #if DEBUG
      .background(Color.yellow)
    #endif
  }
}

// MARK: - DiveRowView_Previews

struct DiveRowView_Previews: PreviewProvider {
  static var previews: some View {
    DiveSessionRowView(diveSession: DiveSession(ident: 0,
                                                sample: DiveSample(start: Date.now,
                                                                   end: Date.now.addingTimeInterval(100.0 * 60.0),
                                                                   depth: 100.234)))
  }
}
