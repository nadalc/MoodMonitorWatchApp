/**
  HealthDataManager.swift
  MoodMonitor WatchKit Extension
 
 The files in this directory are part of the Mood Monitor Watch app.
 For more information please visit https://htd.scss.tcd.ie/mood-monitor

 Copyright (c) 2020, Camille Nadal & Gavin Doherty, Trinity College Dublin.

 Permission is hereby granted, free of charge, to any person obtaining a copy of this software
 and associated documentation files (the "Software"), to deal in the Software without restriction,
 including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
 and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
 subject to the following conditions:
     * Mood Monitor Watch app is citeware:
       Any publications (e.g. academic reports, papers, other disclosure of results) containing
       or based on outputs (such as graphs) or data obtained with the use of this software will
       acknowledge its use by mentioning the name "Mood Monitor Watch app" and an appropriate
       citation of the following publication (or an updated version): "This app was developed at
       Trinity College Dublin in order to support user acceptance research. For associated
       publications, see Nadal, C., Sas, C., & Doherty, G. (2020). Technology Acceptance in Mobile
       Health: Scoping Review of Definitions, Models, and Measurement. Journal of Medical Internet
       Research, 22(7), e17256."
     * The above copyright notice, the list of conditions and the following disclaimer shall be
       included in all copies or substantial portions of the Software.
     * Neither the name of Mood Monitor Watch app nor the names of its contributors may be used to
       endorse or promote products derived from this software without specific prior written
       permission.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
 LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 This class defines the HealthDataManager, object managing the access (reading) to HealthKit data.
*/

import Foundation
import HealthKit

class HealthDataManager: NSObject {
        
    private var healthStore = HKHealthStore()
    
