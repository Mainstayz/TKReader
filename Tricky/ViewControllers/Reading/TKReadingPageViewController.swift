//
//  TKReadingPageViewController.swift
//  Tricky
//
//  Created by Pillar on 2017/6/25.
//  Copyright © 2017年 unkown. All rights reserved.
//

import UIKit

class TKReadingPageViewController: TKViewController {
    

    var page : (Int,Int,Int)!
    lazy var contentView: TKContentView = {
        let view = TKContentView(frame:TKBookConfig.sharedInstance.displayRect)
        
        return view
    }()
    lazy var titleLabel: UILabel = {
        let lab = UILabel(frame:CGRect(x: 10, y: 0, width: TKScreenWidth-20, height: 30))
        lab.numberOfLines = 0
        lab.font = UIFont.systemFont(ofSize: 12)
        lab.textColor = TKBookConfig.sharedInstance.textColor
        return lab
    }()
    lazy var hintLabel: UILabel = {
        let lab = UILabel(frame:CGRect(x: 10, y: TKScreenHeight - 49, width: TKScreenWidth - 30, height: 49))
        lab.numberOfLines = 0
        lab.textAlignment = .right
        lab.font = UIFont.systemFont(ofSize: 14)
        lab.textColor = TKBookConfig.sharedInstance.textColor
        return lab
    }()
    

    private var content: String?
    var chapterName : String?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        if self.content == nil  {
            return
        }
        self.setup()
    }
    
    
    func setup() -> Void {
        
        

        if self.titleLabel.superview == nil {
            self.view.addSubview(self.titleLabel)
        }
        if self.contentView.superview == nil {
            self.contentView.backgroundColor = TKBookConfig.sharedInstance.backgroundColor
            self.view.addSubview(self.contentView)
        }
        
        if self.hintLabel.superview == nil {
            self.view.addSubview(self.hintLabel)
        }

        
        
        
        self.titleLabel.text = chapterName
        
        let attributedText = NSAttributedString(string: self.content!, attributes: TKBookConfig.sharedInstance.attDic)

        self.contentView.attributedText = attributedText;
        


        
        self.hintLabel.text = "\((page.2)+1)/\(page.1)"

        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

    }
    func syncUpdateContent(content:String?) -> Void {
        self.content = content
    }

    
    func asyncUpdateContent(content:String) -> Void {
        self.content = content
        self.setup()
    }
    

    
    func clear() -> Void {
        self.titleLabel.removeFromSuperview()
        self.contentView.removeFromSuperview()
    }

}
