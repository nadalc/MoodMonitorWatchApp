/**
  GlobalFunctions.swift
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
 IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT
 OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

 
 This class defines the global functions of the watchkit app.
*/

import Foundation
import WatchKit

extension WKInterfaceController {
    
    /// Set *userDataDictionary* entries to defaults values; Avoids getting nil exceptions
    func setUserDataToDefaultValues () {
        
        /// Ensures that the *userDataDictionary* does not exceed the limit fixed; Limit = 30 entries;
        while userDataDictionary.count > 30 {
            userDataDictionary.remove(at: userDataDictionary.startIndex)
        }

        var endIndex = 29
        
        var date = Date()
        
        if userDataDictionary.count > 6 { endIndex = userDataDictionary.count }
       
        /// For all entries in user data dictionary
        for _ in 0...endIndex {

            let dateString = formatDateToString(date: date)
            
            var dataOfSpecificDate = Dictionary<String, Any>()
            
            /// If entry exists for date
            if let dateString = userDataDictionary[dateString] {
    
                dataOfSpecificDate = dateString
                
                /// If moods stored in entry, keeps entry
                if dataOfSpecificDate["moods"] == nil {
                    dataOfSpecificDate["moods"] = [Int]()
                }
            }

            /// Sets values to default
            dataOfSpecificDate["day"] = date.dayOfWeek() // Sets day ("MON")
            dataOfSpecificDate["bedtime"] = "-"
            dataOfSpecificDate["inBed"] = "-"
            dataOfSpecificDate["steps"] = "-"

            /// Updates entry
            userDataDictionary.updateValue(dataOfSpecificDate, forKey: dateString)

            /// Moves to previous day
            if let currentDate = Calendar.current.date(byAdding: .day, value: -1, to: date) {
               date = currentDate
            }
        }
        /// Initialises the *pastWeekBedtimes* to new list
        past3Bedtimes = [String]()
    }
    
    /// Sorts *userDataDictionnary* by date (descending)
    func sortDescendingDate(array: [String: [String : Any]]) -> [Dictionary<String, [String : Any]>.Element] {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale.current
        dateFormatter.timeZone = TimeZone.current
        return array.sorted { dateFormatter.date(from: $0.0)! > dateFormatter.date(from: $1.0)! }
    }
    
    /// Initialises the encouragements to the stored values
    func setEncouragementsDefault(){
        do {
            /// Retrieves the status of the encouragements;
            /// Must do so as *Data* type as a custom object cannot be stored in UserDefaults
            if let data = defaults.data(forKey: "encouragements") {
                do {
                    /// Creates JSON Decoder
                    let decoder = JSONDecoder()

                    /// Decodes Encouragements
                    encouragements = try decoder.decode([String:Encouragement].self, from: data)

                } catch {
                    print("\n ERROR - Unable to decode encouragements: (\(error))")
                }
            }
        }
    }
    
    /// Checks whether the user has unlocked any encouragement
    func isAnyEncouragementUnlocked () {
        bedBeforeMidnight3Row ()
        moodsThisWeek()
        totalNumberMoods()
        moodPastWeeks()
    }
    
