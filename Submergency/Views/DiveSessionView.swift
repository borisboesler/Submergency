//
//  DiveSessionView.swift
//  Submergency
//
//  Created by Boris Boesler on 02.04.23.
//

import Charts
import SwiftUI
import UniformTypeIdentifiers

// MARK: - Local config

let displayTemperatureGraph = true
var lastDate = Date(timeIntervalSince1970: 0.0)

// MARK: - UDDF file type

let UTTypeUDDF = UTType(filenameExtension: "uddf", conformingTo: UTType.xml)
let UTTypeExport: UTType = UTTypeUDDF!

// MARK: - DiveSessionView

struct DiveSessionView: View {
  let diveSession: DiveSession
  @State var isExporting = false

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
    let maxTemperatureCelcius = 30.0

    NavigationStack {
      VStack {
        HStack {
          // basic info
          Spacer()
          Text("\(DiveSessionView.durationFormatter.string(from: diveSession.duration()) ?? "0")")
          Spacer()
          Text(String(format: "%.1fm", diveSession.maxDepth()))
          Spacer()
        }

        // a dive profile
        Divider()

        GroupBox("Dive Session Profile") {
          // ScrollView(.horizontal, showsIndicators: true) {
          Chart {
            ForEach(diveSession.profile) { sample in
              // TODO: fill gaps with time at depth 0m
              #if true
                // FIXME: this is false
                if isIntervalGreater(date: sample.start, interval: 3.0) {
                  LineMark(
                    x: .value("Time", lastDate),
                    y: .value("Depth", 0.0)
                  )
                  .foregroundStyle(by: .value("Value", "Depth"))
                  LineMark(
                    x: .value("Time", sample.start),
                    y: .value("Depth", 0.0)
                  )
                  .foregroundStyle(by: .value("Value", "Depth"))
                }
              #endif
              // horizontal line from start to end for depth
              LineMark(
                x: .value("Time", sample.start),
                y: .value("Depth", -sample.depth)
              )
              .foregroundStyle(by: .value("Value", "Depth"))
              LineMark(
                x: .value("Time", sample.end),
                y: .value("Depth", -sample.depth)
              )
              .foregroundStyle(by: .value("Value", "Depth"))
            }
            // temperature, depth ranges from [0, diveSession.maxDepth()]
            // set displayed temperature to -maxDepth + (temp * (diveSession.maxDepth() / maxTemp))
            ForEach(diveSession.profile) { sample in
              LineMark(
                x: .value("Time", sample.start),
                y: .value("Temperature",
                          -diveSession.maxDepth()
                            + (diveSessionManager.temperature(start: sample.start)
                              * (diveSession.maxDepth() / maxTemperatureCelcius)))
              )
              .foregroundStyle(by: .value("Value", "Temperature"))
            }
          } // Chart
          // move depth axis to the left
          .chartYAxis {
            AxisMarks(position: .leading)
            #if false
              // this axis is on top (>0) of the other graph
              AxisMarks(position: .trailing,
                        values: Array(stride(from: maxTemperatureCelcius, through: 0.0, by: -5.0)))
              // TODO: set a Content
            #endif
          }

          // background
          .chartPlotStyle { plotArea in plotArea
            .background(.blue.opacity(0.1))
          }
          // } // ScrollView
        } // GroupBox
      } // VStack
      .navigationTitle("\(DiveSessionView.dateFormatter.string(from: diveSession.start))")
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: { isExporting = true },
                 label: // { Text("Export") }
                 { Image(systemName: "square.and.arrow.up").imageScale(.large) })
            .fileExporter(isPresented: $isExporting,
                          document: UDDFFile(initialText: diveSession.buildUDDF()),
                          contentType: UTTypeUDDF!,
                          defaultFilename: diveSession.defaultUDDFFilename()) { result in
              switch result {
              case let .success(url):
                smLogger.debug("Saved to: \(url)")
              case let .failure(error):
                smLogger.debug(error.localizedDescription)
              }
            }
        } // ToolbarItem
      } // toolbar
    } // NavigationStack
  } // body

  ///
  func isIntervalGreater(date: Date, interval: TimeInterval) -> Bool {
    // static let lastDate = Date(timeIntervalSince1970: 0.0)
    var res = false
    if interval < abs(lastDate.timeIntervalSince(date)) {
      res = true
    }
    lastDate = date
    return res
  }
}

// MARK: - DiveSessionView_Previews Support

func getPreviewDivesession() -> DiveSession {
  let dateNow = Date.now
  let intervalLength = 2.0 // seconds
  let intervalCount = 10

  let depthStart = 2.0 // meter
  let depthDescend = 1.0 // descend in meter per sample

  let previewDS = DiveSession(sample: DiveSample(start: dateNow,
                                                 end: dateNow.addingTimeInterval(intervalLength),
                                                 depth: depthStart))

  var sampleStart = dateNow
  var sampleEnd = sampleStart + intervalLength
  var depth = depthStart
  for _ in 1 ... intervalCount {
    previewDS.add(sample: DiveSample(start: sampleStart,
                                     end: sampleEnd,
                                     depth: depth))
    smLogger.debug("start: \(sampleStart) end:\(sampleEnd) depth:\(depth)")
    sampleStart = sampleEnd
    sampleEnd = sampleStart + intervalLength
    depth += depthDescend
  }

  // add a gap

  // up and wait longer than interval
  previewDS.add(sample: DiveSample(start: sampleStart,
                                   end: sampleEnd,
                                   depth: 1.0))

  sampleStart = sampleEnd
  sampleEnd = sampleStart + intervalLength
  sampleStart = sampleEnd
  sampleEnd = sampleStart + intervalLength

  // start time has a gap now

  // down
  previewDS.add(sample: DiveSample(start: sampleStart,
                                   end: sampleEnd,
                                   depth: 10.0))
  sampleStart += intervalLength
  sampleEnd = sampleStart + intervalLength

  // and finally up
  previewDS.add(sample: DiveSample(start: sampleStart,
                                   end: sampleEnd,
                                   depth: 1.0))

  return previewDS
}

// MARK: - DiveSessionView_Previews

struct DiveSessionView_Previews: PreviewProvider {
  static var previews: some View {
    DiveSessionView(diveSession: getPreviewDivesession())
      .background(Color.gray)
  }
}
