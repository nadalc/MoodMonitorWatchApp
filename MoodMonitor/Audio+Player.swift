//
//  Audio+Player.swift
//  SilverCloud
//
//  Created by Maria Ortega on 24/06/2020.
//  Copyright © 2020 James. All rights reserved.
//

import UIKit
import AVKit

extension AVPlayerViewController {
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.player?.pause()
        defaults.set(true, forKey: kPlayerWasDismissed)
    }
}

