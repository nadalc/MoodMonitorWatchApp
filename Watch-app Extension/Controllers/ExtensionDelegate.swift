/**
  ExtensionDelegate.swift
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
 
 This class defines the Extension Delegate of the WatchKit Extension and the global variables of the watch app.
*/

import WatchKit
import HealthKit
import UserNotifications

/** Start of initialisation of the Global Variables for the Watch app
 */

/// Initialises a variable to back up user data (e.g. if the watch is rebooted)
let defaults = UserDefaults.standard

/// Initialises a dictionary with user's data for the past week
/// Format: ["01:01:2019" : ["day":"MON"], ["moods":[1,4]], ["bedtime":"11:30"], ["inBed":"6:00"], ["stepsCount":"1590"]]
var userDataDictionary = [String: [String : Any]]()

/// Initialises the list of factors influencing the mood
var listOfFactors = [String]()

/// Initialises the values of reminders switches (On/Off) in the Settings screen
var reminder9To12 = Bool()
var reminder12To16 = Bool()
var reminder16To20 = Bool()
var reminder20To23 = Bool()

/// Initialises the list of tips
var copyTips = [String]()

/// Initialises the number of moods logged via the watch
var totalMoodsLogged = 0

/// Initialises an array containing Encouragements
var encouragements = [String:Encouragement]()

/// Variable used to check user's bedtime over time and see if they have unlocked an encouragement badge
var past3Bedtimes = [String]()

/// Variable used to check user's logs and see if they have unlocked an encouragement badge
var past7DaysLogs = [Any]()

/// Initialises the Boolean recording if it's the 1st launch of the app
var hasAlreadyLaunched = false

var currentMoodData = [String:Any] ()

/// Initialises a gloabal variable containing the date of the 7 days ago
var oldestDateToDisplay = Date()

/** End of initialisation of the Global Variables for the Watch app
*/

class ExtensionDelegate: NSObject, WKExtensionDelegate, UNUserNotificationCenterDelegate  {
    
    /// Health Store used to request authorisation to the HealthKit data
    private let healthStore = HKHealthStore()
    
    /// Health Data Manager to handled the reading of HealthKit data
    private let healthDataManager = HealthDataManager()
    
    private let limitEntry = 30
     
    func applicationDidFinishLaunching() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            /// Asks user for permission to access HealthKit data
            _ = self.requestAuthorisationHealthKit()
            
