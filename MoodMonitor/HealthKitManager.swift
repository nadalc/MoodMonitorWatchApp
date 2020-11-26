//
//  HealthKitManager.swift
//  SilverCloud
//
//  Created by Maria Ortega on 03/06/2020.
//  Copyright © 2020 James. All rights reserved.
//

import HealthKit

class HealthKitManager {

     private static var healthStore = HKHealthStore()
     
     private enum HealthkitSetupError: Error {
       case notAvailableOnDevice
       case dataTypeNotAvailable
     }
     
     static func authorizeHealthKit(completion: @escaping (Bool, Error?) -> ()) {
          guard HKHealthStore.isHealthDataAvailable() else {
               completion(false, HealthkitSetupError.notAvailableOnDevice)
               return
          }

          // Define what HealthKit data we want to ask to write/read
          let typestoRead = Set([HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.mindfulSession)!])
          let typestoShare = Set([HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.mindfulSession)!])

          // Prompt the User for HealthKit Authorization
          healthStore.requestAuthorization(toShare: typestoShare, read: typestoRead) { (success, error) in
               completion(success, error)
          }
     }
     
     static func saveMindfullSessions(sessions: [[String: Any]]) {
          let validSessions = sessions.filter { $0["length"] as! Int > 0 }
          retrieveMindFulSessions { (query, results, error) in
               if let results = results, !results.isEmpty {
                    
                    // Find all repeated sessions
                    let sessionsRepeted = results.filter{ existingSession in
                         return validSessions.contains( where: { newSession in
                              Date.dateFromISOString(string: newSession["date_started"] as! String) == existingSession.startDate
                         })
                    }

                    // Delete the existing sessions
                    self.deleteSessions(sessions: sessionsRepeted)

                    // Save new sessions to update them
                    self.saveSessions(sessions: validSessions)

               } else {
                    // No existing sessions, save new ones
                    self.saveSessions(sessions: validSessions)
               }
          }
     }
     
     private static func saveSessions(sessions: [[String: Any]]) {
          var mindfullSessions: [HKSample] = []
          if let mindfulType = HKObjectType.categoryType(forIdentifier: .mindfulSession) {
               for session in sessions {
                    let dates = getSessionDates(session: session)
                    if let startDate = dates.0, let endDate = dates.1 {
                         mindfullSessions.append(HKCategorySample(type: mindfulType, value: 0, start: startDate, end: endDate, metadata: ["sub-type": "CBT"]))
                    }
               }
               healthStore.save(mindfullSessions) { (success, error) in
                    if success {
                         UserDefaults.standard.set(true, forKey: isMindfulSessionSaved)
                    }
               }
          }
     }
     
     private static func getSessionDates(session: [String: Any]) -> (Date?, Date?) {
          if let length = session["length"] as? Int, length > 0, let date = session["date_started"] as? String, let startDate = Date.dateFromISOString(string: date) {
               var endDate = startDate
               endDate.addTimeInterval(TimeInterval(length))
               return (startDate, endDate)
          }
          return (nil, nil)
     }
         
     static func retrieveMindFulSessions(completion: @escaping (HKSampleQuery, [HKSample]?, Error?) -> Void) {
          // Use a sortDescriptor to get the recent data first (optional)
          let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

          // Get all samples from the last 24 hours
          let endDate = Date()
          let startDate = endDate.addingTimeInterval(-1.0 * 60.0 * 60.0 * 24.0)
          let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])

          guard let mindfulType = HKObjectType.categoryType(forIdentifier: .mindfulSession) else { return }

          let query = HKSampleQuery(
              sampleType: mindfulType,
              predicate: predicate,
              limit: 0,
              sortDescriptors: [sortDescriptor],
              resultsHandler: completion
          )
          healthStore.execute(query)
     }
     
     private static func deleteSessions(sessions: [HKSample]) {
          healthStore.delete(sessions) { (success, error) in
               print(success, error as Any)
          }
     }
}
