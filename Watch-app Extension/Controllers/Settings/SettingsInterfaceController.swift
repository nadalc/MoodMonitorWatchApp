/**
  SettingsInterfaceController.swift
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
 
 This class defines the Settings screen of the app, allowing the user to schedule reminders.
*/

import WatchKit
import Foundation
import UserNotifications

class SettingsInterfaceController: WKInterfaceController {
    
    /// Switch for the reminder time range 9:00 - 12:00
    @IBOutlet weak var switch9To12: WKInterfaceSwitch!
    
    /// Switch for the reminder time range 12:00 - 16:00
    @IBOutlet weak var switch12To16: WKInterfaceSwitch!
    
    /// Switch for the reminder time range 16:00 - 20:00
    @IBOutlet weak var switch16To20: WKInterfaceSwitch!
    
    /// Switch for the reminder time range 20:00 - 23:00
    @IBOutlet weak var switch20To23: WKInterfaceSwitch!

    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        /// Initialises the switches to the state the user has set them
        if let switch9To12Value = defaults.object(forKey: "switch9To12") as? Bool {
          switch9To12.setOn(switch9To12Value)
        }
        if let switch12To16Value = defaults.object(forKey: "switch12To16") as?  Bool {
          switch12To16.setOn(switch12To16Value)
        }
        if let switch16To20Value = defaults.object(forKey: "switch16To20") as? Bool{
          switch16To20.setOn(switch16To20Value)
        }
        if let switch20To23Value = defaults.object(forKey: "switch20To23") as? Bool {
          switch20To23.setOn(switch20To23Value)
        }
    }
    
    /// Switch 9:00 - 12:00 tapped: if ON, schedules reminder; stores switch value
    @IBAction func switch9To12Updated(_ value: Bool) {
        defaults.set(value, forKey: "switch9To12")
        if value {
            scheduleReminder(startTimeRange: 9, endTimeRange: 12, dateFrom: Date())
        }
    }
    
    /// Switch 12:00 - 16:00 tapped: if ON, schedules reminder; stores switch value
    @IBAction func switch12To16Updated(_ value: Bool) {
        defaults.set(value, forKey: "switch12To16")
        if value {
            scheduleReminder(startTimeRange: 12, endTimeRange: 16, dateFrom: Date())
        }
    }
    
    /// Switch 16:00 - 20:00 tapped: if ON, schedules reminder; stores switch value
    @IBAction func switch16To20Updated(_ value: Bool) {
        defaults.set(value, forKey: "switch16To20")
         if value {
            scheduleReminder(startTimeRange: 16, endTimeRange: 20, dateFrom: Date())
        }
    }
    
    /// Switch 20:00 - 23:00 tapped: if ON, schedules reminder; stores switch value
    @IBAction func switch20To23Updated(_ value: Bool) {
        defaults.set(value, forKey: "switch20To23")
         if value {
            scheduleReminder(startTimeRange: 20, endTimeRange: 23, dateFrom: Date())
        }
    }
    
    /// This method is called when watch view controller is about to be visible to use
    override func willActivate() {
        super.willActivate()
    }

    /// This method is called when watch view controller is no longer visible
    override func didDeactivate() {
        super.didDeactivate()
        popToRootController()
    }
}