            /// Asks user for permission to send Push Notifications
            _ = self.requestAuthorisationPushNotifications()
        }
    
        restoreSavedData()
        
        /// Initialises the user data to display to default values
        userDataDictionary.removeAll(keepingCapacity: true)
        setUserDataToDefaultValues()
        
        /// Every day at midnight, schedules reminders for the day
        NotificationCenter.default.addObserver(self, selector:#selector(calendarDayDidChange), name:.NSCalendarDayChanged, object:nil)

        /// When the user changes the iPhone time or date, re-schedules the reminders for the day
        NotificationCenter.default.addObserver(self, selector: #selector(timeChangedNotification), name: NSNotification.Name.NSSystemClockDidChange, object: nil)
        
        /// Will return false if the value is not stored
        hasAlreadyLaunched = defaults.bool(forKey: "hasAlreadyLaunched")
        
        setEncouragementsDefault()
        
        /// If 1st launch of the app, display Settings screen to allow user to schedule reminders
        if (!hasAlreadyLaunched) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
                self.firstLaunchCode()
            }
            /// Stores that the app has already launched
            UserDefaults.standard.set(true, forKey: "hasAlreadyLaunched")
        }
    }
    
    /// Shows Settings screen to allow the user to schedule reminders
    private func firstLaunchCode(){

        /// Schedules default reminders; User might change that in the next screen (Settings)
        defaults.set(true, forKey: "switch9To12")
        defaults.set(true, forKey: "switch16To20")

        scheduleAppropriateReminders(from: Date(), except:"")
    }
    
    /// Schedules reminders for the day for the time ranges switched ON in the Settings screen
    @objc private func calendarDayDidChange(){
        scheduleAppropriateReminders(from: Date(), except: "")
    }
    
    /// Method get called user changed the system time manually.
    /// Handles data back up and re-schedules today's Mood Reminders
    @objc private func timeChangedNotification(notification:NSNotification){
        
        /// Re-load backed up data
        userDataDictionary.removeAll(keepingCapacity: true)
        setUserDataToDefaultValues()
        
        /// Re-schedules Mood Reminders for the day
        scheduleAppropriateReminders(from: Date(), except: "")
        
        /// Triggers an update of the display of the home screen
        NotificationCenter.default.post (name: Notification.Name("updateSummaryDisplay"), object: [])
    }
    
    /// Restore backed up user data; Includes *userDataDictionary*, *encouragements*, *tipsList*, reminders switches.
    private func restoreSavedData(){
        
        /// Retrieves *userDataDictionary* saved
        if let userData = defaults.dictionary(forKey: "userDataDictionary") as? [String: [String : Any]] {
            userDataDictionary = userData
        }
        
        /// Retrieves *tipsList* saved and stores it in *copyTips*
        if let tipsList = defaults.array(forKey: "tipsList") as? [String] {
            copyTips = tipsList
        }
        else {
            copyTips = Constants.tips
            /// Randomly sorts the tips list
            copyTips.shuffle()
        }
        
        /// Retrieves *reminder9To12* saved
        if let switch9To12 = defaults.object(forKey: "switch9To12") as? Bool {
             reminder9To12 = switch9To12
        }
        
         /// Retrieves *reminder12To16* saved
        if let switch12To16 = defaults.object(forKey: "switch12To16") as? Bool {
            reminder12To16 = switch12To16
        }
        
         /// Retrieves *reminder16To20* saved
        if let switch16To20 = defaults.object(forKey: "switch16To20") as? Bool {
            reminder16To20 = switch16To20
        }
        
         /// Retrieves *reminder20To23* saved
        if let switch20To23 = defaults.object(forKey: "switch20To23") as? Bool {
            reminder20To23 = switch20To23
        }
        
        if let totalMoods = defaults.object(forKey: "totalMoodsLogged") as? Int {
            totalMoodsLogged = totalMoods
        }
    }
    
    /// Set *userDataDictionary* entries to defaults values; Avoids getting nil exceptions
    func setUserDataToDefaultValues () {
        
        /// Ensures that the *userDataDictionary* does not exceed the limit fixed; Limit = 30 entries;
        while userDataDictionary.count > limitEntry {
            userDataDictionary.remove(at: userDataDictionary.startIndex)
        }

        var endIndex = limitEntry - 1
        
        var date = Date()
        
        if (userDataDictionary.count > 6) { endIndex = userDataDictionary.count }
       
        /// For all entries in user data dictionary
        for _ in 0...endIndex {

            let dateString = formatDateToString(date: date)
            
            var dataOfSpecificDate = Dictionary<String, Any>()
            
            /// If entry exists for date
            if let dateString = userDataDictionary[dateString] {
    
                dataOfSpecificDate = dateString
                
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
            if let previousDate = Calendar.current.date(byAdding: .day, value: -1, to: date) {
               date = previousDate
            }
        }
        /// Initialises the *pastWeekBedtimes* to new list
        past3Bedtimes = [String]()
        
        /// Initialises the *past7DaysLogs* to new list
        past7DaysLogs = [Any]()
    }
    
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
        
        /// Initialises the encouragements that might be missing
        /// Consistency of bedtime
        if  (encouragements["bedBeforeMidnight3Row"] == nil) {
            encouragements["bedBeforeMidnight3Row"] = Encouragement(id: "bedBeforeMidnight3Row")
        }

        /// Consistency of mood self-report
        if (encouragements["moods3ThisWeek"] == nil) {
            encouragements["moods3ThisWeek"] = Encouragement(id: "moods3ThisWeek")
        }
        if (encouragements["moods7DaysThisWeek"] == nil) {
            encouragements["moods7DaysThisWeek"] = Encouragement(id: "moods7DaysThisWeek")
        }
        if (encouragements["moodsPast2Weeks"] == nil){
            encouragements["moodsPast2Weeks"] = Encouragement(id: "moodsPast2Weeks")
        }
        if (encouragements["moodsPast3Weeks"] == nil){
            encouragements["moodsPast3Weeks"] = Encouragement(id: "moodsPast3Weeks")
        }
        if (encouragements["moodsPast4Weeks"] == nil){
            encouragements["moodsPast4Weeks"] = Encouragement(id: "moodsPast4Weeks")
        }
        if (encouragements["moodsPast5Weeks"] == nil){
            encouragements["moodsPast5Weeks"] = Encouragement(id: "moodsPast5Weeks")
        }
        if (encouragements["moodsPast6Weeks"] == nil){
            encouragements["moodsPast6Weeks"] = Encouragement(id: "moodsPast6Weeks")
        }
        if (encouragements["moodsPast7Weeks"] == nil){
            encouragements["moodsPast7Weeks"] = Encouragement(id: "moodsPast7Weeks")
        }

        /// Total number of moods recorded
        if (encouragements["moods15"] == nil){
            encouragements["moods15"] = Encouragement(id: "moods15")
        }
        if (encouragements["moods30"] == nil){
            encouragements["moods30"] = Encouragement(id: "moods30")
        }
        if (encouragements["moods50"] == nil){
            encouragements["moods50"] = Encouragement(id: "moods50")
        }
        if (encouragements["moods70"] == nil){
            encouragements["moods70"] = Encouragement(id: "moods70")
        }
        if ( encouragements["moods100"] == nil){
            encouragements["moods100"] = Encouragement(id: "moods100")
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
 
    /// Gets and formats today's day
    /// - Returns: dayInLetters; Format "MON"
    private func getDayInLetters() -> String {
       
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE"
        let currentDay = dateFormatter.string(from: currentDate)
        
        /// Keeps only the first 3 letters
        let dayInLetters = String(currentDay.prefix(3))
        
        return dayInLetters.uppercased()
    }

    
    /// Reads HealthKit data; Includes bedtime, number of hours slept and steps count
    @objc private func readHealthData(){

        DispatchQueue.main.async {
            self.healthDataManager.getPastWeekSteps()
            self.healthDataManager.getPastWeekSleepAnalysis()
            
            NotificationCenter.default.post(name: NSNotification.Name("newHealthData"), object: [])
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
            
       /// Perform the task associated with the action on the Mood Reminder
       switch response.actionIdentifier {
       case "LATER":
          postponeNotification(oldDate: Date())
       case "NOT_TODAY":
          if let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) {
               scheduleAppropriateReminders(from: tomorrow, except: "")
          }
       default:
          break
       }
        
       /// Always call the completion handler when done.
       completionHandler()
    }
    
    /// Schedules mood reminder for the hour following *oldDate*, if the new time is still in available time range.
    private func postponeNotification(oldDate: Date){
        
        /// Retrieves the hours from *oldDate*
        let calendar = Calendar.current
        let oldHour = calendar.component(.hour, from: oldDate)
        
        /// Creates a new time range starting at *oldHour* + 1h and ending at *oldHour* + 2hrs
        let startInterval = oldHour + 1
        let endInterval = oldHour + 2
        
        /// If new time range falls into [9:00 - 12:00] and [9:00 - 12:00] is switched ON, schedules reminder
        if (startInterval >= 9 && startInterval < 12 && reminder9To12){
            scheduleReminder(startTimeRange: startInterval, endTimeRange: endInterval, dateFrom: Date())
        }
        /// If new time range falls into [12:00 - 16:00] and [12:00 - 16:00] is switched ON, schedules reminder
        else if (startInterval >= 12 && startInterval < 16 && reminder12To16){
            scheduleReminder(startTimeRange: startInterval, endTimeRange: endInterval, dateFrom: Date())
        }
        /// If new time range falls into [16:00 - 20:00] and [16:00 - 20:00] is switched ON, schedules reminder
        else if (startInterval >= 16 && startInterval < 20 && reminder16To20){
            scheduleReminder(startTimeRange: startInterval, endTimeRange: endInterval, dateFrom: Date())
        }
        /// If new time range falls into [20:00 - 23:00] and [20:00 - 23:00] is switched ON, schedules reminder
        else if (startInterval >= 20 && startInterval < 23 && reminder20To23){
             scheduleReminder(startTimeRange: startInterval, endTimeRange: endInterval, dateFrom: Date())
        }
    }
    
    /// Requests user permission to read HealthKit data
    private func requestAuthorisationHealthKit() -> Bool{
     
        var authorized = false
        
        /// If HealthKit is available on device, requires permission to read types stepCout and sleepAnalysis
        if (HKHealthStore.isHealthDataAvailable()){
            
            let typesToRead: Set<HKObjectType> = [
                HKObjectType.quantityType(forIdentifier: .stepCount)!,
                HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)!
            ]
            
            healthStore.requestAuthorization(toShare: nil, read: typesToRead) { (success, error) in
                print("\n HealthKit Authorization GRANTED [Extension Delegate]")
                authorized = true
               
               /// Observes calls to read HealthKit data
                NotificationCenter.default.addObserver(self, selector: #selector(self.readHealthData), name: NSNotification.Name(rawValue: "watchCheckForNewHealthData"), object: nil)
          
              /// Might as well get the data now anyway
               self.readHealthData()
            }
        }
        return authorized
    }
    
    /// Requests user permission to send PUSH Notifications
    func requestAuthorisationPushNotifications() -> Int {
        
        UNUserNotificationCenter.current().delegate = self
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
           granted, error in
    
            print("\n PUSH NOTIFICATIONS - Permission granted: \(granted)")

            if let error = error {
                print(error.localizedDescription)
            }
        }
        return 0
    }

    /// Restart any tasks that were paused (or not yet started) while the application was inactive.
    /// If the application was previously in the background, optionally refresh the user interface.
    func applicationDidBecomeActive() {

     /// Removes all observers
     NotificationCenter.default.removeObserver(self)
     
     /// Add observer for calls to read HealthKit data
      NotificationCenter.default.addObserver(self, selector: #selector(self.readHealthData), name: NSNotification.Name(rawValue: "watchCheckForNewHealthData"), object: nil)
    }

    /** Sent when the application is about to move from active to inactive state.
     This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, etc.
     */
    func applicationWillResignActive() {
        
     /// Observes calls to read HealthKit data
      NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "watchCheckForNewHealthData"), object: nil)
     
        defaults.set(userDataDictionary, forKey: "userDataDictionary")
        defaults.set(copyTips, forKey: "tipsList")
        
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

    /// Sent when the system needs to launch the application in the background to process tasks.
    /// Tasks arrive in a set, so loop through and process each one.
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Be sure to complete the background task once you’re done.
                backgroundTask.setTaskCompletedWithSnapshot(false)
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompletedWithSnapshot(false)
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompletedWithSnapshot(false)
            case let relevantShortcutTask as WKRelevantShortcutRefreshBackgroundTask:
                // Be sure to complete the relevant-shortcut task once you're done.
                relevantShortcutTask.setTaskCompletedWithSnapshot(false)
            case let intentDidRunTask as WKIntentDidRunRefreshBackgroundTask:
                // Be sure to complete the intent-did-run task once you're done.
                intentDidRunTask.setTaskCompletedWithSnapshot(false)
            default:
                // make sure to complete unhandled task types
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }
}

