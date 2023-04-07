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
  private var diveSamples: [DiveSample] = []
  /// all temperature samples
  private var temperatureSamples: [TemperatureSample] = []
  /// all dive sample are organized in dive sessions
  @Published var diveSessions: [DiveSession] = []

  /// initializer
  init() {}

  // MARK: - Dive Samples

  /// read dive depth from healthikit
  /// - Parameter maxSecondDelta: max interval between two sessions
  func readDiveSamples(maxSecondDelta: Double) {
    smLogger.info("readDiveSample")
    diveSamples = []
    diveSessions = []

    healthStore.requestAuthorization { success in
      if success {
        self.healthStore.readDepthType { sample in
          DispatchQueue.main.async {
            self.addDiveSample(sample: sample, maxSecondDelta: maxSecondDelta)
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
  func addDiveSample(sample: DiveSample, maxSecondDelta: Double) {
    // add sample
    diveSamples.append(sample)
    addSampleToSessions(sample: sample, maxSecondDelta: maxSecondDelta)
  }

  // MARK: - Sessions

  func addSampleToSessions(sample: DiveSample, maxSecondDelta: Double) {
    #if DEBUG
      smLogger.debug("--")
      smLogger.debug("start:\(sample.start) end:\(sample.end) depth: \(sample.depth)")
    #endif

    // search a dive session to which this sample belongs to
    for var session in diveSessions
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
    diveSessions.append(session)
  }

  /// delete all sessiona and reload sessions from samples
  /// - Parameter maxSecondDelta: max interval between two sessions
  func reloadDiveSessions(maxSecondDelta: Double) {
    smLogger.info("reloadDiveSessions")

    // delete all old sessions
    diveSessions = []

    // recoonstruct all sessions from samples
    for sample in diveSamples {
      DispatchQueue.main.async {
        self.addSampleToSessions(sample: sample, maxSecondDelta: maxSecondDelta)
      }
    }
  }

  // MARK: - Temperature

  func readDiveTemperatures() {
    smLogger.info("readDiveTemperatures")
    temperatureSamples = []

    healthStore.requestAuthorization { success in
      if success {
        self.healthStore.readTemperatureType { temperatureSample in
          DispatchQueue.main.async {
            // self.add(sample: sample)
            self.temperatureSamples.append(temperatureSample)

            #if DEBUG
              smLogger.debug("temperature from: \(temperatureSample.start) to \(temperatureSample.end) \(temperatureSample.temp)C")
            #endif

            #if false
              /// this is useless, because the temperature might be delivered BEFORE a dive sample has been delivered
              /// add temperature sample to dive sample
              for var diveSample in self.diveSamples
                // appending a sample to a session
                where (temperatureSample.start.timeIntervalSinceReferenceDate >= diveSample.start.timeIntervalSinceReferenceDate)
                && (temperatureSample.start.timeIntervalSinceReferenceDate <= diveSample.end.timeIntervalSinceReferenceDate) {
                diveSample.temp = temperatureSample
                return
              }
            #endif
          }
        }
      } else {
        smLogger.info("healthStore.requestAuthorization failed")
      }
    }
  }

  // MARK: - Logging

  /// log a sample via XCG logger
  func log() {
    for session in diveSessions {
      session.log()
    }
  }
}
