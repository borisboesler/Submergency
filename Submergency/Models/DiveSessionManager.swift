//
//  DiveSessionManager.swift
//  Submergency
//
//  Created by Boris Boesler on 26.03.23.
//

import Foundation

struct DiveSessionManager {
  /// all dive samples
  private var samples: [DiveSample] = []
  /// all dive sample are organized in dive sessions
  private var sessions: [DiveSession] = []

  /// initializer
  init() {}

  /// add a sample to the manager and add it to the relevnt session or create a new dive session
  mutating func add(sample: DiveSample, timeOffset: Double) -> Bool {
    // add sample
    samples.append(sample)
    // search a dive session to which this sample belongs to
    for var session in sessions
      where session.start < sample.start
    && session.end.timeIntervalSince(sample.end) < timeOffset {
        // add sample to session and return true
      session.add(sample: sample)
      return true
      }
    // add a new session and add sample to new session
    var session = DiveSession(id: UInt(sessions.count + 1))
    session.add(sample: sample)

    return true
  }

  /// log
  func log() {
    smLogger.debug("dive session \(id):")
    for session in sessions {
      sessions.log()
    }
  }
}