/// Schedules one Mood Reminder per time range switched ON by user
func scheduleAppropriateReminders(from: Date, except:String){
    
    let date = from
    /// Remove all pending reminders
    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    
    /// Retrieves *reminder9To12* saved
    if let _ = defaults.object(forKey: "switch9To12"){
        reminder9To12 = defaults.bool(forKey: "switch9To12")
    }

     /// Retrieves *reminder12To16* saved
    if let _ = defaults.object(forKey: "switch12To16"){
        reminder12To16 = defaults.bool(forKey: "switch12To16")
    }
    
     /// Retrieves *reminder16To20* saved
    if let _ = defaults.object(forKey: "switch16To20"){
        reminder16To20 = defaults.bool(forKey: "switch16To20")
    }
    
     /// Retrieves *reminder20To23* saved
    if let _ = defaults.object(forKey: "switch20To23"){
        reminder20To23 = defaults.bool(forKey: "switch20To23")
    }
    
    /// Schedules a Mood Reminder between 9:00 and 12:00 [not included]
    if reminder9To12 && (except != "switch9To12"){
        scheduleReminder(startTimeRange: 9, endTimeRange: 12, dateFrom: date)
    }
    /// Schedules a Mood Reminder between 12:00 and 16:00 [not included]
    if reminder12To16 && (except != "switch12To16"){
        scheduleReminder(startTimeRange: 12, endTimeRange: 16, dateFrom: date)
    }
    /// Schedules a Mood Reminder between 16:00 and 20:00 [not included]
    if reminder16To20 && (except != "switch16To20"){
        scheduleReminder(startTimeRange: 16, endTimeRange: 20, dateFrom: date)
    }
    /// Schedules a Mood Reminder between 20:00 and 23:00 [included]
    if reminder20To23 && (except != "switch20To23"){
        scheduleReminder(startTimeRange: 20, endTimeRange: 23, dateFrom: date)
    }
}

