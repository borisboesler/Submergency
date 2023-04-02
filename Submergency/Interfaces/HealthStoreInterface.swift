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

  /// some characteristics to read and write
  let genderCharacteristic
    = HKCharacteristicType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.biologicalSex)
  let underwaterDepthType
    = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.underwaterDepth)

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

    // let hkCharacteristicTypesToRead: Set<HKCharacteristicType>? = [genderCharacteristic!]
    let hkTypesToRead: Set<HKObjectType> = [underwaterDepthType!]
    // let hkTypesToWrite: Set<HKSampleType> = [bodyMass]

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
        // completion(nil)
        return
      }
      guard let depth = depth
      else {
        smLogger.debug("fail on depth \(depth)")
        // completion(nil)
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

  /// read gender data
  func readGenderType() {
    let status = healthStore!.authorizationStatus(for: genderCharacteristic!)
    if status == .sharingAuthorized {
      do {
        let genderType = try healthStore?.biologicalSex()

        if genderType?.biologicalSex == .female {
          smLogger.info("Gender is female.")
        } else if genderType?.biologicalSex == .male {
          smLogger.info("Gender is male.")
        } else {
          smLogger.info("Gender is unspecified.")
        }
      } catch {
        smLogger.info("Error looking up gender.")
      }
    } else {
      smLogger.info("no authorization to read gender.")
    }
  } // end func readGenderType
}
