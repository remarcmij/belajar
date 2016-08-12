//
//  SpeechRatePopoverViewController.swift
//  Belajar
//
//  Created by Jim Cramer on 12/08/2016.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import UIKit

class SpeechRatePopoverViewController: UIViewController {

    @IBOutlet weak var speechRateSlider: UISlider!
    
    @IBAction func speechRateSliderValueChanged(_ sender: UISlider) {
        SpeechService.sharedInstance.speechRate = sender.value
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        speechRateSlider.minimumValue = SpeechService.minimumValue
        speechRateSlider.maximumValue = SpeechService.maximumValue
        speechRateSlider.value = SpeechService.sharedInstance.speechRate
    }
}
