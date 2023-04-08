//
//  HealthStoreInterface.swift
//  Submergency
//
//  Created by Boris Boesler on 21.03.23.
//

import Foundation

import HealthKit

/// Interface to HealthStore.
class HealthStoreInterface {
  /// our private access to health data
  private var healthStore: HKHealthStore?

  ///  dive depth characteristics to read
  let underwaterDepthType
    = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.underwaterDepth)
  ///  dive temperature characteristics to read
  let underwaterTemperatureType
    = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.waterTemperature)

  init() {
    // Check whether HealthKit is available on this device.
    if HKHealthStore.isHealthDataAvailable() {
      healthStore = HKHealthStore()
    }
  }

  /// request access to health data
  /// this request open iOS panel in which the user can grant or
  /// reject access to some data. it does not imply that some
  /// access is granted. this has to be checked with another
  /// method.
  func requestAuthorization(completion: @escaping (Bool) -> Void) {
    smLogger.info("request authorization ")

    let hkTypesToRead: Set<HKObjectType> = [underwaterDepthType!, underwaterTemperatureType!]

    guard let healthStore = healthStore else { return completion(false) }

    healthStore.requestAuthorization(toShare: nil,
                                     read: hkTypesToRead, completion: { success, error in
                                       if success {
                                         smLogger.info(" authorization request done")
                                       } else {
                                         smLogger.info(error.debugDescription)
                                       }
                                       completion(success)
                                     })
  }

  func readDepthType(completion: @escaping (DiveSample) -> Void) {
    // TODO: generators of data: HKSourceQuery
    // generate query to read depth data
    let query = HKQuantitySeriesSampleQuery(quantityType: underwaterDepthType!,
                                            predicate: nil) { _, depth, dateInterval, _, _, error in
      if let error = error {
        smLogger.debug("\(error)")
        return
      }
      guard let depth = depth
      else {
        smLogger.debug("fail on depth")
        return
      }

      // bypass nil check
      if let sampleDates = dateInterval {
        // create a divesample
        let diveSample = DiveSample(start: sampleDates.start, end: sampleDates.end,
                                    depth: depth.doubleValue(for: HKUnit.meter()))
        completion(diveSample)
      } // if let sampleDates = dates
    } // let query

    // execute query (asyncroniously)
    healthStore!.execute(query)
  }

  func readSourceType(completion: @escaping (HKSource) -> Void) {
    // read sources
    let query = HKSourceQuery(sampleType: underwaterDepthType!,
                              samplePredicate: nil) { _, sources, _ in
      for source in sources! {
        completion(source)
      }
    }
    healthStore!.execute(query)
  }

  func readTemperatureType(completion: @escaping (TemperatureSample) -> Void) {
    // TODO: generators of data: HKSourceQuery
    // generate query to read depth data
    let query = HKQuantitySeriesSampleQuery(quantityType: underwaterTemperatureType!,
                                            predicate: nil) { _, temp, dateInterval, _, _, error in
      if let error = error {
        smLogger.debug("\(error)")
        return
      }
      guard let temp = temp
      else {
        smLogger.debug("fail on temp")
        return
      }

      // bypass nil check
      if let sampleDates = dateInterval {
        // create a divesample
        let tempSample = TemperatureSample(start: sampleDates.start, end: sampleDates.end,
                                           temp: temp.doubleValue(for: HKUnit.degreeCelsius()))
        completion(tempSample)
      } // if let sampleDates = dates
    } // let query

    // execute query (asyncroniously)
    healthStore!.execute(query)
  }
}
