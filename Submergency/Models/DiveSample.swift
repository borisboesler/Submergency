//
//  DiveSample.swift
//  Submergency
//
//  Created by Boris Boesler on 26.03.23.
//

import Foundation

// MARK: - DiveSample

/// A DiveSample represents a time interval at a certain depth
/// Identifiable for plotting
class DiveSample: Identifiable {
  /// The start of this dive sample
  var start: Date
  /// The end of this dive sample
  var end: Date
  /// The depth during this dive sample
  var depth: Double

  /// Initializer of a DiveSample
  /// - Parameters:
  ///   - start: start date
  ///   - end: end date
  ///   - depth: depth during start to end
  /// NOTE: This method is generated
  internal init(start: Date, end: Date, depth: Double) {
    self.start = start
    self.end = end
    self.depth = depth
  }

  /// log a sample via XCG logger
  func log() {
    smLogger.debug("from: \(start) to \(end) \(depth)m")
  }
}