/// Schedules a Mood Reminder within the time range in parameter
/// Parameters:
///     - startTimeRange: start hour of the time range
///     - endTimeRange: end hour of the time range
func scheduleReminder(startTimeRange: Int, endTimeRange: Int, dateFrom: Date){
    
    /// Generates a random time (HH:MM) between *startTimeRange* and *endTimeRange*
    let reminderHour = Int.random(in: startTimeRange..<endTimeRange)
    let reminderMin = Int.random(in: 0..<60)
    
    /// If Push Notifications allowed, schedules the Mood Reminder
    let centre = UNUserNotificationCenter.current()
    centre.getNotificationSettings { (settings) in
        
        if settings.authorizationStatus != UNAuthorizationStatus.authorized {
            print("Sending Notifications NOT Authorised")
        }
        else {
            /// Initialises Mood Reminder's content
            let content = UNMutableNotificationContent()
            content.title = NSString.localizedUserNotificationString(forKey: "MM", arguments: nil)
            content.body = NSString.localizedUserNotificationString(forKey: "I'm feeling...", arguments: nil)
            content.categoryIdentifier = "MOOD_REMINDER"
            content.sound = UNNotificationSound.default
            
            /// Sets Mood Reminder's time
            let userCalendar = Calendar.current
            var date = userCalendar.dateComponents([.hour, .minute], from: dateFrom)
 
            date.hour = reminderHour
            date.minute = reminderMin
        
            /// The reminder will repeat. If 1) the user answer the reminder or 2) a *calendarDayDidChange* event is observed,
            /// all pending reminders will re-schedule at a random time within the appropriate time ranges.
            let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
            
            /// Creates the scheduling request for the Mood Reminder
          let today = getTodaysDate(date: Date())
            let id = "\(today)\(startTimeRange)To\(endTimeRange)"
            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
            
            let center = UNUserNotificationCenter.current()
            
            /// Sets custom actions in Mood Reminder
            /// Ask Later: dismisses reminder and schedules one in the coming hour
            let notNow = UNNotificationAction.init(identifier: "LATER", title: "Ask Later", options: UNNotificationActionOptions())
            
            /// Mute for Today: dismisses reminder and cancel all reminders scheduled today
            let notToday = UNNotificationAction.init(identifier: "NOT_TODAY", title: "Mute for Today", options: UNNotificationActionOptions())
                
            /// Adds the custom actions to the Mood Reminder category
            let categories = UNNotificationCategory.init(identifier: "MOOD_REMINDER", actions: [notNow, notToday], intentIdentifiers: [], options: [])
            centre.setNotificationCategories([categories])
            
            /// Schedules the Mood Reminder
            center.add(request, withCompletionHandler: nil)
        }
    }
}

