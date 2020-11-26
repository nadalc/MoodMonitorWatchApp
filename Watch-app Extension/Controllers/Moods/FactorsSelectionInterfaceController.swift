/**
  MoodPickedInterfaceController.swift
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

 This class defines the Factors Selection screen
*/

import WatchKit
import Foundation


class FactorsSelectionInterfaceController: WKInterfaceController, URLSessionDelegate {
    
    /// Variable storing the mood selected in previous screen
    private var moodSelected = Int()
    
    /// Variable storing if the OK button has been clicked
    var isOkClicked = false
    
    /// Variable storing the context received from previous screen (mood selected)
    var myContext = [Any]()
    
    /// Image representing the mood selected on previous screen
    @IBOutlet weak var moodIcon: WKInterfaceImage!
    
    /// Tappable table presenting the factors which might have influenced the mood
    @IBOutlet weak var tableOfFactors: WKInterfaceTable!
    
    override func awake(withContext context: Any?) {
          super.awake(withContext: context)
        
          /// Initialises the *moodSelected* to the value passed in Context
          if let context = context as? Int {
               moodSelected = context
          }
        
          /// Sets the *moodIcon* to the image representing the *moodSelected*
          moodIcon.setImageNamed("mood-\(moodSelected)")

          /// Creates the rows in *tableOfFactors*
          populateTableWithFactors()
    }
    
    /// For each factor of constant *factors*, creates a row in *tableOfFactors*
    private func populateTableWithFactors() {
        
        /// Sets number of rows to the number of factors in the constant array *factors*
        tableOfFactors.setNumberOfRows(Constants.factors.count, withRowType: "FactorTableRowController")
        
        /// For each factor, creates a row in *tableOfFactors*
        for (index, factor) in Constants.factors.enumerated() {
            
            let row = tableOfFactors.rowController(at: index) as! FactorTableRowController
            
            /// Initialises the text (factor)
            row.label.setText(factor)
            row.title = factor
            
            /// Initialises the icon
            row.icon.setImageNamed(factor.lowercased())
            
            /// Initialises the row status to unselected
            row.isSelected = false
        }
    }
    
    /// Changes display of the row when tapped and manages the addition/removal of the factor to the *listOfFactors*
    override func table(_:WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        
        let row = tableOfFactors.rowController(at: rowIndex) as! FactorTableRowController
        
        /// Row is now selected
        if row.isSelected == false {
            row.select()
            row.isSelected = true
        }
            
        /// Row is now unselected
        else {
            row.unselect()
            row.isSelected = false
        }
    }
    
    /// OK button pressed: returns to Home screen
    @IBAction func okBtnPressed() {
        isOkClicked = true
        popToRootController()
    }
    
    /// This method is called when watch view controller is about to be visible to user
    override func willActivate() {
        super.willActivate()
    }
    
    /// This method is called when watch view controller is no longer visible
    override func didDeactivate() {
        
        /// Back button is pressed: empties *listOfFactors*
        if !isOkClicked {
            listOfFactors = [String]()
        }
        else {
            /// Increases the *totalMoodsLogged*
            totalMoodsLogged += 1
            defaults.set(totalMoodsLogged, forKey: "totalMoodsLogged")
            
            /// Stores the mood selected in *userDataDictionary*
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
            todaysData.updateValue([moodSelected], forKey: "moods")
            todaysData.updateValue(listOfFactors, forKey: "factors")
            todaysData.updateValue(time, forKey: "time")
        
            userDataDictionary.updateValue(todaysData, forKey: today)
        
            let factors = listOfFactors
            let datetime = "\(today) \(time)"
            
            sendMoodToSC(mood: moodSelected, factors: factors, datetime: datetime)
            
            /// Triggers an update of the display of the home screen
            NotificationCenter.default.post (name: Notification.Name("updateSummaryDisplay"), object: [])
        }
        super.didDeactivate()
    }
    
     private func sendMoodToSC(mood: Int, factors: [String], datetime: String){
        
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
}


