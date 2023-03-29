//
//  DiveSessionManager.swift
//  Submergency
//
//  Created by Boris Boesler on 26.03.23.
//

import Foundation

class DiveSessionManager {
  /// all dive samples
  private var samples: [DiveSample] = []
  /// all dive sample are organized in dive sessions
  private var sessions: [DiveSession] = []

  /// initializer
  init() {}

  /// add a sample to the manager and add it to the relevnt session or create a new dive session
  func add(sample: DiveSample, maxSecondDelta: Double) {
    // add sample
    samples.append(sample)

    smLogger.debug("--")
    smLogger.debug("start:\(sample.start) end:\(sample.end) depth: \(sample.depth)")

    // search a dive session to which this sample belongs to
    for var session in sessions
      // appending a sample to a session
      where (sample.start.timeIntervalSinceReferenceDate >= session.start.timeIntervalSinceReferenceDate)
      && (sample.start.timeIntervalSinceReferenceDate - maxSecondDelta <= session.end.timeIntervalSinceReferenceDate) {
      smLogger.debug("add sample to session \(session.id) size:\(session.profile.count)")
      smLogger.debug("session end:\(session.end) vs. sample start:\(sample.start)")
      smLogger.debug("diff:\(sample.start.timeIntervalSinceReferenceDate - session.end.timeIntervalSinceReferenceDate) < \(maxSecondDelta)")
      // add sample to session and return true
      session.add(sample: sample)
      return
    }
    // add a new session and add sample to new session
    let session = DiveSession(ident: UInt(sessions.count + 1), sample: sample)
    smLogger.debug("add sample to new session \(session.id)")
    sessions.append(session)
  }

  // TODO: rebuild sessions from samples

  /// log a sample via XCG logger
  func log() {
    for session in sessions {
      session.log()
    }
  }
}
