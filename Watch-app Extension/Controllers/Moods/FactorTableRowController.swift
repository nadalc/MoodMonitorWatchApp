/**
  FactorTableRowController.swift
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

 
 This class defines a row in the Factors table.
*/

import WatchKit

class FactorTableRowController: NSObject {
    
    /// Factor label; Format "Sleep"
    @IBOutlet var label: WKInterfaceLabel!
    
    /// Group: includes the label behaves like a button
    @IBOutlet var group: WKInterfaceGroup!
    
    @IBOutlet weak var icon: WKInterfaceImage!
    
    var title: String = ""
    
    /// Declares a variable to store the status of the row (selected or not)
    var isSelected: Bool?
    
    /// Row selected: updates its display and stores factor in *listOfFactors*
    func select (){
        updateView(backgroundColor: Constants.highlightColor, textColor: UIColor.black)
        listOfFactors.append(title.lowercased())
    }
    
     /// Row unselected: updates its display and delete factor from *listOfFactors*
    func unselect (){
        updateView(backgroundColor: Constants.defaultColor, textColor: UIColor.white)
        
        if let index = listOfFactors.firstIndex(of: "\(title.lowercased())") {
            listOfFactors.remove(at: index)
        }
    }
    
    /// Updates the display of the group and label with the *backgroundColor* and *textColor* in parameter
    func updateView(backgroundColor:UIColor, textColor:UIColor){
        group.setBackgroundColor(backgroundColor)
        label.setTextColor(textColor)
    }
}