    /// Reads Sleep Analysis data (bedtime and number of hours slept)
    /// Creates and executes a query to read the Sleep Analysis data in the HealthKit
    func getPastWeekSleepAnalysis(){
       
        var stringInBed = ""
        
        /// Defines sleepAnalysis as the type of object to read in HealthKit
        if let sleepType = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis) {
            
            /// Uses a sortDescriptor to get the recent data first
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            
            /// Creates a predicate to read only data from the past week
            let now = Date()
            if let exactlySevenDaysAgo = Calendar.current.date(byAdding: DateComponents(day: -7), to: now) {
               let startOfSevenDaysAgo = Calendar.current.startOfDay(for: exactlySevenDaysAgo)
               let predicate = HKQuery.predicateForSamples(withStart: startOfSevenDaysAgo, end: now, options: .strictStartDate)
               
               /// Creates a query to read the Sleep Analysis
               let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: 30, sortDescriptors: [sortDescriptor]) { (query, tmpResult, error) -> Void in
                   
                   if error != nil {
                       print("ERROR - Watch couldn't read sleep data")
                       return
                   }
                   
                   /// Query has returned results
                   if let result = tmpResult {
                       
                       /// Goes trough the query results
                       for item in result {
                           
                           /// Initialises variables
                           var secondsInBed = 0
                           var bedtime: Date? = nil
                          
                           /// Formats the timestamp to a date to be used as key in *userDataDictionary*
                           let dateString = formatDateToString(date: item.endDate)
                           
                           /// If the query result is of type Sleep Analysis, reads it
                           if let sample = item as? HKCategorySample {
                               
                               /// If query result has an *inBed* value
                               if (sample.value == HKCategoryValueSleepAnalysis.inBed.rawValue) {
                                   
                                   /// Calculates the actual number of seconds *inBed*
                                   /// Substracts the start time of the interval to the end time
                                   let inBedInterval = Calendar.current.dateComponents([.second], from: sample.startDate, to: sample.endDate)
                                   secondsInBed = inBedInterval.second!
                                   
                                   /// If the number of seconds *inBed* over 1h, we suppose that there was no error of recording
                                   /// Formats it to the half hour and stores it in *userDataDictionary* at the *dateString*
                                   if (secondsInBed > 3600){
                                       
                                       stringInBed = self.formatToHalfHourInterval(seconds: secondsInBed)
                                       userDataDictionary[dateString]?.updateValue(stringInBed, forKey: "inBed")
                                   }
                                       
                                   /// If the number of seconds *inBed* is unknown, stores a "-" in *userDataDictionary* at the *dateString*
                                   else {
                                       userDataDictionary[dateString]?.updateValue("-", forKey: "inBed")
                                   }
                                   
                                   /// Bedtime is stored in HealthKit as the startDate of the *inBed* sample
                                   bedtime = sample.startDate
                                   
                                   /// If bedtime is known, formats is to "HH:mm" and stores it in *userDataDictionary* at the *dateString*
                                   if (bedtime != nil){

                                       /// Formats  bedtime to "HH:mm"
                                       let dateFormatter = DateFormatter()
                                       dateFormatter.dateFormat = "HH:mm"
                                       let string = dateFormatter.string(from: bedtime!)
                               
                                       /// Gets time in seconds
                                       let seconds = string.numberOfSeconds()
                                       
                                       /// Format time to nearest half hour
                                       let bedtimeString = self.formatToHalfHourInterval(seconds: seconds)
                                       
                                       /// Stores bedtime
                                       userDataDictionary[dateString]?.updateValue(bedtimeString, forKey: "bedtime")
                                   }
                               }
                           }
                       }
                   }
               }
               /// Executes the HealthKit query to read the Sleep Analysis
               healthStore.execute(query)
          }
        }
    }
    
    /// Reads Steps Count
    /// Creates and executes a query to read the Steps Count in the HealthKit
    func getPastWeekSteps(){
          let now = Date()

          /// Defines stepCount as the type of object to read in HealthKit
          /// Creates a predicate to read only data from the past week

     if let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount), let exactlySevenDaysAgo = Calendar.current.date(byAdding: DateComponents(day: -7), to: now) {
          let startOfSevenDaysAgo = Calendar.current.startOfDay(for: exactlySevenDaysAgo)
          let predicate = HKQuery.predicateForSamples(withStart: startOfSevenDaysAgo, end: now, options: .strictStartDate)

          /// Creates a query to read the Steps Count
          let query = HKStatisticsCollectionQuery.init(quantityType: stepsQuantityType,
                                                       quantitySamplePredicate: predicate,
                                                       options: .cumulativeSum,
                                                       anchorDate: startOfSevenDaysAgo,
                                                       intervalComponents: DateComponents(day: 1))
               
          query.initialResultsHandler = { query, results, error in
               guard let statsCollection = results else {
                    print("ERROR - Watch couldn't read steps data")
                    return
               }

               /// Query has returned results; Goes through the results
               statsCollection.enumerateStatistics(from: startOfSevenDaysAgo, to: now) { statistics, stop in
                      
                    /// Formats the timestamp to a date to be used as key in *userDataDictionary*
                    let dateString = formatDateToString(date:statistics.startDate)
                       
                    /// Reads the Steps Count double value and converts the double value to a String
                    if let quantity = statistics.sumQuantity() {
                         let stepValue = quantity.doubleValue(for: HKUnit.count())
                           
                         let stringSteps = String(format: "%.0f", stepValue)
                       
                         /// Stores the Steps Count
                         userDataDictionary[dateString]?.updateValue(stringSteps, forKey: "steps")
                    }
               }
          }
          /// Executes the HealthKit query to read the Steps Count
          self.healthStore.execute(query)
     }
    }
    
    /// Formats the seconds value in parameter to the corresponding hours:minutes
    /// Parameter: totalSeconds is the seconds value
    /// Returns: a String in format "HH:MM"
    private func formatSecondsToHHMM(totalSeconds: Int) -> String {
        
        let minutes = (totalSeconds / 60) % 60
        let hours = totalSeconds / 3600

        return String(format: "%02d:%02d", hours, minutes)
    }
    
    /// Formats the seconds value in parameter to the closest half hour
    /// Parameter: totalSeconds is the seconds value
    /// Returns: a String in format "HH:MM"
    private func formatToHalfHourInterval (seconds: Int) -> String {
        
        var nearestHalfHour = 0

        let prevHalfHour = seconds - (seconds % 1800);
        
        var nextHalfHour = prevHalfHour + 1800;
        
        if ((seconds - prevHalfHour) < (nextHalfHour - seconds)){
            nearestHalfHour = prevHalfHour
        }
        else {
            /// For all times past midnight
            if (nextHalfHour >= 86400){
                
                /// Deduces 24h to start again from 0
                nextHalfHour = nextHalfHour - 86400
            }
            nearestHalfHour = nextHalfHour
        }
        
        let interval = TimeInterval(nearestHalfHour)
        if let tmp = interval.format(using: [.hour, .minute]) {
          return tmp.description
        }
        return ""
    }
    
}

extension String {
    
    /// Calculates the seconds value of the String "HH:MM"
    /// Returns: Integer seconds value
    func numberOfSeconds() -> Int {
        
        /// Retrieves hours and minutes values of the String
        let components: Array = self.components(separatedBy: ":")
        let hours = Int(components[0]) ?? 0
        let minutes = Int(components[1]) ?? 0
        
        /// Calculates and returns seconds value
        return (hours * 3600) + (minutes * 60)
    }
}