    /// Checks if the encouragement rewarding user for going to bed before midnight 3 nights in a row is unlocked
    func bedBeforeMidnight3Row () {

        if (past3Bedtimes.count == 3) {
            let bedtimeYesterday = past3Bedtimes[0]
            let bedtime2DaysAgo = past3Bedtimes[1]
            let bedtime3DaysAgo = past3Bedtimes[2]
            
            if (bedtimeYesterday != "-" && bedtime2DaysAgo != "-" && bedtime3DaysAgo != "-") {
               let fullTimeYesterday = bedtimeYesterday.split(separator: "h")
               let fullTime2DaysAgo = bedtime2DaysAgo.split(separator: "h")
               let fullTime3DaysAgo = bedtime3DaysAgo.split(separator: "h")

               if fullTimeYesterday.count > 0, let hours = fullTimeYesterday.first, let hoursYesterday = Int(hours),
               fullTime2DaysAgo.count > 0, let hours2D = fullTime2DaysAgo.first, let hours2DaysAgo = Int(hours2D),
               fullTime3DaysAgo.count > 0, let hours3D = fullTime3DaysAgo.first, let hours3DaysAgo = Int(hours3D) {
                    
                    /// If user has gone to bed before midnight 3 nights in a row (bedtime between 19:00 and 23:00)
                    if (hoursYesterday >= 19 && hours2DaysAgo >= 19 && hours3DaysAgo >= 19 &&
                        hoursYesterday <= 23 && hours2DaysAgo <= 23 && hours3DaysAgo <= 23) {
                        
                        /// Update status of the prompt to unlocked
                         if let prompt = encouragements["bedBeforeMidnight3Row"] {
                              prompt.unlock()
                              encouragements.updateValue(prompt, forKey: "bedBeforeMidnight3Row")
                         }
                       
                        /// Waits three days to make the encouragement enabled again
                        let threeDays = DispatchTimeInterval.seconds(60 * 60 * 24 * 3)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + threeDays) {
                            
                            /// Update status of the prompt to enable
                            if let prompt = encouragements["bedBeforeMidnight3Row"] {
                              prompt.enableFutureDisplay()
                              encouragements.updateValue(prompt, forKey: "bedBeforeMidnight3Row")
                            }
                           
                            
                            /// Stores the new status of the encouragements;
                            /// Must do so as *Data* type as a custom object cannot be stored in UserDefaults
                            do {
                                let encoder = JSONEncoder()

                                /// Encodes Encouragements
                                let data = try encoder.encode(encouragements)
                                defaults.set(data, forKey: "encouragements")
                            }
                            catch {
                                print("\n ERROR - Unable to encode Encouragements: (\(error))")
                                
                            }
                        }
                    }
               }
            }
        }
        
