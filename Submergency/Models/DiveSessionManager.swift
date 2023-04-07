//
//  DiveSessionManager.swift
//  Submergency
//
//  Created by Boris Boesler on 26.03.23.
//

import Foundation

class DiveSessionManager: ObservableObject {
  /// the session manager receives its dive from the HealthStore
  private var healthStore = HealthStoreInterface()
  /// all dive samples
  private var samples: [DiveSample] = []
  /// all dive sample are organized in dive sessions
  @Published var sessions: [DiveSession] = []

  /// initializer
  init() {}

  // MARK: - Dive Samples

  /// read dive depth from healthikit
  /// - Parameter maxSecondDelta: max interval between two sessions
  func readDiveSample(maxSecondDelta: Double) {
    smLogger.info("readDiveSample")
    samples = []
    sessions = []

    healthStore.requestAuthorization { success in
      if success {
        self.healthStore.readDepthType { sample in
          DispatchQueue.main.async {
            self.add(sample: sample, maxSecondDelta: maxSecondDelta)
          }
        }
      } else {
        smLogger.info("healthStore.requestAuthorization failed")
      }
    }
  }

  /// add a sample to the manager and add it to the relevnt session or create a new dive session
  /// - Parameters:
  ///   - sample: the sample to add
  ///   - maxSecondDelta: max interval between two sessions
  func add(sample: DiveSample, maxSecondDelta: Double) {
    // add sample
    samples.append(sample)
    addSampleToSessions(sample: sample, maxSecondDelta: maxSecondDelta)
  }

  // MARK: - Sessions

  func addSampleToSessions(sample: DiveSample, maxSecondDelta: Double) {
    #if DEBUG
      smLogger.debug("--")
      smLogger.debug("start:\(sample.start) end:\(sample.end) depth: \(sample.depth)")
    #endif

    // search a dive session to which this sample belongs to
    for var session in sessions
      // appending a sample to a session
      where (sample.start.timeIntervalSinceReferenceDate >= session.start.timeIntervalSinceReferenceDate)
      && (sample.start.timeIntervalSinceReferenceDate - maxSecondDelta <= session.end.timeIntervalSinceReferenceDate) {
      #if DEBUG
        smLogger.debug("add sample to session \(session.id) size:\(session.profile.count)")
        smLogger.debug("session end:\(session.end) vs. sample start:\(sample.start)")
        smLogger.debug("diff:\(sample.start.timeIntervalSinceReferenceDate - session.end.timeIntervalSinceReferenceDate) < \(maxSecondDelta)")
      #endif
      // add sample to session and return true
      session.add(sample: sample)
      return
    }
    // add a new session and add sample to new session
    let session = DiveSession(sample: sample)
    #if DEBUG
      smLogger.debug("add sample to new session \(session.id)")
    #endif
    sessions.append(session)
  }

  /// delete all sessiona and reload sessions from samples
  /// - Parameter maxSecondDelta: max interval between two sessions
  func reloadDiveSessions(maxSecondDelta: Double) {
    smLogger.info("reloadDiveSessions")

    // delete all old sessions
    sessions = []

    // recoonstruct all sessions from samples
    for sample in samples {
      DispatchQueue.main.async {
        self.addSampleToSessions(sample: sample, maxSecondDelta: maxSecondDelta)
      }
    }
  }

  // MARK: - Temperature

  // MARK: - Logging

  /// log a sample via XCG logger
  func log() {
    for session in sessions {
      session.log()
    }
  }
}
