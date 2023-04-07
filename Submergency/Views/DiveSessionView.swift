//
//  DiveSessionView.swift
//  Submergency
//
//  Created by Boris Boesler on 02.04.23.
//

import Charts
import SwiftUI

// MARK: - DiveSessionView

let displayTemperatureGraph = true

// MARK: - DiveSessionView

struct DiveSessionView: View {
  let diveSession: DiveSession

  /// local date formatter for this view
  static let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale.autoupdatingCurrent
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
  }()

  /// local date formatter for sessions
  static let durationFormatter: DateComponentsFormatter = {
    let formatter = DateComponentsFormatter()
    formatter.unitsStyle = .abbreviated
    formatter.zeroFormattingBehavior = .dropAll
    formatter.allowedUnits = [.hour, .minute, .second]
    return formatter
  }()

  var body: some View {
    VStack {
      HStack {
        // basic info
        Text("\(DiveSessionView.dateFormatter.string(from: diveSession.start))")
        // TODO: should we skip the hours?
        Text("\(DiveSessionView.durationFormatter.string(from: diveSession.duration()) ?? "0")")
        Text(String(format: "%.1fm", diveSession.maxDepth()))
      }

      // a dive profile
      Divider()

      GroupBox("Dive Session Profile") {
        // ScrollView(.vertical, showsIndicators: true) {
        Chart {
          // depth
          ForEach(diveSession.profile) { sample in
            // TODO: fill gaps with time at depth 0m
            LineMark(
              x: .value("Time", sample.start),
              y: .value("Depth", -sample.depth)
            )
            .foregroundStyle(by: .value("Value", "Depth"))
            .interpolationMethod(.stepStart)
          }
          #if false
            // temperature
            ForEach(diveSession.profile) { sample in
              LineMark(
                x: .value("Time", sample.start),
                y: .value("Temperature", sample.temp?.temp ?? 0.0)
              )
              .foregroundStyle(by: .value("Value", "Temperature"))
              .interpolationMethod(.stepStart)
            }
          #endif
        } // Chart
        // .frame(width: diveSession.duration())
        // move depth axis to the left
        .chartYAxis {
          AxisMarks(position: .leading)
          #if false
            // should be from:35 to:0, but then axis is moved to .leading
            AxisMarks(position: .trailing
              // , values: Array(stride(from: 0, through: 35, by: 5))
            )
          #endif
        }

        // background
        .chartPlotStyle { plotArea in
          plotArea
            .background(.blue.opacity(0.1))
        }
        // } // ScrollView
      } // GroupBox
    } // VStack
  } // body
}

// MARK: - DiveSessionView_Previews

struct DiveSessionView_Previews: PreviewProvider {
  static var previews: some View {
    DiveSessionView(diveSession: DiveSession(sample: DiveSample(start: Date.now,
                                                                end: Date.now.addingTimeInterval(10.0),
                                                                depth: 12.234)))
  }
}
