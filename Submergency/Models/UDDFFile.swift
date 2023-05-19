//
//  UDDFFile.swift
//  Submergency
//
//  Created by Boris Boesler on 07.04.23.
//

import Foundation
import SwiftUI

// MARK: - UDDFString

class UDDFString {
  init() {}

  /// Build the <generator> section of UDDF
  func uddfGeneratorTag() -> String {
    let generatorTag =
      """
      <generator>
        <name>Submergency</name>
        <manufacturer id=\"boris-boesler\">
          <name>Boris Boesler</name>
        </manufacturer>
        <version>0</version>
        <datetime>\(Date.now.ISO8601Format())</datetime>
      <type>converter</type>
      </generator>
      """
    return generatorTag
  }

  /// Build the <diver> section of UDDF
  func uddfDiverTag(computerId: String, computerName: String) -> String {
    let diverTag =
      """
      <diver>
        <owner id=\"owner\">
          <personal>
            <firstname/>
            <lastname/>
          </personal>
          <equipment>
            <divecomputer id=\"\(computerId)\">
              <name>\(computerName)</name>
              <model>Apple Watch Ultra</model>
            </divecomputer>
          </equipment>
        </owner>
        <buddy/>
      </diver>
      """
    return diverTag
  }

  func getUDDFWaypointTag2(offsetTime: Double, depth: Double, tempCelcius: Double?) -> String {
    var waypointTag = "<waypoint>\n"
    waypointTag += "<depth>\(depth)</depth>\n"
    waypointTag += "<divetime>\(offsetTime)</divetime>\n"
    if let tempCelcius = tempCelcius {
      waypointTag += "<temperature>\(tempCelcius + 273.15)</temperature>"
    }
    waypointTag += "<divemode type=\"apnoe\"/>\n"
    waypointTag += "</waypoint>\n"
    return waypointTag
  }

  func getUDDFTemeratureTag(sample: DiveSample, temps: [TemperatureSample]) -> String {
    for temp in temps where temp.start == sample.start {
      let tempTag = "<temperature>\(temp.temp + 273.15)</temperature>\n"
      return tempTag
    }
    return ""
  }

  func getUDDFWaypointTag(startTime: Date, sample: DiveSample, temps: [TemperatureSample]) -> String {
    var waypointTag = "<waypoint>\n"
    waypointTag += "<depth>\(sample.depth)</depth>\n"
    waypointTag += "<divetime>\((sample.end.timeIntervalSinceReferenceDate) - startTime.timeIntervalSinceReferenceDate)</divetime>\n"
    // <temperature>\(findTemperature(sample.start, temps)) + 273.15</temperature>
    waypointTag += getUDDFTemeratureTag(sample: sample, temps: temps)
    waypointTag += "<divemode type=\"apnoe\"/>\n"
    waypointTag += "</waypoint>\n"
    return waypointTag
  }

  ///
  func getUDDFSamplesTag(startTime: Date, profile: [DiveSample], temps: [TemperatureSample]) -> String {
    var samplesTag = "<samples>\n"

    // have to start at waypoint 0
    samplesTag += getUDDFWaypointTag2(offsetTime: 0.0, depth: 0.0, tempCelcius: nil)

    for sample in profile {
      samplesTag += getUDDFWaypointTag(startTime: startTime, sample: sample, temps: temps)
    }

    // have to end at waypoint 0
    samplesTag += getUDDFWaypointTag2(offsetTime: (profile.last?.end.timeIntervalSinceReferenceDate)! - startTime.timeIntervalSinceReferenceDate + 1.0,
                                      depth: 0.0, tempCelcius: nil)
    // end
    samplesTag += "</samples>\n"
    return samplesTag
  }

  /// build full UDDF string
  func getUDDFString(computerId: String, computerName: String,
                     session: DiveSession, temps: [TemperatureSample]) -> String {
    var uddfString =
      """
      <?xml version=\"1.0\" encoding=\"utf-8\"?>
      <uddf xmlns=\"http://www.streit.cc/uddf/3.2.3/\" version=\"3.2.3\">
      """

    uddfString += uddfGeneratorTag()
    uddfString += uddfDiverTag(computerId: computerId, computerName: computerName)
    uddfString += "<profiledata>\n"
    uddfString += "<repetitiongroup>\n"
    uddfString += "<dive id=\"session_\(session.profile.first!.start.timeIntervalSinceReferenceDate)\">\n"

    // we have to wrap the date/time in informationdeforedive additionally for MacDive
    uddfString += "<informationbeforedive>\n"
    uddfString += "<datetime>\(session.profile.first!.start.ISO8601Format())</datetime>\n"
    uddfString += "</informationbeforedive>\n"
    uddfString += "<datetime>\(session.profile.first!.start.ISO8601Format())</datetime>\n"

    uddfString += "<diveduration>\(session.duration())</diveduration>\n"
    uddfString += "<greatestdepth>\(session.maxDepth())</greatestdepth>\n"
    uddfString += getUDDFSamplesTag(startTime: session.profile.first!.start, profile: session.profile, temps: temps)
    uddfString += "</dive>\n"
    uddfString += "</repetitiongroup>\n"
    uddfString += "</profiledata>\n"
    uddfString += "</uddf>\n"
    return uddfString
  }
}

// MARK: - UDDFFile

struct UDDFFile: FileDocument {
  /// tell the system we support only plain text
  static var readableContentTypes = [UTTypeExport]
  /// static var readableContentTypes = [UTType.xml]
  static var writableContentTypes = [UTTypeExport]

  /// by default our document is empty
  var content = ""

  /// a simple initializer that creates new, empty documents
  init(initialText: String = "") {
    content = initialText
  }

  /// this initializer loads data that has been saved previously
  init(configuration: ReadConfiguration) throws {
    if let data = configuration.file.regularFileContents {
      content = String(decoding: data, as: UTF8.self)
    }
  }

  /// this will be called when the system wants to write our data to disk
  func fileWrapper(configuration _: WriteConfiguration) throws -> FileWrapper {
    let data = Data(content.utf8)
    return FileWrapper(regularFileWithContents: data)
  }
}
