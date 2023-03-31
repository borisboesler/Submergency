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

  static let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd/MM/yyyy hh:mm a"
    return formatter
  }()

  var body: some View {
    let duration = Int((diveSession.duration() + 59.0) / 60.0)
    HStack {
      Text(DiveSessionRowView.dateFormatter.string(from: diveSession.start))
        .frame(width: 180, alignment: .leading)

      Text("\(duration)min")
        .frame(width: 50, alignment: .trailing)

      Text(String(format: "%.1fm", diveSession.maxDepth()))
        .frame(width: 50, alignment: .trailing)
    }
  }
}

// MARK: - DiveRowView_Previews

struct DiveRowView_Previews: PreviewProvider {
  static var previews: some View {
    DiveSessionRowView(diveSession: DiveSession(ident: 0,
                                                sample: DiveSample(start: Date.now,
                                                                   end: Date.now,
                                                                   depth: 1.234)))
  }
}
