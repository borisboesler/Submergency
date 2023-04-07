//
//  DiveSession.swift
//  Submergency
//
//  Created by Boris Boesler on 24.03.23.
//

import Foundation

// MARK: - DiveSession

/// A DiveSession represents
/// ObservableObject for ..
/// Hashable for ..
/// Equatable for ..
/// Identifiable for plotting
class DiveSession: ObservableObject, Hashable, Equatable, Identifiable {
  /// General number
  let id = UUID()

  /// The dive profile during this dive session. the surface samples are missing and
  /// must be added manually during all kinds of dumps
  var profile: [DiveSample] = []

  /// computed properties: start of first sample; empty profile not allowed
  var start: Date {
    profile.first!.start
  }

  /// computed properties: end of last sample; empty profile not allowed
  var end: Date {
    profile.last!.end
  }

  /// Initializer of a DiveSession
  /// - Parameter sample: the first dive sample
  internal init(sample: DiveSample) {
    profile.append(sample)
  }

  /// add a sample to a session
  /// - Parameter sample: the sample to be added
  func add(sample: DiveSample) {
    profile.append(sample)
  }

  func maxDepth() -> Double {
    var maxDepth = 0.0

    for sample in profile where sample.depth > maxDepth {
      maxDepth = sample.depth
    }
    return maxDepth
  }

  func duration() -> TimeInterval {
    return profile.last!.end.timeIntervalSinceReferenceDate - profile.first!.start.timeIntervalSinceReferenceDate
  }

  // MARK: - Protocol Hashable

  func hash(into hasher: inout Hasher) {
    hasher.combine(start)
  }

  // MARK: - Protocol Equatable

  static func == (lhs: DiveSession, rhs: DiveSession) -> Bool {
    return lhs.start == rhs.start
      && lhs.end == rhs.end
      && lhs.profile.count == rhs.profile.count
  }

  // MARK: - Logging

  /// log a sample via XCG logger
  func log() {
    smLogger.debug("dive session \(id) size: \(profile.count):")
    for sample in profile {
      sample.log()
    }
  }
}