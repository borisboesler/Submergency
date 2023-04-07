//
//  TemperatureSample.swift
//  Submergency
//
//  Created by Boris Boesler on 07.04.23.
//

import Foundation

/// a temperature sample
class TemperatureSample: Identifiable {
  /// start of this temperature sample
  var start: Date
  /// end of this temperature sample
  var end: Date
  /// temperature of this temperature sample
  var temp: Double

  /// initialze this temperature sample
  /// - Parameters:
  ///   - start: start of this temperature sample
  ///   - end: end of this temperature sample
  ///   - temp: temperature of this temperature sample
  init(start: Date, end: Date, temp: Double) {
    self.start = start
    self.end = end
    self.temp = temp
  }
}
