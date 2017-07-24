//
//  TKBookCollectionViewCell.swift
//  Tricky
//
//  Created by Pillar on 2017/6/24.
//  Copyright © 2017年 unkown. All rights reserved.
//

import UIKit
import FontAwesomeKit
class TKBookCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var titleLab: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    var inEditState = false
    func configure(model : TKNovelModel){
        
        self.imgView.sd_setImage(with: URL(string: model.img!))
        let readingRerord = TKReadingRecordManager.default.readingRecord(key: model.title!)
        let progress = Float(readingRerord.0) / Float(model.chapters.count)
        
        self.progressView.progress = progress
        self.titleLab.text = model.title
    }
    func setInEditState(edit:Bool) -> Void {
        self.inEditState = edit
        self.closeButton.isHidden = !edit
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let closeIcon = FAKFontAwesome.closeIcon(withSize: 24)
        closeIcon?.addAttribute(NSForegroundColorAttributeName, value: UIColor.flatRed)
        self.closeButton.setAttributedTitle(closeIcon?.attributedString(), for: .normal)
        self.closeButton.isHidden = self.inEditState
        
    }

}