        /// Initialises the *pastWeekBedtimes* to new list
        past3Bedtimes = [String]()
    }

    /// Checks if there was a mood streak this week (3 days or 7 days)
    func moodsThisWeek () {

        /// If user has recorded 3 moods this week
        if past7DaysLogs.count == 3 {
            
            if let moods3ThisWeek = encouragements["moods3ThisWeek"] {
                /// Update status of the prompt to unlocked
                moods3ThisWeek.unlock()
                encouragements.updateValue(moods3ThisWeek, forKey: "moods3ThisWeek")
                
                /// Stores the new status of the encouragements;
                /// Must do so as *Data* type as a custom object cannot be stored in UserDefaults
                do {
                    let encoder = JSONEncoder()

                    /// Encodes Encouragements
                    let data = try encoder.encode(encouragements)
                    defaults.set(data, forKey: "encouragements")
                }
                catch {
                    print("\n ERROR - Unable to encode Encouragements: (\(error))")
                    
                }
                
                /// Waits three days to make the encouragement enabled again
                let threeDays = DispatchTimeInterval.seconds(60 * 60 * 24 * 3)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + threeDays) {
                    
                    if let moods3ThisWeek = encouragements["moods3ThisWeek"] {
                        /// Update status of the prompt to enable
                        moods3ThisWeek.enableFutureDisplay()
                        encouragements.updateValue(moods3ThisWeek, forKey: "moods3ThisWeek")
                        
                        /// Stores the new status of the encouragements;
                        /// Must do so as *Data* type as a custom object cannot be stored in UserDefaults
                        do {
                            let encoder = JSONEncoder()

                            /// Encodes Encouragements
                            let data = try encoder.encode(encouragements)
                            defaults.set(data, forKey: "encouragements")
                        }
                        catch {
                            print("\n ERROR - Unable to encode Encouragements: (\(error))")
                        }
                    }
                }
            }
            
        }

        /// If user has recorded 7 moods this week
        if past7DaysLogs.count == 7 {
            
            /// Update status of the prompt to unlocked
            if let moods7DaysThisWeek = encouragements["moods7DaysThisWeek"] {
                moods7DaysThisWeek.unlock()
                encouragements.updateValue(moods7DaysThisWeek, forKey: "moods7DaysThisWeek")
                
                /// Stores the new status of the encouragements;
                /// Must do so as *Data* type as a custom object cannot be stored in UserDefaults
                do {
                    let encoder = JSONEncoder()

                    /// Encodes Encouragements
                    let data = try encoder.encode(encouragements)
                    defaults.set(data, forKey: "encouragements")
                }
                catch {
                    print("\n ERROR - Unable to encode Encouragements: (\(error))")
                }
                
                /// Waits seven days to make the encouragement enabled again
                let threeDays = DispatchTimeInterval.seconds(60 * 60 * 24 * 7)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + threeDays) {
                    
                    /// Update status of the prompt to enable
                    if let prompt = encouragements["moods7ThisWeek"] {
                         prompt.enableFutureDisplay()
                         encouragements.updateValue(prompt, forKey: "moods7ThisWeek")
                    }
               
                    /// Stores the new status of the encouragements;
                    /// Must do so as *Data* type as a custom object cannot be stored in UserDefaults
                    do {
                        let encoder = JSONEncoder()

                        /// Encodes Encouragements
                        let data = try encoder.encode(encouragements)
                        defaults.set(data, forKey: "encouragements")
                    }
                    catch {
                        print("\n ERROR - Unable to encode Encouragements: (\(error))")
                    }
                }
            }
        }
        /// Initialises the *past7DaysLogs* to new list
        past7DaysLogs = [Any]()
    }

    /// Checks if the total number of moods logged is enough to unlock an encouragement (15, 30, 50, 70, 100)
    func totalNumberMoods () {
        
        /// Retrieves the *totalMoodsLogged* if stored
        if let totalMoods = defaults.object(forKey: "totalMoodsLogged") as? Int {
            totalMoodsLogged = totalMoods
            
            /// This week, user has recorded *i* moods
            switch totalMoodsLogged {
                case 15:
                    if let moods15 = encouragements["moods15"] {
                        /// Update status of the prompt to unlocked
                        moods15.unlock()
                        encouragements.updateValue(moods15, forKey: "moods15")
                    }
                case 30:
                    if let moods30 = encouragements["moods30"] {
                        /// Update status of the prompt to unlocked
                        moods30.unlock()
                        encouragements.updateValue(moods30, forKey: "moods30")
                    }
                case 50:
                    if let moods50 = encouragements["moods50"] {
                        /// Update status of the prompt to unlocked
                        moods50.unlock()
                        encouragements.updateValue(moods50, forKey: "moods50")
                    }
                case 70:
                    if let moods70 = encouragements["moods70"]{
                        /// Update status of the prompt to unlocked
                        moods70.unlock()
                        encouragements.updateValue(moods70, forKey: "moods70")
                    }
                case 100:
                    if let moods100 = encouragements["moods100"]{
                        /// Update status of the prompt to unlocked
                       moods100.unlock()
                       encouragements.updateValue(moods100, forKey: "moods100")
                    }
                default: break
            }
            /// Stores the new status of the encouragements;
            /// Must do so as *Data* type as a custom object cannot be stored in UserDefaults
            do {
                let encoder = JSONEncoder()

                /// Encodes Encouragements
                let data = try encoder.encode(encouragements)
                defaults.set(data, forKey: "encouragements")
            }
            catch {
                print("\n ERROR - Unable to encode Encouragements: (\(error))")
            }
        }
    }
    
    /// Checks if the user has logged moods in the past weeks to trigger a streak (e.g. moods logged in past 4 weeks)
    func moodPastWeeks (){
        let now = Date()

        /// Determines the date of 7 days ago and convert it to a String
        let aWeekAgo = formatDateToString(date: Calendar.current.date(byAdding: .day, value: -7, to: now)!)
    
       /// Determines the date of 14 days ago and convert it to a String
        let twoWeeksAgo = formatDateToString(date: Calendar.current.date(byAdding: .day, value: -14, to: now)!)
        
        /// Determines the date of 14 days ago and convert it to a String
        let threeWeeksAgo = formatDateToString(date: Calendar.current.date(byAdding: .day, value: -21, to: now)!)
        
        /// Determines the date of 14 days ago and convert it to a String
        let fourWeeksAgo = formatDateToString(date: Calendar.current.date(byAdding: .day, value: -28, to: now)!)
        
        /// Determines the date of 14 days ago and convert it to a String
        let fiveWeeksAgo = formatDateToString(date: Calendar.current.date(byAdding: .day, value: -35, to: now)!)
        
        /// Determines the date of 14 days ago and convert it to a String
        let sixWeeksAgo = formatDateToString(date: Calendar.current.date(byAdding: .day, value: -42, to: now)!)
        
        /// Determines the date of 14 days ago and convert it to a String
        let sevenWeeksAgo = formatDateToString(date: Calendar.current.date(byAdding: .day, value: -49, to: now)!)
        
        /// Determines the date of 14 days ago and convert it to a String
        let eightWeeksAgo = formatDateToString(date: Calendar.current.date(byAdding: .day, value: -56, to: now)!)

        /// Initialises the array to 8 false bools; Each value represents whether a mood was recorded in the corresponding week of treatment
        var array = [false,false,false,false,false,false,false,false]

       for entry in userDataDictionary {

            /// If a mood was recorded on that date
            if let _ = entry.value["moods"] {
                
                /// If date falls in week 1 of treatment
                if (entry.key <= aWeekAgo){
                           array[0] = true
                }
                /// If date falls in week 2 of treatment
                if (entry.key > aWeekAgo && entry.key <= twoWeeksAgo){
                           array[1] = true
                }
                /// If date falls in week 3 of treatment
                if (entry.key > twoWeeksAgo && entry.key <= threeWeeksAgo){
                           array[2] = true
                }
                /// If date falls in week 4 of treatment
                if (entry.key > threeWeeksAgo && entry.key <= fourWeeksAgo){
                         array[3] = true
                }
                /// If date falls in week 5 of treatment
                if (entry.key > fourWeeksAgo && entry.key <= fiveWeeksAgo){
                           array[4] = true
                }
                /// If date falls in week 6 of treatment
                if (entry.key > fiveWeeksAgo && entry.key <= sixWeeksAgo){
                           array[5] = true
                }
                /// If date falls in week 7 of treatment
                if (entry.key > sixWeeksAgo && entry.key <= sevenWeeksAgo){
                         array[6] = true
                }
                /// If date falls in week 8 of treatment
                if (entry.key > sevenWeeksAgo && entry.key <= eightWeeksAgo){
                         array[7] = true
                }
            }
        }
    
        var promptToDisplay = ""
        
        /// Moods logged in past 7 weeks
        if (array[0] && array[1] && array [2] && array[3] && array[4] && array[5] && array[6]){
            promptToDisplay = "moodsPast7Weeks"
        }
        /// Moods logged in past 6 weeks
        else if (array[1] && array [2] && array[3] && array[4] && array[5] && array[6]) ||
            (array[0] && array[1] && array [2] && array[3] && array[4] && array[5]) {
            
            promptToDisplay = "moodsPast6Weeks"
        }
        /// Moods logged in past 5 weeks
        else if (array [2] && array[3] && array[4] && array[5] && array[6]) ||
            (array[1] && array [2] && array[3] && array[4] && array[5]) ||
            (array[0] && array[1] && array [2] && array[3] && array[4]){
            
            promptToDisplay = "moodsPast5Weeks"
        }
        /// Moods logged in past 4 weeks
        else if (array [3] && array[4] && array[5] && array[6]) ||
            (array[2] && array [3] && array[4] && array[5]) ||
            (array[1] && array[2] && array [3] && array[4]) ||
            (array[0] && array[1] && array[2] && array[3]){
            
            promptToDisplay = "moodsPast4Weeks"
        }
        /// Moods logged in past 3 weeks
        else if (array[4] && array [5] && array[6]) ||
            (array[3] && array[4] && array [5]) ||
            (array[2] && array[3] && array[4]) ||
            (array[1] && array[2] && array[3]) ||
            (array[0] && array [1] && array[2]){
            
            promptToDisplay = "moodsPast3Weeks"
        }
        /// Moods logged in past 2 weeks
        else if (array[5] && array [6]) ||
            (array[4] && array [5]) ||
            (array[3] && array [4]) ||
            (array[2] && array [3]) ||
            (array[1] && array [2]) ||
            (array[0] && array [1]){
            
            promptToDisplay = "moodsPast2Weeks"
        }

        /// If there is a prompt to display, then unlock it and store its new status
        if promptToDisplay != "" {
            
               /// Updates status of the prompt to unlocked
               if let prompt = encouragements[promptToDisplay] {
                    prompt.unlock()
                    encouragements.updateValue(prompt, forKey: promptToDisplay)
               }
          
            /// Stores the new status of the encouragements;
            /// Must do so as *Data* type as a custom object cannot be stored in UserDefaults
            do {
                let encoder = JSONEncoder()

                /// Encodes Encouragements
                let data = try encoder.encode(encouragements)
                defaults.set(data, forKey: "encouragements")
            }
            catch {
                print("\n ERROR - Unable to encode Encouragements: (\(error))")
            }
        }
    }
}
