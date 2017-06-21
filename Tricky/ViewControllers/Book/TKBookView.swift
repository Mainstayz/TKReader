//
//  TKBookView.swift
//  Tricky
//
//  Created by Pillar on 2017/6/19.
//  Copyright © 2017年 unkown. All rights reserved.
//

import UIKit



protocol TKBookViewDelegate : NSObjectProtocol{
    
    func bookViewWillBeginLoading()
    func bookViewDidEndLoading()
    func bookViewWillBeginDragging(_ bookView : TKBookView)
    func bookViewDidEndDecelerating(_ bookView : TKBookView, _ location:Int)
 }



class TKBookView: UIScrollView , UIScrollViewDelegate{


    // ---------------------
    
    var chapters:[TKCharacter]?
    
    
    
    
    // ---------------------
    var chapterTitle : NSAttributedString?
    var bookMarkup : NSAttributedString?
    
    var textStorage : NSTextStorage?
    var layoutManager : NSLayoutManager! = NSLayoutManager()
    var currentPage: Int {
        let progress =  self.contentOffset.x / self.bounds.size.width
        return Int(round(progress))
    }
    var pageCount = 0
    var location : Int = 0
    
    
    weak var aDelegate : TKBookViewDelegate?
    
    
    var textViews : NSMutableSet = NSMutableSet()
    var titleViews : NSMutableSet = NSMutableSet()
    var pageViews : NSMutableSet = NSMutableSet()
    
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.delegate = self
        self.showsHorizontalScrollIndicator = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func buildFrames() -> Void {
        

        _ = self.subviews.map({$0.removeFromSuperview()})
    
        self.textViews.removeAllObjects()
        self.titleViews.removeAllObjects()
        self.pageViews.removeAllObjects()
        
        
        self.aDelegate?.bookViewWillBeginLoading()
        
        self.textStorage = NSTextStorage(attributedString: self.bookMarkup!)
        self.textStorage!.addLayoutManager(self.layoutManager)
       
        var range = NSMakeRange(0, 0)
        var containerIndex = 0
        
       
        while NSMaxRange(range) < self.layoutManager.numberOfGlyphs {
            
            
            let textViewRect = self.frameForViewAtIndex(index: containerIndex)
            
            let containerSize = CGSize(width: textViewRect.width, height: textViewRect.height)
            
            let textContainer = NSTextContainer(size: containerSize)
            self.layoutManager.addTextContainer(textContainer)
            
            containerIndex += 1
            range = self.layoutManager.glyphRange(for: textContainer)
            
            print("\(range.location) --- \(range.length) ---- \(textContainer.size)")
            
        }
        
        self.pageCount = containerIndex;
        
        self.contentSize = CGSize(width:self.bounds.width * (CGFloat)(containerIndex),height:self.bounds.height)
        
        self.isPagingEnabled = true
        
        
        self.location > 0 ? self.navigateToCharacterLocation(location: self.location) : self .buildViewsForCurrentOffset()
        
        self.aDelegate?.bookViewDidEndLoading()
    }

    
    
    private func titleViewAtIndex(index:Int) -> UILabel!{
        for titleView in self.titleViews{
            
            let tag = (titleView as! UILabel).tag
            if (tag == index % 3){
                (titleView as! UILabel).tag = index % 3
                return titleView as? UILabel
            }
        }

        
        // 初始化titleView
        
        let titleView = UILabel()
        titleView.attributedText = self.chapterTitle
        titleView.tag = index % 3
        self.titleViews.add(titleView)
        self.addSubview(titleView)
        return titleView
    }
    
    
    private func pageViewAtIndex(index:Int) -> UILabel!{
        for pageView in self.pageViews{
            let tag = (pageView as! UILabel).tag
            if (tag == index % 3 ){
                (pageView as! UILabel).tag = index % 3
                return pageView as? UILabel
            }
        }
        
        
        // 初始化pageView
        
        let pageView = UILabel()
        pageView.tag = index % 3
        pageView.textAlignment = .right
        pageView.font = UIFont.systemFont(ofSize: 12)
        pageView.textColor = UIColor(hue: 0, saturation: 0, brightness: 0.17, alpha: 1).withAlphaComponent(0.7)
        self.pageViews.add(pageView)
        self.addSubview(pageView)
        return pageView
    }

    
    
    
    
