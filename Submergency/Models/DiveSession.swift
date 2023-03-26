//
//  DiveSession.swift
//  Submergency
//
//  Created by Boris Boesler on 24.03.23.
//

import Foundation

// MARK: - DiveSession

/// A DiveSession represents
struct DiveSession {
  /// General nu,ber
  var id: UUID
  /// The dive profile during this dive session
  var profile: [DiveSample] = []
  /// computed properties; empty profile not allowed
  var start: Date {
    profile.first!.start
  }

  var end: Date {
    profile.last!.end
  }

  /// Initializer of a DiveSession
  /// - Parameter id: a general identifier
  /// - Parameter profile: The dive profile during this session
  internal init(id _: UInt, profile: [DiveSample] = []) {
    id = UUID()
    self.profile = profile
  }

  /// Initializer of a DiveSession
  /// - Parameter id: a general identifier
  internal init(id _: UInt) {
    id = UUID()
    profile = []
  }

  mutating func add(sample: DiveSample) {
    profile.append(sample)
  }

  func log() {
    smLogger.debug("dive session \(id) size: \(profile.count):")
    for sample in profile {
      sample.log()
    }
  }
}
