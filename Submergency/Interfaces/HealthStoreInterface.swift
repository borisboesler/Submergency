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

  ///
  func readDepthTypeTMP() {
    var diveNum = 1
    var currentDiveStart: Date?
    var lastDiveEnd: Date?
    var diveDuration = 0.0

    let status = healthStore!.authorizationStatus(for: underwaterDepthType!)
    if true { // status == .sharingAuthorized /*this test is for writing, what is it for reading? */ {
      // generate query to read depth data
      let query = HKQuantitySeriesSampleQuery(quantityType: underwaterDepthType!,
                                              predicate: nil) { _, depth, dates, _, _, error in

        if error != nil {
          smLogger.info(error.debugDescription)
        }
        guard let depth = depth
        else {
          return
        }

        if let currentDiveDates = dates {
          // start of dive
          if currentDiveStart == nil {
            currentDiveStart = currentDiveDates.start
            lastDiveEnd = currentDiveDates.start
          }
          // increment duration
          diveDuration += currentDiveDates.duration

          // if lastEndDate is not same as this this start then start new dive
          // let diffSeconds = currentDiveDates.start.timeIntervalSinceReferenceDate - lastDiveEnd!.timeIntervalSinceReferenceDate
          let diffSeconds = currentDiveDates.start.timeIntervalSince(lastDiveEnd!)
          let maxDivesessionDistance = 15.0 * 60.0 // 15 minutes difference
          // smLogger.info("diffSeconds: \(diffSeconds)")
          if diffSeconds < maxDivesessionDistance {
            // attach current sample to current dive profile
            smLogger.info(" start date: \(currentDiveDates.start) end date: \(currentDiveDates.end) depth: \(depth.doubleValue(for: HKUnit.meter()))")
            // smLogger.info(" duration: \(currentDiveDates.duration)")
            lastDiveEnd = currentDiveDates.end
          } else {
            // dive #diveNum: start: currentDiveStart end: dates!.end duration: duration
            smLogger.info("dive #\(diveNum) start: \(currentDiveStart!) end: \(currentDiveDates.end) duration: \(diveDuration)")
            // smLogger.info("** start new dive \(diveNum + 1).")
            // inc dive count
            diveNum += 1
            // reset
            currentDiveStart = nil
            lastDiveEnd = nil
            diveDuration = 0.0
          }
        }
      }

      healthStore!.execute(query)
    } else {
      smLogger.info("no authorization \(status) to read depth.")
    }
  }

  func readDepthType(completion: @escaping (DiveSample?) -> Void) {
    var sessionList: [DiveSession] = []
    var lastDiveSample: DiveSample?
    var sessionCounter: UInt = 1
    var currentDiveSession: DiveSession?
    // 15min break between sessions
    let maxSessionDifference = 60.0 * 15.0
    // generate query to read depth data
    let query = HKQuantitySeriesSampleQuery(quantityType: underwaterDepthType!,
                                            predicate: nil) { _, depth, dates, _, _, error in
      if let error = error {
        smLogger.debug("\(error)")
        completion(nil)
        return
      }
      guard let depth = depth
      else {
        completion(nil)
        return
      }

      // bypass nil check
      if let sampleDates = dates {
        // if the session list is empty, then generate a session, because we have data
        if sessionList.isEmpty {
          currentDiveSession = DiveSession(id: sessionCounter)
          sessionList.append(currentDiveSession!)
          sessionCounter += 1
        }

        // do we have to start a new session?
        if let lastDiveSample = lastDiveSample {
          // yes: create a new dive session with current samples, add
          // this dive session to list of session and clear current dive
          // sample list
          if sampleDates.start.timeIntervalSince(lastDiveSample.end) > maxSessionDifference {
            // log old session
            // currentDiveSession!.log()
            // create a new session
            //smLogger.debug("create new session \(sessionCounter) #sessions:\(sessionList.count)")
            currentDiveSession = DiveSession(id: sessionCounter)
            sessionList.append(currentDiveSession!)
            sessionCounter += 1
          } else {
            // keep old session
          }
        } else {
          // no previous lastDiveSample, append to current session
        }

        // create a divesample
        //smLogger.debug("create new sample \(sampleDates.start) \(sampleDates.end) \(depth.doubleValue(for: HKUnit.meter()))")
        lastDiveSample = DiveSample(start: sampleDates.start, end: sampleDates.end, depth: depth.doubleValue(for: HKUnit.meter()))
        currentDiveSession!.profile.append(lastDiveSample!)
      } // if let sampleDates = dates

      //completion(sessionList)
      completion(lastDiveSample)
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
