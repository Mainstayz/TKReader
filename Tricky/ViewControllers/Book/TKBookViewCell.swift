//
//  TKBookViewCell.swift
//  Tricky
//
//  Created by Pillar on 2017/6/22.
//  Copyright © 2017年 unkown. All rights reserved.
//

import UIKit

class TKBookViewCell: UICollectionViewCell {
    
    
    var titleLab : UILabel?
    var contentTextView:UITextView?
    var pageLab : UILabel?
    
    
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        
        self.titleLab = UILabel(frame: CGRect(x: 20, y: 0, width: frame.width - 20, height: 40))
        self.contentView.addSubview(self.titleLab!)
        
        self.pageLab = UILabel(frame: CGRect(x: 20, y: frame.height - 30, width: frame.width - 40, height: 14))
        self.pageLab?.textAlignment = .right
        self.contentView.addSubview(self.pageLab!)
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ model: NSTextContainer) -> Void {
        
        self.contentTextView?.removeFromSuperview()
        self.contentTextView = nil
        
        self.contentTextView = UITextView(frame: TKBookConfig.sharedInstance.contentFrame, textContainer: model)

        self.contentView.addSubview(self.contentTextView!)
        self.contentTextView?.setNeedsLayout()
        
        
    }
    
    
}


