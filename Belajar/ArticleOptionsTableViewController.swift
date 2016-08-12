//
//  ArticleOptionsTableTableViewController.swift
//  Belajar
//
//  Created by Jim Cramer on 09/08/2016.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import UIKit

protocol ArticleOptionsDelegate: class {
    var speakOnTapIsOn: Bool {get set }
}

class ArticleOptionsTableViewController: UITableViewController {
    
    weak var delegate: ArticleOptionsDelegate?
    
    @IBOutlet weak var speechSwitch: UISwitch! {
        didSet {
            if delegate != nil {
                speechSwitch.isOn = delegate!.speakOnTapIsOn
            }
        }
    }

    @IBOutlet weak var speechRateSlider: UISlider! {
        didSet {
            speechRateSlider.value = SpeechService.sharedInstance.speechRate
        }
    }
    
    @IBAction func speechSwitchValueChanged(_ sender: UISwitch) {
        delegate?.speakOnTapIsOn = sender.isOn
    }
    
    @IBAction func speechRateChanged(_ sender: UISlider) {
        SpeechService.sharedInstance.speechRate = sender.value
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
