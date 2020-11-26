/**
  Constants.swift
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

 
 This class defines the global constants of the watchkit app.
*/

import Foundation
import WatchKit

/// Defines the global constants of the watch app
struct Constants{
    /// List of factors that may influence the mood
    static let factors = ["Sleep", "Exercise", "Diet", "Coffee", "Alcohol", "Medication"]

    /// Colour of an *unselected* row in the table of factors; Dark gray
    static let defaultColor = UIColor(red: 31/255, green: 31/255, blue: 32/255, alpha: 1)

    /// Colour of a *selected* row in the table of factors; White
    static let highlightColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
   
    /// List of Tips to Stay Well
    /// extracted from the Space from Depression program
    static let tips = [
        "Tip 1: Some helpful content here",
        "Tip 2: Some helpful content here",
        "Tip 3: Some helpful content here",
        "Tip 4: Some helpful content here",
        "Tip 5: Some helpful content here",
        "Tip 6: Some helpful content here",
        "Tip 7: Some helpful content here",
        "Tip 8: Some helpful content here",
        "Tip 9: Some helpful content here",
        "Tip 10: Some helpful content here"
    ]
}

