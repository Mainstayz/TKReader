//
//  TKReadingPageViewController.swift
//  Tricky
//
//  Created by Pillar on 2017/6/25.
//  Copyright © 2017年 unkown. All rights reserved.
//

import UIKit

class TKReadingPageViewController: TKViewController,UIScrollViewDelegate {
    
    enum TKReadingScrollTo: Int {
        case none = -1
        case up
        case bottom
    }

    
    lazy var scrollView: TKScrollView = {
        let sv = TKScrollView(frame: UIScreen.main.bounds)
        sv.bounces = false
        sv.decelerationRate = UIScrollViewDecelerationRateFast
        sv.delegate = self
        return sv
    }()
    var index : Int!
    
    lazy var contentView: TKContentView = {
        let view = TKContentView(frame:.zero)
        
        return view
    }()
    lazy var titleLabel: UILabel = {
        let lab = UILabel(frame:CGRect(x: 10, y: 0, width: TKScreenWidth-20, height: TKScreenHeight / 2.0))
        lab.numberOfLines = 0
        lab.font = UIFont.systemFont(ofSize: 20)
        lab.textColor = TKBookConfig.sharedInstance.textColor
        return lab
    }()
    
    private var content: String?
    var chapterName : String?
    var scrollViewDirectionType : TKReadingScrollTo = .none
    
    var resistance : CGFloat = 0.7
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        if self.content == nil  {
            self.clear()
            return
        }
        self.setup()
    }
    
    
    func setup() -> Void {
        
        
        if self.scrollView.superview == nil {
            self.view.addSubview(self.scrollView)
        }

        if self.titleLabel.superview == nil {
            self.scrollView.addSubview(self.titleLabel)
        }
        if self.contentView.superview == nil {
            self.contentView.backgroundColor = self.scrollView.backgroundColor
            self.scrollView.addSubview(self.contentView)
        }
        
        
        self.titleLabel.text = chapterName
        
        let attributedText = NSAttributedString(string: self.content!, attributes: TKBookConfig.sharedInstance.attDic)
        let limitSize = CGSize(width: TKScreenWidth - 30, height: CGFloat.greatestFiniteMagnitude)
        let containerSize =  attributedText.boundingRect(with: limitSize, options: [.usesFontLeading,.usesLineFragmentOrigin], context: nil).size
        let frame =  CGRect(x: 10, y: self.titleLabel.frame.maxY, width: limitSize.width, height: containerSize.height)
        
        self.contentView.frame = frame
        self.contentView.attributedText = attributedText;
    
        self.scrollView.contentSize = CGSize(width: limitSize.width, height: self.contentView.frame.maxY + 20)
        self.view.setNeedsLayout()
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        switch self.scrollViewDirectionType {
        case .up:
            self.scrollView.contentOffset = CGPoint.zero
        case .bottom:
            self.scrollView.contentOffset = CGPoint(x: 0, y: self.scrollView.contentSize.height - self.scrollView.bounds.height)
        default:
            return
        }
    }
    func syncUpdateContent(content:String) -> Void {
        self.content = content
    }

    
    func asyncUpdateContent(content:String) -> Void {
        self.content = content
        self.setup()
    }
    

    
    func clear() -> Void {
        self.titleLabel.removeFromSuperview()
        self.contentView.removeFromSuperview()
        self.scrollView.contentSize = CGSize.zero
    }

    
    //MARK:
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if self.resistance == 0{
            return
        }
        
        
        let target = targetContentOffset.pointee.y
        let current = self.scrollView.contentOffset.y
        
        
        debugPrint("target \(target) -- current \(current)")
        
        let distance = target - current
        let minDistance = scrollView.bounds.height / 2
        
        if  abs(distance) <= minDistance {
            return
        }else{
            
            var newDistance : CGFloat = 0
            
            if distance > 0{
                // 下
                newDistance = (distance - minDistance) * (1 - self.resistance) + minDistance
            }else{
                // 上
                newDistance = (distance + minDistance) * (1 - self.resistance) - minDistance
            }
            
        

            let newTarget = current + newDistance
            let point = CGPoint (x: targetContentOffset.pointee.x, y: newTarget)
            
            targetContentOffset.pointee = point
            
            debugPrint("fixTarget \(point)")
        }
        
        
    }
    
    func currentCenter() -> CGPoint!{
        return CGPoint(x: self.scrollView.contentOffset.x + self.scrollView.bounds.width / 2, y: self.scrollView.contentOffset.y + self.scrollView.bounds.height / 2)
    }
    
}