    private func textViewForContainer(_ container : NSTextContainer) -> UITextView? {
        for textView in self.textViews {
            if (textView as! UITextView).textContainer == container {
                return textView as? UITextView
            }
        }
        
        return nil
    }
    
    private func shouldRenderView(_ viewFrame: CGRect) -> Bool {
        if viewFrame.origin.x + viewFrame.size.width < self.contentOffset.x - self.bounds.size.width {
            return false
        }
        
        if viewFrame.origin.x > self.contentOffset.x +  self.bounds.size.width * 2.0 {
            return false
        }
        
        return true
    }
    
    private func frameForViewAtIndex(index:Int) -> CGRect {
        var textViewRect = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
        textViewRect = textViewRect.insetBy(dx: 15, dy: 44)
        textViewRect = textViewRect.offsetBy(dx: self.bounds.size.width * (CGFloat)(index) - 2, dy: -5)
        return textViewRect
        
    }
    
    
    
    
    func navigateToCharacterLocation(location:Int) -> Void {
        var offset : CGFloat = 0.0;
        for  container in self.layoutManager.textContainers{
            let glypRange = self.layoutManager.glyphRange(for: container)
            let charRange = self.layoutManager.characterRange(forGlyphRange: glypRange, actualGlyphRange: nil)
            if (location >= charRange.location) && (location < NSMaxRange(charRange)) {
                self.contentOffset = CGPoint(x: offset, y: 0)
                self.buildViewsForCurrentOffset()
                self.location = 0
                return
            }
            offset += self.bounds.width
        }
    }
    
    
    private func buildViewsForCurrentOffset() -> Void {
        
    
        
        let queue =  DispatchQueue(label: "com.buildView.queue")
    
        queue.async {
            
            let start = max(0, self.currentPage - 3)
            
            let end = min(self.layoutManager.textContainers.count, self.currentPage + 3)
            
            
            for i in start  ..< end {
                
                let textContainer = self.layoutManager.textContainers[i]
                let textView = self.textViewForContainer(textContainer)
                let textViewRect = self.frameForViewAtIndex(index: i)
                
                let titleView = self.titleViewAtIndex(index:i)
                let pageView = self.pageViewAtIndex(index: i)
                
                
                if self.shouldRenderView(textViewRect) {
                    
                    DispatchQueue.main.async {
                        titleView!.frame = CGRect(x: textViewRect.minX + 8, y: 0, width: textViewRect.width - 8, height: textViewRect.minY)
                        pageView!.frame = CGRect(x: textViewRect.minX, y: self.bounds.height - 30, width: textViewRect.width, height: 14)
                        pageView?.text = "\(i+1)／\(self.layoutManager.textContainers.count)";
                        if (textView == nil) {
                            print("add view at index \(i)")
                            let textView = UITextView(frame: textViewRect.insetBy(dx: 0, dy: 0), textContainer: textContainer)
                            textView.backgroundColor = self.backgroundColor
                            self.addSubview(textView)
                            self.textViews.add(textView)
                        }
                    }
                    
                    
                }else{
                    if (textView != nil) {
                      
                        DispatchQueue.main.async {
                            print("remove view at index \(i)")
                            textView?.removeFromSuperview();
                            self.textViews.remove(textView!)

                        }
                    
                    }
                }
                
            }
        }
        

        
    }
    

    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.aDelegate?.bookViewWillBeginDragging(self)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
 
        self.buildViewsForCurrentOffset()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let textContainer = self.layoutManager.textContainers[self.currentPage]
        self.aDelegate?.bookViewDidEndDecelerating(self, self.layoutManager.glyphRange(for: textContainer).location)
    }
    
}



