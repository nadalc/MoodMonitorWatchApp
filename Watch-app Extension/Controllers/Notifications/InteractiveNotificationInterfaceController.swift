/**
  InteractiveNotificationInterfaceController.swift
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

 
 This class defines the Interactive Notification allowing the user to self-report their current mood
*/

import WatchKit
import Foundation
import UserNotifications
import UIKit

@available(watchOSApplicationExtension 5.0, *)
class InteractiveNotificationInterfaceController: WKUserNotificationInterfaceController, URLSessionDelegate {
    
    /// Initialize variables here.
    override init() {
        
        super.init()
        /// Configure interface objects here.
    }
    
    /** This method is called when a notification needs to be presented.
     Implement it if you use a dynamic notification interface.
     Populate your dynamic notification interface as quickly as possible.
     After populating your dynamic notification interface call the completion block.
     */
    override func didReceive(_ notification: UNNotification, withCompletion completionHandler: @escaping (WKUserNotificationInterfaceType) -> Swift.Void) {
        
        /// Sets interface title to something short and stigma-free
        self.setTitle("MM")
    
        completionHandler(.custom)
    }

    /// User selects Sun: stores mood and opens the app
    @IBAction func sunPicked() {
        self.storeMoodLog(mood: 5)
        rescheduleReminders()
        performNotificationDefaultAction()
    }
    
    /// User selects Sun-Cloud: stores mood and opens the app
    @IBAction func sunCloudPicked() {
        self.storeMoodLog(mood: 4)
        rescheduleReminders()
        performNotificationDefaultAction()
    }
    
    /// User selects Cloud: stores mood and opens the app
    @IBAction func cloudPicked() {
        self.storeMoodLog(mood: 3)
        rescheduleReminders()
        performNotificationDefaultAction()
    }
    
    /// User selects Cloud-Rain: stores mood and opens the app
    @IBAction func rainCloudPicked() {
        self.storeMoodLog(mood: 2)
        rescheduleReminders()
        performNotificationDefaultAction()
    }
    
    /// User selects Rain: stores mood and opens the app
    @IBAction func rainPicked() {
        self.storeMoodLog(mood: 1)
        rescheduleReminders()
        performNotificationDefaultAction()
    }
    
    /// Stores *mood* selected in the *userDataDictionary* to today's date
    /// - Parameter:
    ///      mood: Mood selected by user
    private func storeMoodLog(mood: Int){
        
        /// Increases the *totalMoodsLogged*
        totalMoodsLogged += 1
        defaults.set(totalMoodsLogged, forKey: "totalMoodsLogged")
        
        /// Retrieves today's data in *userDataDictionary*
     let today = getTodaysDate(date: Date())
        var todaysData = [String:Any]()
        
        /// If data already stored for today's date, retrieves it
        if let today = userDataDictionary[today] {
            todaysData = today
        }
        
        /// Stores the time of the mood in *userDataDictionary*
        let hour = Calendar.current.component(.hour, from: Date())
        let minute = Calendar.current.component(.minute, from: Date())
        let time = "\(hour):\(minute)"

          /// Replace any mood entry for this date with new mood
        todaysData.updateValue([mood], forKey: "moods")
        todaysData.updateValue(listOfFactors, forKey: "factors")
        todaysData.updateValue(time, forKey: "time")
    
        userDataDictionary.updateValue(todaysData, forKey: today)
    
        let factors = listOfFactors
        let datetime = "\(today) \(time)"
        
        sendMoodToDatabase(mood: mood, factors: factors, datetime: datetime)
        
        /// Triggers an update of the display of the home screen
        NotificationCenter.default.post (name: Notification.Name("updateSummaryDisplay"), object: [])
    }
            
    private func sendMoodToDatabase(mood: Int, factors: [String], datetime: String){
        
          DispatchQueue.main.async {
               
                /// Initialises the dictionary to build JSON from
                var dict = Dictionary<String,Any>()
                 
                /// Sets the devide unique identifier in *dict*
                dict["mood"] = mood
                dict["factors"] = factors
                dict["datetime"] = datetime
                 
                /// Creates and sends a JSON file containing the data
                let jsonData: NSData
                do{
                    jsonData = try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions()) as NSData
                    if let jsonString = NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue) {
                         let url = "" // REPLACE WITH YOUR ENPOINT HERE
                         self.sendAndRetrieveMoodsJSONAPI(jsonData: jsonString as String, endpoint: url)
                    }
                }
                catch _ {}
            }
    }
    
    /// Sends a JSON containing the moods logged through the Watch to the client's account
    /// Retrieve the moods already in client's account and sends them to the Watch for display
    func sendAndRetrieveMoodsJSONAPI(jsonData: String, endpoint: String){
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
    
    /// This method is called when watch view controller is about to be visible to user
    override func willActivate() {
        super.willActivate()
    }
    
    /// This method is called when watch view controller is no longer visible
    override func didDeactivate() {
        
        super.didDeactivate()
    }
}

private func rescheduleReminders () {
    var except = ""
    let currentTime = Calendar.current.component(.hour, from: Date())
    
    /// We won't re-schedule the reminder in current timeframe as the user just answered it
    if currentTime >= 9 && currentTime < 12 {
        except = "switch9To12"
    }
    else if currentTime >= 12 && currentTime < 16 {
        except = "switch12To16"
    }
    else if currentTime >= 16 && currentTime < 20 {
        except = "switch16To20"
    }
    else if currentTime >= 20 && currentTime < 23 {
        except = "switch20To23"
    }
    
    /// Reschedule the reminders to random times
    scheduleAppropriateReminders(from: Date(), except: except)
}
