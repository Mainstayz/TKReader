//
//  TKBookCollectionViewCell.swift
//  Tricky
//
//  Created by Pillar on 2017/6/24.
//  Copyright © 2017年 unkown. All rights reserved.
//

import UIKit

class TKBookCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var titleLab: UILabel!
    
    func configure(model : TKNovelModel){
        
        self.imgView.sd_setImage(with: URL(string: model.img!))
        let readingRerord = TKReadingRecordManager.sharedInstance.readingRecord(key: model.title!)
        let progress = Float(readingRerord.0) / Float(model.chapters.count)
        
        self.progressView.progress = progress
        self.titleLab.text = model.title
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
