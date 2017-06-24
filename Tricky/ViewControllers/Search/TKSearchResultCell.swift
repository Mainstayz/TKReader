//
//  TKSearchResultCell.swift
//  Tricky
//
//  Created by Pillar on 2017/6/25.
//  Copyright © 2017年 unkown. All rights reserved.
//

import UIKit
import SDWebImage
class TKSearchResultCell: TKTableViewCell {
    
    @IBOutlet weak var titleLab: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var authorLab: UILabel!
    @IBOutlet weak var descLab: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }
    override func configure(_ model: Any) {
        super.configure(model)
        let m : TKNovelDetail =  model as! TKNovelDetail
        titleLab.text = m.title
        imgView.sd_setImage(with: URL(string: m.img!))
        authorLab.text = m.author
        descLab.text = m.desc
        
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
