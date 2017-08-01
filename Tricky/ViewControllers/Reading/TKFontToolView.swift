//
//  TKFontToolView.swift
//  Tricky
//
//  Created by Pillar on 2017/8/1.
//  Copyright © 2017年 unkown. All rights reserved.
//

import UIKit
import StepSlider

class TKFontToolView: UIView {

    var delegate: TKToolsProtocol?
    
    @IBOutlet weak var slider: StepSlider!
    
    @IBAction func changeValue(_ sender: StepSlider){
       delegate?.fontSizeDidChange!(Int(sender.index))
    }
}
