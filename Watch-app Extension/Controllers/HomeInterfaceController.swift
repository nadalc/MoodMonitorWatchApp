/**
 HomeInterfaceController.swift
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
 
 This class defines the main screen of the app.
 */

import WatchKit
import Foundation
import UserNotifications
import WatchConnectivity

/// Main screen of the watch app
class HomeInterfaceController: WKInterfaceController, URLSessionDelegate, WCSessionDelegate {
     
     /// Button which background represent the last mood logged today
     @IBOutlet weak var moodBtn: WKInterfaceButton!
     
     /// Label indicating when user went to bed last night
     @IBOutlet weak var bedtimeLabel: WKInterfaceLabel!
     
     /// Label indicating when the number of hours user slept last night
     @IBOutlet weak var sleepLabel: WKInterfaceLabel!
     
     /// Label indicating user current steps count of the day
     @IBOutlet weak var exerciseLabel: WKInterfaceLabel!
     
     /// Image of a moon more or less filled depending on user's number of hours slept
     @IBOutlet weak var inBedIcon: WKInterfaceImage!
     /// Image of a person walking, walking fast, or running depending user's current steps count
     @IBOutlet weak var exerciseIcon: WKInterfaceImage!
     
     /// Image of an arrow - arrow up = user went to bed earlier last night than previous night
     ///                     arrow down = user went to bed later last night than previous night
     ///                     arrow right = user went to bed at the same time last night as previous night
     @IBOutlet weak var bedtimeArrow: WKInterfaceImage!
     
     /// Image of an arrow - arrow up = user slept more last night than previous night
     ///                     arrow down = user slept less last night than previous night
     ///                     arrow right = user slept the same time last night as previous night
     @IBOutlet weak var inBedArrow: WKInterfaceImage!
     
     /// Image of an arrow - arrow up = user steps count is higher today than yesterday
     ///                     arrow down = user steps count is lower today than yesterday
     ///                     arrow right = user steps count is the same today as yesterday
     @IBOutlet weak var exerciseArrow: WKInterfaceImage!
     
     /// Table showing a visualisation of user's past week mood, sleep, and activity level
     @IBOutlet weak var summaryTable: WKInterfaceTable!
     
     /// Data to be displayed in the *summaryTable*
     var dataToDisplay = [DailyData]()
     
     private var observer: NSObjectProtocol!
     private var session: WCSession!
     override func awake(withContext context: Any?) {
          super.awake(withContext: context)
          
          retrieveMoodsFromDatabase()
          
          /// If 1st launch of the app, display Settings screen to allow user to schedule reminders
          if (!hasAlreadyLaunched) {
               showSettingsScreen()
               /// Stores that the app has already launched
               UserDefaults.standard.set(true, forKey: "hasAlreadyLaunched")
          }
          self.attachToPhone()
          sendHealthDataToDatabase()
     }
     
     private func setObserversForDataUpdate() {
          
          NotificationCenter.default.addObserver(self, selector: #selector(self.sendHealthDataToDatabase), name: NSNotification.Name(rawValue: "newHealthData"), object: nil)
          
          NotificationCenter.default.addObserver(self, selector: #selector(self.retrieveMoodsFromDatabase), name: NSNotification.Name(rawValue: "retrieveMoods"), object: nil)
          
          /// Observes for calls to update the *summaryTable*
          NotificationCenter.default.addObserver(self, selector: #selector(self.updateDisplay), name: NSNotification.Name(rawValue: "updateSummaryDisplay"), object: nil)
     }
     
     private func removeObserversForDataUpdate() {
          
          NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "newHealthData"), object: nil)
          
          NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "retrieveMoods"), object: nil)
          
          NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "updateSummaryDisplay"), object: nil)
     }
     
     /// Updates the daily visualisation of mood, bedtime, hours slept, steps count,
     /// with appropriate images and arrows
     @objc private func updateDisplay(){
          
          /// Updates interface elements
          let today = getTodaysDate(date:Date())
          
          var todaysData = [String:Any]()
          
          if let todaysDict = userDataDictionary[today] {
               todaysData = todaysDict
          }
          
          var moods = [Int]()
          
          if let todayMoods = todaysData["moods"] as? [Int] {
               moods = todayMoods
          }
          
          /// Sets the *moodBtn* background to the last mood recorded for today
          if moods.count > 0, let lastMood = moods.last {
               let moodImage = moodImageFromInt(mood: lastMood)
               moodBtn.setBackgroundImage(moodImage)
               past7DaysLogs.append(lastMood)
          }
          /// If no mood recorded today, *moodBtn* background is an image of dash
          else {
               let moodImage = UIImage.init(named: "dash")
               moodBtn.setBackgroundImage(moodImage)
          }
          
          /// Sets *bedtimeLabel* text with last night's bedtime
          /// if no bedtime recorded, *bedtimeLabel* is a dash
          var bedtime = "-"
          if let todayBedtime = todaysData["bedtime"] as? String{
               bedtime = todayBedtime.replacingOccurrences(of: ":", with: "h", options: .literal, range: nil)
          }
          bedtimeLabel.setText(bedtime)
          
          /// Sets *sleepLabel* text with last night's number of hours slept
          /// if no sleep data recorded, *inBedLabel* is a dash
          var inBed = "-"
          if let todayInBed = todaysData["inBed"] as? String {
               inBed = todayInBed.replacingOccurrences(of: ":", with: "h", options: .literal, range: nil)
          }
          sleepLabel.setText(inBed)
          
          /// Sets *bedtimeLabel* text with today's steps count
          /// if no steps count recorded, *exerciseLabel* is a dash
          var steps = "-"
          if let todaySteps = todaysData["steps"] as? String {
               steps = todaySteps
          }
          exerciseLabel.setText(steps)
          
          /// Sets approprate images for *inBedIcon* and *exerciseIcon* depending on user's slept hours and activity level
          if let bed = getInBedIcon(dateString: today) {
               inBedIcon.setImage(bed)
          }
          
          if let exercise = getExerciseIcon(dateString: today) {
               exerciseIcon.setImage(exercise)
          }
          
          /// Displays appropriate arrows to reflect the daily evolution of sleep and activity
          updateArrows(todaysData: todaysData)
          
          /// Populates weekly visualisation table with data from past 7 days
          displayDataInTable()
          
          self.displayEncouragements()
     }
     
     /// Displays the encouragements unlocked by the user
     private func displayEncouragements(){
          
          /// Check if user has unlocked any encouragement
          isAnyEncouragementUnlocked ()
          
          for encouragement in encouragements {
               /// Displays the prompt if the conditions are met and it hasn't been displayed yet
               if (encouragement.value.toBeDisplayed()) {
                    pushController(withName: "EncouragementInterfaceController", context: encouragement.value.identifier)
               }
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
     
     /// Updates the arrows to reflect the user's daily evolution of bedtime, slept hours and steps count
     private func updateArrows(todaysData: [String:Any]){
          
          /// Initialises the arrow images to "-"
          var inBedArrowImage = UIImage(named: "dash")
          var exerciseArrowImage = UIImage(named: "dash")
          
          /// Retreives yesterday's user data
          if let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) {
               let yesterdayString = formatDateToString(date: yesterday)
               
               /// Compares yesterday's data (if it exists) to today's data
               if let yesterdaysData = userDataDictionary[yesterdayString] {
                    
                    /// BEDTIME ARROW
                    var todaysBedtime = "-"
                    
                    /// Retreives today's bedtime
                    if let bedtime = todaysData["bedtime"] as? String {
                         todaysBedtime = bedtime
                         
                         /// Changes the format from "21:30" to "21h30" and adds the bedtime to *past3Bedtimes*
                         let string = todaysBedtime.replacingOccurrences(of: ":", with: "h", options: .literal, range: nil)
                         past3Bedtimes.append(string)
                    }
                    /// Retreives yesterday's bedtime
                    var yesterdaysBedtime = "-"
                    if let previousBedTime = yesterdaysData["bedtime"] as? String {
                         yesterdaysBedtime = previousBedTime
                    }
                    
                    /// Updates *bedtimeArrow*
                    if let bedtimeArrowImage = updateBedtimeArrow(todaysBedtime: todaysBedtime, yesterdaysBedtime: yesterdaysBedtime) {
                         bedtimeArrow.setImage(bedtimeArrowImage)
                    }
                    
                    /// NUMBER HOURS SLEPT ARROW
                    var todaysInBed = "-"
                    
                    /// Retreives today's number of hours slept
                    if  let inBed = todaysData["inBed"] as? String {
                         todaysInBed = inBed
                         
                         /// Retreives yesterday's number of hours slept
                         var yesterdaysInBed = "-"
                         if let previousInBed = yesterdaysData["inBed"] as? String {
                              yesterdaysInBed = previousInBed
                              if let arrowImage = updateInBedArrow(todaysTimeInBed: todaysInBed, yesterdaysTimeInBed: yesterdaysInBed) {
                                   inBedArrowImage = arrowImage
                              }
                         }
                    }
                    /// Updates *inBedArrow*
                    inBedArrow.setImage(inBedArrowImage)
                    
                    /// STEPS COUNT ARROW
                    var todaysStepsString = "-"
                    
                    /// Retreives today's steps count
                    if let steps = todaysData["steps"] as? String {
                         todaysStepsString = steps
                         
                         /// Retreives yesterday's steps count
                         var yesterdaysStepsString = "-"
                         if let previousSteps = yesterdaysData["steps"] as? String {
                              yesterdaysStepsString = previousSteps
                              exerciseArrowImage = updateStepsArrow(todaysStepsString: todaysStepsString, yesterdaysStepsString: yesterdaysStepsString)
                         }
                    }
                    /// Updates *exerciseArrow*
                    exerciseArrow.setImage(exerciseArrowImage)
               }
               
          }
     }
     
     /// Updates *bedtimeArrow*
     /// - Parameters:
     ///     - todaysBedtime: Time when user went to bed last night; Format "22:00", "22:30"
     ///     - yesterdaysBedtime: Time when user went to bed the night before last night; Format "22:00", "22:30"
     /// - Returns: image for *bedtimeArrow*
     private func updateBedtimeArrow(todaysBedtime: String, yesterdaysBedtime: String) -> UIImage? {
          
          var bedtimeArrowImage = UIImage(named: "dash")
          
          /// Checks if the bedtimes are known
          if todaysBedtime != "-" && yesterdaysBedtime != "-" {
               
               /// Arrow up: today's bedtime is in the afternoon/evening
               /// and yesterdays's bedtime is in the morning
               if todaysBedtime > "12:00" && yesterdaysBedtime < "12:00"{
                    bedtimeArrowImage = UIImage.init(systemName: "arrow.up")
               }
               
               /// Arrow down: today's bedtime is in the morning
               /// and yesterdays's bedtime is in the afternoon/evening
               else if todaysBedtime < "12:00" && yesterdaysBedtime > "12:00"{
                    bedtimeArrowImage = UIImage.init(systemName: "arrow.down")
               }
               /// if both bedtimes in the afternoon/evening, or both in the morning
               else {
                    /// Arrow up: today's bedtime is earlier than yesterday's
                    if (todaysBedtime < yesterdaysBedtime){
                         bedtimeArrowImage = UIImage.init(systemName: "arrow.up")
                    }
                    /// Arrow down: today's bedtime is later than yesterday's
                    else if (todaysBedtime > yesterdaysBedtime){
                         bedtimeArrowImage = UIImage.init(systemName: "arrow.down")
                    }
                    /// Arrow right: bedtimes are the same
                    else {
                         bedtimeArrowImage = UIImage.init(systemName: "arrow.right")
                    }
               }
          }
          return bedtimeArrowImage
     }
     
     /// Updates *inBedArrow*
     /// - Parameters:
     ///     - todaysTimeInBed: Number of hours slept last night; Format "6:00", "6:30"
     ///     - yesterdaysTimeInBed: Number of hours slept the night before last night; Format "6:00", "6:30"
     /// - Returns: image for *inBedArrow*
     private func updateInBedArrow(todaysTimeInBed: String, yesterdaysTimeInBed: String) -> UIImage? {
          
          var inBedArrowImage = UIImage(named: "dash")
          
          /// Checks if both number of hours slept are known
          if todaysTimeInBed != "-" && yesterdaysTimeInBed != "-" {
               
               /// Arrow up: today's number of hours slept is greater than yesterday's
               if todaysTimeInBed > yesterdaysTimeInBed {
                    inBedArrowImage = UIImage(systemName: "arrow.up")
               }
               
               /// Arrow down: today's number of hours slept is lower than yesterday's
               else if todaysTimeInBed < yesterdaysTimeInBed {
                    inBedArrowImage = UIImage(systemName: "arrow.down")
               }
               
               /// Arrow right: number of hours slept are the same
               else {
                    inBedArrowImage = UIImage(systemName: "arrow.right")
               }
          }
          return inBedArrowImage
     }
     
     /// Updates *exerciseArrow*
     /// - Parameters:
     ///     - todaysStepsCount: Today's steps counts; Format "5702"
     ///     - yesterdaysStepsCount: Yesterday's steps count; Format "5702"
     /// - Returns: image for *exerciseArrow*
     private func updateStepsArrow(todaysStepsString: String, yesterdaysStepsString: String) -> UIImage? {
          
          var exerciseArrowImage = UIImage.init(named: "dash")
          
          /// Checks if both steps counts are known
          if todaysStepsString != "-" && yesterdaysStepsString != "-" {
               
               /// Convert the Strings to Int values
               if let todaysStepsCount = Int(todaysStepsString), let yesterdaysStepsCount = Int(yesterdaysStepsString) {
                    /// Arrow up: today's steps count is higher than yesterday's
                    if todaysStepsCount > yesterdaysStepsCount {
                         exerciseArrowImage = UIImage.init(systemName: "arrow.up")
                    }
                    /// Arrow down: today's steps count is lower than yesterday's
                    else if todaysStepsCount < yesterdaysStepsCount {
                         exerciseArrowImage = UIImage.init(systemName: "arrow.down")
                    }
                    /// Arrow right: steps counts are the same
                    else {
                         exerciseArrowImage = UIImage.init(systemName: "arrow.right")
                    }
               }
               
          }
          return exerciseArrowImage
     }
     
     /// Updates the weekly display in *summaryTable*
     private func displayDataInTable() {
          
          /// Instantiates the appropriate number of rows: 7 or less if days with no data to display
          createTableRows()
          summaryTable.setNumberOfRows(dataToDisplay.count, withRowType: "SummaryRowController")
          
          /// For each row, initialises the day, mood image, bedtime, number of hours slept and steps count
          for (index, dailyData) in dataToDisplay.enumerated() {
               
               let row = summaryTable.rowController(at: index) as! SummaryRowController
               
               /// Sets the day; Format "MON"
               row.setDayLabel(day: dailyData.day)
               
               /// Sets the mood image to the last mood stored for *index*; Default value = 99
               var moodValue = 99
               if dailyData.moods.count > 0,  let last = dailyData.moods.last {
                    moodValue = last
                    
                    /// Stores mood log of past week
                    past7DaysLogs.append(dailyData)
               }
               let moodImage = moodImageFromInt(mood: moodValue)
               row.setMoodImage(image: moodImage)
               
               /// Sets the bedtime, hours slept and steps count labels
               row.setBedtimeLabel(bedtime: dailyData.bedtime)
               row.setInBedLabel(inBed: dailyData.inBed)
               row.setExerciseLabel(exercise: dailyData.steps)
               
               /// Sets the appropriate icons for sleep and activity level
               if let bedIcon = getInBedIcon(dateString: dailyData.date) {
                    row.setSleepIcon(image: bedIcon)
               }
               
               /// Stores bedtimes of past 3 nights
               if (index <= 1) {
                    /// Stores bedtime in the *pastWeekBedtimes* list
                    past3Bedtimes.append(dailyData.bedtime)
               }
          }
     }
     
     /// Creates the appropriate number of rows in the *summaryTable*
     /// and fill in the *dataToDisplay* array with the data from past 7 days
     private func createTableRows(){
          
          /// Initialises *arrayOfDates* with the dates of the past 7 days
          var arrayOfDates = [String]()
          var date = Date ()
          for _ in 0...6 {
               arrayOfDates.append(formatDateToString(date: date))
               if let currentDate = Calendar.current.date(byAdding: .day, value: -1, to: date) {
                    date = currentDate
               }
          }
          
          /// Default values for a row
          var day = "-"
          var moods = [Int]()
          var bedtime = "-"
          var inBed = "-"
          var steps = "-"
          
          /// Sorts *userDataDictionnary* by date (descending)
          var sortedArray = sortDescendingDate(array: userDataDictionary)
          
          /// Starts the table at yesterday; Removes today's entry
          sortedArray.remove(at: 0)
          
          /// Fill in the *dataToDisplay* array with the data from past 7 days
          if (sortedArray.count > 0){
               
               /// Empties array; Avoids duplicates in case of multiple calls to *createTableRows* function
               dataToDisplay.removeAll()
               
               /// Add daily data to the *dataToDisplay* array
               for(dateString, dailyData) in sortedArray {
                    
                    /// If *dateString* is within past 7 days, adds *dailyData* to the date to *dataToDisplay* array
                    if arrayOfDates.contains(dateString) {
                         /// Retreives day, bedtime, hours slept, steps and moods for *dateString* if they exist
                         if let dDay = dailyData["day"] as? String {
                              day = dDay
                         }
                         
                         if let dBedtime = dailyData["bedtime"] as? String {
                              bedtime = dBedtime
                         }
                         
                         if let dInBed = dailyData["inBed"] as? String {
                              inBed = dInBed
                         }
                         
                         if let dSteps = dailyData["steps"] as? String {
                              steps = dSteps
                         }
                         
                         if let dMoods = dailyData["moods"] as? [Int] {
                              moods = dMoods
                         }
                         /// If no mood, instanciate an empty one so that the icon displayed is the dash
                         /// Otherwise, this will create a bug in the display 
                         else {
                              moods = [Int]()
                         }
                         
                         /// Instanciates a new DailyData entry and adds it to the *dataToDisplay* array
                         let newData = DailyData(date: dateString, day: day, moods: moods, bedtime: bedtime, inBed: inBed, steps: steps)
                         dataToDisplay.append(newData)
                    }
               }
          }
     }
     
     @objc private func retrieveMoodsFromDatabase() {
          
          DispatchQueue.main.async {
                    
               /// Initialises the dictionary to build JSON from
               var dict = Dictionary<String,Any>()
               
               /// Creates and sends a JSON file containing the data
               let jsonData: NSData
               do {
                    jsonData = try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions()) as NSData
                    if let jsonString = NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue) {
                         let url = "" // REPLACE WITH YOUR ENDPOINT HERE
                         self.sendAndRetrieveMoodsJSONAPI(jsonData: jsonString as String, endpoint: url)
                    }
               }
               catch _ {}
          }
     }
     
     /// Sends a JSON containing the moods logged through the Watch to the client's account
     /// Retrieve the moods already in client's account and sends them to the Watch for display
     func sendAndRetrieveMoodsJSONAPI(jsonData: String, endpoint: String){
          if let url =  URL(string: endpoint) {
               var apiRequest = URLRequest(url: url)
               var body = jsonData
               apiRequest.httpMethod = "POST"
               body = body.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
               apiRequest.httpBody = (jsonData as NSString).data(using: String.Encoding.utf8.rawValue)
               apiRequest.setValue(endpoint, forHTTPHeaderField:"Referer")
               apiRequest.setValue("application/json", forHTTPHeaderField:"Content-Type")
               let config = URLSessionConfiguration.default
               let session = Foundation.URLSession(configuration: config, delegate: self, delegateQueue: nil)
               
               let task = session.dataTask(with: apiRequest, completionHandler: {
                    (responseData, response, error) in
                    
                    /// Handles the list of moods received in response
                    if let responseData = responseData {
                         do {
                              var answer = ""
                              if let jsonAnswer = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers) as? [String:Any], jsonAnswer["all_moods"] != nil {
                                   answer = jsonAnswer["all_moods"]! as! String
          
                                   /// Sends the retrieved moods to the Watch for display
                                   self.moodReceivedFromDatabase(moodData: answer)
                              }
                         } catch _ {}
                    }
               })
               task.resume()
          }
          // FOR TEST PURPOSES - REMOVE ONCE YOU RECEIVE FROM YOUR DATABASE
          self.moodReceivedFromDatabase(moodData: "")
     }
     
     func moodReceivedFromDatabase(moodData: String){
         
          DispatchQueue.main.async {
               
               let jsonData = moodData.data(using: .utf8)!
               
               /// DECODE YOUR JSON HERE
            //   let moods: [MoodType] = try! JSONDecoder().decode([MoodType].self, from: jsonData)
               
               /// DATA FOR TEST PURPOSES - REMOVE THAT ONCE YOU HAVE YOUR JSON DATA
               let now = Date()
               let today = "\(formatDateToString(date:now)) 10:00"
               let mood1 = Mood(value: 5, factors: ["Sleep"], datetime: today)
               
               let yesterday = "\(formatDateToString(date:Calendar.current.date(byAdding: .day, value: -1, to: now)!)) 10:00"
               let mood2 = Mood(value: 2, factors: ["Diet"], datetime: yesterday)
               
               let twoDaysAgo = "\(formatDateToString(date:Calendar.current.date(byAdding: .day, value: -2, to: now)!)) 10:00"
               let mood3 = Mood(value: 1, factors: ["Exercise"], datetime: twoDaysAgo)
               
               let threeDaysAgo = "\(formatDateToString(date:Calendar.current.date(byAdding: .day, value: -3, to: now)!)) 10:00"
               let mood4 = Mood(value: 4, factors: ["Medication"], datetime: threeDaysAgo)
               
               let fourDaysAgo = "\(formatDateToString(date:Calendar.current.date(byAdding: .day, value: -4, to: now)!)) 10:00"
               let mood5 = Mood(value: 3, factors: ["Coffee"], datetime: fourDaysAgo)
               
               let fiveDaysAgo = "\(formatDateToString(date:Calendar.current.date(byAdding: .day, value: -5, to: now)!)) 10:00"
               let mood6 = Mood(value: 4, factors: ["Sleep"], datetime: fiveDaysAgo)
               
               let sixDaysAgo = "\(formatDateToString(date:Calendar.current.date(byAdding: .day, value: -6, to: now)!)) 10:00"
               let mood7 = Mood(value: 5, factors: ["Sleep"], datetime: sixDaysAgo)
               
               let moods = [mood1, mood2, mood3, mood4, mood5, mood6, mood6]
               /// END OF DATA FOR TEST PURPOSES
               
               /// Checks if the mood date is within the past 7 days (*oldestDateToDisplay*)
               if let currentDate = Calendar.current.date(byAdding: .day, value: -7, to: Date()) {
                    oldestDateToDisplay = currentDate
               }
               
               /// Instanciates an array containing the list of *valueOfMood* for each *date*
               var temp = [(date: Date, valueOfMood: Int, time: String)] ()
               
               for mood in moods{
                    
                    let dateValue = mood.datetime.toDate(format: "yyyy-MM-dd HH:mm")
                    
                    let hour = Calendar.current.component(.hour, from: dateValue)
                    let minute = Calendar.current.component(.minute, from: dateValue)
                    let time = "\(hour):\(minute)"
                    
                    /// If mood was recorded in the past 7 days, adds it to the *arrayOfMoods* to be displayed
                    if (dateValue > oldestDateToDisplay){
                         temp.append((date: dateValue, valueOfMood: mood.value, time: time))
                    }
               }
               // Note at this point, there may ne no moods in the last 7 days.  So, nothing to update
               if(temp.count == 0) {
                    self.updateDisplay()
                    // Don't go any further, there's no data to map
                    return;
               }
               /// Sorts list of moods from most recent to oldest
               temp = temp.sorted(by: {
                    $0.date.compare($1.date) == .orderedDescending
               })
               
               /// Instanciates an array containing the list of *valueOfMood* for each *date*
               var arrayOfMoods = [(date: Date, valueOfMood: Int, time: String)] ()
               
               /// Stores most recent entry for date
               var newestEntryForDate = temp[0]
               arrayOfMoods.append((date: temp[0].date, valueOfMood: temp[0].valueOfMood, time: temp[0].time))
               
               /// Stores only the most recent mood for each date
               for i in 1..<temp.count{
                    
                    let previousEntryDate = formatDateToString(date: newestEntryForDate.date)
                    let currentEntryDate = formatDateToString(date: temp[i].date)
                    
                    /// If current entry date is different from previous entry date
                    if (currentEntryDate != previousEntryDate){
                         arrayOfMoods.append((date: temp[i].date, valueOfMood: temp[i].valueOfMood, time: temp[i].time))
                         newestEntryForDate = temp[i]
                    }
               }
               /// For each mood entry in *arrayOfMoods*, adds it to *userDataDictionary*
               for moodReceived in arrayOfMoods{
                    
                    /// Gets the string value for the date of the mood
                    let dateString = formatDateToString(date: moodReceived.date)
                    
                    var dataStoredForDate = Dictionary<String, Any>()
                    
                    /// Retrieves the data stored in *userDataDictionary* for that *dateString*
                    /// if it exists
                    if let dateStringValue = userDataDictionary[dateString] {
                         
                         dataStoredForDate = dateStringValue
                         
                         /// If mood already stored for that date
                         if let _ = dataStoredForDate["moods"]{
                              
                              let moodStoredTime = dataStoredForDate["time"] as! String
                              
                              /// Keeps most recent mood
                              if (moodReceived.time < moodStoredTime){
                                   /// Stores the value of the mood
                                   dataStoredForDate["moods"] = [moodReceived.valueOfMood]
                                   
                                   /// Stores the time of the mood
                                   dataStoredForDate["time"] = moodReceived.time
                              }
                         }
                         /// Reset the moods entry for that date
                         else {
                              /// Stores the value of the mood
                              dataStoredForDate["moods"] = [moodReceived.valueOfMood]
                              
                              /// Stores the time of the mood
                              dataStoredForDate["time"] = moodReceived.time
                         }
                    }
                    /// Stores the entry in *userDataDictionary*
                    userDataDictionary.updateValue(dataStoredForDate, forKey: dateString)
               }
               /// Triggers an update of the display of the home screen
               self.updateDisplay()
          }
     }
     
     @objc private func sendHealthDataToDatabase(){
          /// Sends Activity Level via JSONAPI
          DispatchQueue.main.async {
               
               /// Initialises the dictionary to build JSON from
               var dict = Dictionary<String,Any>()
               
               var stepsString = ""
               
               for entry in userDataDictionary {
                    
                    /// If stepsCount was recorded, adds it to dictionary *dict* with the record date
                    if let steps = entry.value["steps"] as? String{
                         stepsString = steps
                         
                         if (stepsString != "-") {
                              /// Sets the stepsCount as an activity level (0-5) in *dict*
                              dict["exercise"] = self.getActivityLevelFromSteps(stepsString: stepsString)
                              
                              /// Sets the date of entry record in *dict*
                              let hour = Calendar.current.component(.hour, from: Date())
                              let minute = Calendar.current.component(.minute, from: Date())
                              
                              /// Formats the date to "yyyy-MM-dd HH:mm"
                              let dateTime = "\(entry.key) \(hour):\(minute)"
                              dict["datetime"] = dateTime
                              
                              /// Creates and sends a JSON file containing the data
                              let jsonData: NSData
                              do {
                                   jsonData = try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions()) as NSData
                                   if let jsonString = NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue) {
                                        let url = "" // REPLACE WITH YOUR ENDPOINT HERE
                                        self.sendLifestyleJSONAPI(jsonData: jsonString as String, endpoint: url)
                                   }
                              }
                              catch _ {}
                         }
                    }
               }
          }
          /// Sends Hours Slept via JSONAPI
          DispatchQueue.main.async {
               
               /// Initialises the dictionary to build JSON from
               var dict = Dictionary<String,Any>()
               
               var inBedString = ""
               
               for entry in userDataDictionary {
                    
                    /// If stepsCount was recorded, adds it to dictionary *dict* with the record date
                    if let inBed = entry.value["inBed"] as? String {
                         inBedString = inBed
                         
                         if (inBedString != "-") {
                              /// Sets the stepsCount as an activity level (0-5) in *dict*
                              dict["sleep"] = self.getHoursSleptFromTimeInBed(inBed: inBedString)
                              
                              /// Sets the date of entry record in *dict*
                              let hour = Calendar.current.component(.hour, from: Date())
                              let minute = Calendar.current.component(.minute, from: Date())
                              
                              /// Formats the date to "yyyy-MM-dd HH:mm"
                              let dateTime = "\(entry.key) \(hour):\(minute)"
                              dict["datetime"] = dateTime
                              
                              /// Creates and sends a JSON file containing the data
                              let jsonData: NSData
                              do{
                                   jsonData = try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions()) as NSData
                                   if let jsonString = NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue) {
                                        let url = "" // REPLACE WITH YOUR ENDPOINT HERE
                                        self.sendLifestyleJSONAPI(jsonData: jsonString as String, endpoint: url)
                                   }
                              }
                              catch _ { }
                         }
                    }
               }
          }
          
     }
     
     /// Sends a JSON containing the data from the Watch (lifestyle choices) to the client's account
     func sendLifestyleJSONAPI(jsonData: String, endpoint: String){
          if let url = URL(string: endpoint) {
               var apiRequest = URLRequest(url: url)
               var body = jsonData
               apiRequest.httpMethod = "POST"
               body = body.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
               apiRequest.httpBody = (jsonData as NSString).data(using: String.Encoding.utf8.rawValue)
               apiRequest.setValue(endpoint, forHTTPHeaderField:"Referer")
               apiRequest.setValue("application/json", forHTTPHeaderField:"Content-Type")
               let config = URLSessionConfiguration.default
               let session = Foundation.URLSession(configuration: config, delegate: self, delegateQueue: nil)
               let task = session.dataTask(with: apiRequest, completionHandler: {
                    (responseData, response, error) in
               })
               task.resume()
          }
     }
     
     /// Formats the time *inBed* to an integer with only the hours value
     /// Parameter: inBed: String containing the time in bed; Format "09:00"
     /// Returns an Int corresponding to the number of hours spent in bed
     func getHoursSleptFromTimeInBed (inBed: String) -> Int {
          
          /// Initialises the activity level to average (7/15)
          var stringHoursSlept = inBed.prefix(2)
          
          /// If the number of hours slept is like "08", then drop the first zero
          if stringHoursSlept.prefix(1) == "0" {
               stringHoursSlept = stringHoursSlept.dropFirst()
          }
          return Int(stringHoursSlept) ?? 0
     }
     
     /// Formats the time *stepsString* to an integer corresponding to the activity level (0-5)
     /// Parameter: stepsString: String containing the steps count; Format "5690"
     /// Returns an Int corresponding to the activity level
     func getActivityLevelFromSteps(stepsString: String) -> Int{
          
          let stepsCount = Int(stepsString)!
          /// Initialises the activity level to average (3/5)
          var activityLevel = 3
          
          /// Associates an appropriate activity level for the number of steps achieved
          if (stepsCount >= 10000){
               activityLevel = 5
          }
          else if (stepsCount >= 8000 && stepsCount < 10000){
               activityLevel = 4
          }
          else if (stepsCount >= 5000 && stepsCount < 8000){
               activityLevel = 3
          }
          else if (stepsCount >= 2000 && stepsCount < 5000){
               activityLevel = 2
          }
          else if (stepsCount >= 1 && stepsCount < 2000){
               activityLevel = 1
          }
          /// We decide not to attribute an activity level of 0 as a nil steps count might be due to a technical issue
          return activityLevel
     }
     
     /// In the menu, when user tap 'Log Mood', displays Mood Selector screen
     @IBAction func menuItemLogMoodPressed() {
          pushController(withName: "MoodSelectorInterfaceController", context: [])
     }
     
     /// In the menu, when user tap 'Tips', displays Tips to Stay Well screen
     @IBAction func menuItemTipsPressed() {
          pushController(withName: "TipInterfaceController", context: [])
     }
     
     /// In the menu, when user tap 'Settings', displays Settings screen
     @IBAction func menuItemSettingsPressed() {
          presentController(withName: "SettingsInterfaceController", context: [])
     }
     
     /// This method is called when watch view controller is about to be visible to user
     override func willActivate() {
          
          /// Instanciates/clear the *dataToDisplay* array
          dataToDisplay = [DailyData]()
          
          /// Sets observers for new mood logged and new retrieval of number hours slept and steps count
          /// This will then send the new data to the iOS app
          setObserversForDataUpdate()
          
          /// Triggers the reading of HealthKit data; Bedtime, number of hours slept and steps count.
          NotificationCenter.default.post (name: Notification.Name("watchCheckForNewHealthData"), object: [])
          
          /// Refresh data to display in case we received new HealthKit data
          updateDisplay()
          
          /// Retrieve moods to display
          retrieveMoodsFromDatabase()
          
          super.willActivate()
     }
     
     @objc func showSettingsScreen(){
          presentController(withName: "SettingsInterfaceController", context: [])
     }
     
     /// This method is called when watch view controller is no longer visible
     override func didDeactivate() {
          super.didDeactivate()
          
          /// Removes observer when the app goes to background
          removeObserversForDataUpdate()
     }
     
     func attachToPhone() {
          if !WCSession.isSupported() {
               return
          }
          WCSession.default.delegate = self
          self.session = WCSession.default
          WCSession.default.activate()
     }
     
     // WKSession stuff
     func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
          
     }
     
     func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
     }
     
}