/// Determines the image associated with the *mood* in parameter
/// Parameter: mood; Integer ranging from 1 to 5
/// Returns: image associated with mood
func moodImageFromInt(mood: Int) -> UIImage{
    var image = UIImage()
    switch mood {
    case 1...5:
          if let moodImage = UIImage.init(named: "mood-" + "\(mood)") {
               image = moodImage
          }
     default:
          if let dash = UIImage.init(named: "dash") {
               image = dash
          }
    }
    return image
}

/// Determines background image for *inBedIcon*
/// Parameter: dateString is the date of the data
/// Returns: image for the *inBedIcon*
func getInBedIcon(dateString: String) -> UIImage? {
    
     /// If the number of hours slept for the date is unknown
     /// icon is a full moon (neutral visualisation)
     var icon = UIImage(named: "moon-4")
     
     /// Checks if the number of hours slept for date is known
     if let userDataForDate = userDataDictionary[dateString], let timeInBedString = userDataForDate["inBed"] as? String, timeInBedString != "-" {
          
               /// Retrieves hours value from *timeInBedString*; Format (hh:mm)
               let index = timeInBedString.index(timeInBedString.startIndex, offsetBy:0)..<timeInBedString.index(timeInBedString.endIndex, offsetBy: -3)
          
               if let hoursInBed = Int(timeInBedString[index]) {
                   /// Over 8hrs slept is associated with the image of a full moon
                   if hoursInBed >= 8 {
                       icon = UIImage(named: "moon-4")
                   }
                   /// Between 6 and 8 hrs slept is associated with the image of an almost full moon
                   else if hoursInBed >= 6 {
                       icon = UIImage(named: "moon-3")
                   }
                   /// Between 4 and 6 hrs slept is associated with the image of a partially full moon
                   else if hoursInBed >= 4 {
                       icon = UIImage(named: "moon-2")
                   }
                   /// Under 4 slept is associated with the image of an almost empty moon
                   else {
                       icon = UIImage(named: "moon-1")
                   }
           }
     }
     return icon
}

