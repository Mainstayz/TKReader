//
//  TKReadingPageViewController.swift
//  Tricky
//
//  Created by Pillar on 2017/6/25.
//  Copyright © 2017年 unkown. All rights reserved.
//

import UIKit

class TKReadingPageViewController: TKViewController {
    
    @IBOutlet weak var scrollView: TKScrollView!
    
    lazy var contentView: TKContentView = {
        let view = TKContentView(frame:.zero)
        
        return view
    }()
    lazy var titleLabel: UILabel = {
        let lab = UILabel(frame:CGRect(x: 10, y: 0, width: self.view.bounds.width-20, height: self.view.bounds.size.height / 2.0))
        lab.numberOfLines = 0
        lab.font = UIFont.systemFont(ofSize: 20)
        lab.textColor = TKBookConfig.sharedInstance.textColor
        return lab
    }()
    
    var content: String?
    var chapterName : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.content == nil  {
            self.clear()
            return
        }
        self.setup()
    }
    
    
    func setup() -> Void {
        
        if self.titleLabel.superview == nil {
            self.scrollView.addSubview(self.titleLabel)
        }
        if self.contentView.superview == nil {
            self.contentView.backgroundColor = self.scrollView.backgroundColor
            self.scrollView.addSubview(self.contentView)
        }
        
        
        self.titleLabel.text = chapterName
        
        let attributedText = NSAttributedString(string: self.content!, attributes: TKBookConfig.sharedInstance.attDic)
        let limitSize = CGSize(width: UIScreen.main.bounds.width - 30, height: CGFloat.greatestFiniteMagnitude)
        let containerSize =  attributedText.boundingRect(with: limitSize, options: [.usesFontLeading,.usesLineFragmentOrigin], context: nil).size
        let frame =  CGRect(x: 10, y: self.titleLabel.frame.maxY, width: containerSize.width, height: containerSize.height)
        
        
        self.contentView.attributedText = attributedText;
        self.contentView.frame = frame
        
        self.scrollView.contentSize = CGSize(width: limitSize.width, height: self.contentView.frame.maxY + 20)
        self.scrollView.setNeedsLayout()
        
    }
    
    
    func clear() -> Void {
        self.titleLabel.removeFromSuperview()
        self.contentView.removeFromSuperview()
        self.scrollView.contentSize = CGSize.zero
    }
    
}
