/**
  TipInterfaceController.swift
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

 
 This class defines the Tips to Stay Well screen.
*/

import WatchKit
import Foundation


class TipInterfaceController: WKInterfaceController {

    /// Label with the text of the tip
    @IBOutlet weak var tipTextLabel: WKInterfaceLabel!

    /// Animated button to go through the tips
    @IBOutlet weak var tipButton: WKInterfaceButton!
    
    /// Image used to animate the button
    @IBOutlet weak var animatedImage: WKInterfaceImage!
    
    /// Timer used for the button animation
    var timer = Timer()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        /// Initialises the "new tip" animation of the button (plant growing)
        animatedImage.setImageNamed("plant")
        animatedImage.startAnimatingWithImages(in: NSRange(location: 0, length: 4), duration: 1.5, repeatCount: 1)
        
        /// Displays new tip
        showNewTip()
        
        /// Initialises the button animation to encourage user to tap (plant pulsing)
        /// Repeating every 2.5 seconds
        timer = Timer.scheduledTimer(timeInterval: 2.5, target: self, selector: #selector(animateImage), userInfo: nil, repeats: true)
    }

    /// Button is tapped: diplays following tip and manages button behaviour
    @IBAction func pressTipButton() {
        timer.invalidate()
        
        /// Disables button for 1.5 seconds: Ensures that the user reads the tip before moving on to next one
        tipButton.setEnabled(false)
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { _ in
            self.tipButton.setEnabled(true)
        })
        
        /// Animates the button to present the new tip (plant growing)
        animatedImage.setImageNamed("plant")
        animatedImage.startAnimatingWithImages(in: NSRange(location: 0, length: 4), duration: 1.5, repeatCount: 1)
        
        /// Display the text of the next tip in *tipTextLabel*
        showNewTip()

        /// Initialises the button animation to encourage user to tap (plant pulsing)
        /// Repeating every 2.5 seconds
        timer = Timer.scheduledTimer(timeInterval: 2.5, target: self, selector: #selector(animateImage), userInfo: nil, repeats: true)
    }
    
    /// Animates the button image to present new tip (plant growing)
    @objc func animateImage(){
        animatedImage.setImageNamed("action-plant")
        animatedImage.startAnimatingWithImages(in: NSRange(location: 0, length: 6), duration: 0.5, repeatCount: 1)
    }
     
    /// Displays the text of the new tip
    private func showNewTip(){
        
        /// Disables button until new tip is displayed
        tipButton.setEnabled(false)
        
        /// Hides the current tip text to transition to the next one
        self.tipTextLabel.setAlpha(0.0)
        
        /// Diplays 1st entry in *Constants.tips*
        if (copyTips.count > 0) {
            tipTextLabel.setText(copyTips.first)
        }
        /// If first time accessing the Tips, copy the *Constants.tips* and display 1st one
        else {
            copyTips = Constants.tips
            tipTextLabel.setText(copyTips.first)
        }
        
        /// Removes tip displayed from the *copyTips*
        copyTips.removeFirst()
        
        /// Animates the display of new tip
        DispatchQueue.main.async {
            self.animate(withDuration: 1.5, animations: {
                self.tipTextLabel.setAlpha(1.0)
            })
            /// Re-enables the tip button
            self.tipButton.setEnabled(true)
        }
    }
    
    /// This method is called when watch view controller is about to be visible to user
    override func willActivate() {
        super.willActivate()
    }

    /// This method is called when watch view controller is no longer visible
    override func didDeactivate() {
        super.didDeactivate()
        timer.invalidate()
    }

}