/// Determines background image for *exerciseIcon*
/// Parameter: dateString is the date of the data
/// Returns: image for the *exerciseIcon*
func getExerciseIcon(dateString: String) -> UIImage? {
     /// If the steps count for the date is unknown, icon is a person walking (neutral visualisation)
     var icon = UIImage(named: "walking")
    
     if let userDataForDate = userDataDictionary[dateString], let stepsString = userDataForDate["steps"] as? String, stepsString != "-", let steps = Int(stepsString) {
                    
          /// A high steps count is associated with the image of a running person
          if steps >= 8000 {
               icon = UIImage(named: "running")
          }
          /// A medium steps count is associated with the image of a fast-walking person
          else if steps >= 3000 {
               icon = UIImage(named: "fast-walking")
          }
          /// A low steps count is associated with the image of a walking person
          else{
               icon = UIImage(named: "walking")
          }
     }
     return icon
}

/// Returns today's date; Format "yyyy-MM-dd"
func getTodaysDate (date:Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: date)
}

/// Formats the *date* in parameter as "yyyy-MM-dd"
func formatDateToString(date: Date) -> String{
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: date)
}

extension TimeInterval {
    
    /// Formats a time interval into the units in parameter
    func format(using units: NSCalendar.Unit) -> String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = units
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        
        return formatter.string(from: self)
    }
}

extension Date {
    
    /// Returns the day of the week; Format "MON"
    func dayOfWeek() -> String? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE"
        return dateFormatter.string(from: self).uppercased()
    }
}

extension String {
    
    /// Removes all non-digits from a String
    var digits: String {
        
        return components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()
    }
    
    func toDate(format: String) -> Date {
           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = format
           guard let date = dateFormatter.date(from: self) else {
               preconditionFailure("\nERROR - Wrong format for date")
           }
           return date
       }
}
