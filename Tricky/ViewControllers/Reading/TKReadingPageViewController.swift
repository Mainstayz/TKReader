//
//  TKReadingPageViewController.swift
//  Tricky
//
//  Created by Pillar on 2017/6/25.
//  Copyright © 2017年 unkown. All rights reserved.
//

import UIKit

class TKReadingPageViewController: TKViewController {
    

    var page : (Int,Int)!
    
    lazy var contentView: TKContentView = {
        let view = TKContentView(frame:TKBookConfig.sharedInstance.displayRect)
        
        return view
    }()
    lazy var titleLabel: UILabel = {
        let lab = UILabel(frame:CGRect(x: 10, y: 0, width: TKScreenWidth-20, height: 30))
        lab.numberOfLines = 0
        lab.font = UIFont.systemFont(ofSize: 20)
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
        
        
        self.titleLabel.text = chapterName
        
        let attributedText = NSAttributedString(string: self.content!, attributes: TKBookConfig.sharedInstance.attDic)

        self.contentView.attributedText = attributedText;

        
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
