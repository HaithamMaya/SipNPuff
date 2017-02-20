//
//  Threshold.swift
//  SipNPuff
//
//  Created by Haitham Maaieh on 12/5/15.
//  Copyright © 2015 haithammaaieh. All rights reserved.
//

import Foundation
import UIKit

class ThresholdViewController: UIViewController {
    let screenSize = UIScreen.mainScreen().bounds
    let puffThreshold = UISlider()
    let sipThreshold = UISlider()
    let playButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func playGame() {
        switchToViewController("viewController")
    }
    func switchToViewController(identifier: String) {
        let viewController = (self.storyboard?.instantiateViewControllerWithIdentifier(identifier))! as UIViewController
        self.navigationController?.setViewControllers([viewController], animated: false)
        
    }
}