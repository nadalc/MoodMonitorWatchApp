//
//  EncouragementInterfaceController.swift
//  Watch-app Extension
//
//  Created by cnadal on 14/09/2020.
//  Copyright © 2020 tcd. All rights reserved.
//

import WatchKit
import Foundation


class EncouragementInterfaceController: WKInterfaceController {

    @IBOutlet weak var heading: WKInterfaceLabel!
    
    @IBOutlet weak var image: WKInterfaceImage!
    
    @IBOutlet weak var praise: WKInterfaceLabel!
    
    @IBOutlet weak var reason: WKInterfaceLabel!
    
    @IBOutlet weak var text: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        let promptType = context as! String
        
        /// Default values
        var myHeading = ""
        var myImage = "award"
        var myPraise = "Keep it up!"
        var myDescription = ""
        var myText = "Log your mood often to build an accurate picture of how you are feeling."
        
        switch (promptType) {
            case "bedBeforeMidnight3Row":
                myHeading = "3-day Streak!"
                myImage = "bed-moon"
                myPraise = "Well done!"
                myDescription = "Bed before midnight each day"
                myText = "Mainting a sleep routine by sleeping and waking at a regular time each day."
            break
            
            case "moods3ThisWeek":
                myHeading = "3-log Streak!"
                myImage = "award"
                myPraise = "Way to go!"
                myDescription = "3 moods logged this week"
            break
            
            case "moods7DaysThisWeek":
               myHeading = "7-log Streak!"
               myImage = "award"
               myPraise = "Well done!"
               myDescription = "Moods logged each day of the week"
            break
            
            case "moodsPast2Weeks":
               myHeading = "2-week Streak!"
               myImage = "award"
               myPraise = "Keep it up!"
               myDescription = "Moods logged in the past 2 weeks"
            break
            
            case "moodsPast3Weeks":
                myHeading = "3-week Streak!"
                myImage = "award"
                myPraise = "Well done!"
                myDescription = "Moods logged in the past 3 weeks"
            break
            
            case "moodsPast4Weeks":
                myHeading = "4-week Streak!"
                myImage = "award"
                myPraise = "Well done!"
                myDescription = "Moods logged in the past 4 weeks"
            break
            
            case "moodsPast5Weeks":
                myHeading = "5-week Streak!"
                myImage = "award"
                myPraise = "Excellent!"
                myDescription = "Moods logged in the past 5 weeks"
            break
            
            case "moodsPast6Weeks":
                myHeading = "6-week Streak!"
                myImage = "award"
                myPraise = "Congratulations!"
                myDescription = "Moods logged in the past 6 weeks"
            break
            
            case "moodsPast7Weeks":
                myHeading = "7-week Streak!"
                myImage = "award"
                myPraise = "Brilliant!"
                myDescription = "Moods logged in the past 7 weeks"
            break
            
            case "moods15":
                myHeading = "15 moods!"
                myImage = "moods15"
                myPraise = "Keep it up!"
                myDescription = "15 moods logged"
            break
            
            case "moods30":
                myHeading = "30 moods!"
                myImage = "moods30"
                myPraise = "Way to go!"
                myDescription = "30 moods logged"
            break
            
            case "moods50":
                myHeading = "50 moods!"
                myImage = "moods50"
                myPraise = "Well done!"
                myDescription = "50 moods logged"
            break
            
            case "moods70":
                myHeading = "70 moods!"
                myImage = "moods70"
                myPraise = "Excellent!"
                myDescription = "70 moods logged"
            break
            
            case "moods100":
                myHeading = "100 moods!"
                myImage = "moods100"
                myPraise = "Congratulations!"
                myDescription = "100 moods logged"
            break
            
            default: print("")
        }
        /// Update interface elements
        heading.setText(myHeading)
        image.setImageNamed(myImage)
        praise.setText(myPraise)
        reason.setText(myDescription)
        text.setText(myText)
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
