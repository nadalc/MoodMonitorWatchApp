/**
  MoodSelectorInterfaceController.swift
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

 
 This class defines the Mood Selection screen.
*/

import WatchKit
import Foundation


class MoodSelectorInterfaceController: WKInterfaceController {
    
    /// Mood selected by the user; Format "sun-cloud"
    private var moodSelected = Int()

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }
    
    /// Sun selected: open the Factor Selection screen and pass "sun" in parameter
    @IBAction func sunPressed() {
        moodSelected = 5
        pushController(withName: "FactorsSelectionInterfaceController", context: moodSelected)
    }
    
    /// Sun-Cloud selected: open the Factor Selection screen and pass "sun-cloud" in parameter
    @IBAction func sunCloudPressed() {
        moodSelected = 4
        pushController(withName: "FactorsSelectionInterfaceController", context: moodSelected)
    }
    
    /// Cloud selected: open the Factor Selection screen and pass "cloud" in parameter
    @IBAction func cloudPressed() {
        moodSelected = 3
        pushController(withName: "FactorsSelectionInterfaceController", context: moodSelected)
    }
    
    /// Cloud-Rain selected: open the Factor Selection screen and pass "cloud-rain" in parameter
    @IBAction func multipleCloudsPressed() {
        moodSelected = 2
        pushController(withName: "FactorsSelectionInterfaceController", context: moodSelected)
    }
    
    /// Rain selected: open the Factor Selection screen and pass "rain" in parameter
    @IBAction func rainPressed() {
        moodSelected = 1
        pushController(withName: "FactorsSelectionInterfaceController", context: moodSelected)
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
