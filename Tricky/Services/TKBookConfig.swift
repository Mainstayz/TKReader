//
//  TKBookConfig.swift
//  Tricky
//
//  Created by Pillar on 2017/6/19.
//  Copyright © 2017年 unkown. All rights reserved.
//

import UIKit
import ChameleonFramework


class TKBookConfig {
    
    lazy var whitespace: String = {
        
        
        var string = ""
        var length : CGFloat = 0.0
        repeat{
            string += " "
            let space = NSAttributedString(string: string)
            length =  CGFloat(CTLineGetTrailingWhitespaceWidth(CTLineCreateWithAttributedString(space)))
        }while(length < (TKBookConfig.sharedInstance.fontSize!))
        
        return string
        
        
        
    }()
    
    
    
    static let sharedInstance = TKBookConfig.init()
    
    var lineSpacing : CGFloat?
    var paragraphSpacing : CGFloat?
    var firstLineHeadIndent : CGFloat?
    var textColor : UIColor?
    var fontSize : CGFloat?
    var backgroundColor : UIColor?
    
    var titleColor : UIColor?
    var pageColor : UIColor?
    
    let displayRect = CGRect(x: 10, y: 30, width: TKScreenWidth - 30, height: TKScreenHeight - 72)
    
    var attDic: Dictionary<String,Any> {
        
        let paragraphStyle = NSMutableParagraphStyle()
        //        paragraphStyle.firstLineHeadIndent = firstLineHeadIndent! * fontSize!
        paragraphStyle.lineSpacing = lineSpacing!
        paragraphStyle.paragraphSpacing = paragraphSpacing!
        paragraphStyle.lineBreakMode = .byCharWrapping
        paragraphStyle.minimumLineHeight = fontSize!
        paragraphStyle.maximumLineHeight = fontSize!
        
        let attributeDic = [NSFontAttributeName:UIFont(name: "PingFang SC", size: fontSize!)!,NSParagraphStyleAttributeName:paragraphStyle,NSForegroundColorAttributeName:textColor!] as [String : Any]
        return attributeDic
        
    }
    
    
    var titleAttDic: Dictionary<String,Any> {
        
        let attributeDic = [NSFontAttributeName:UIFont(name: "PingFang SC", size: 12.0)!,NSForegroundColorAttributeName:titleColor!] as [String : Any]
        return attributeDic
        
    }
    
    
    
    private init(){
        lineSpacing = 12.0
        paragraphSpacing = 0
        firstLineHeadIndent = 2
        textColor = UIColor.flatBlack
        backgroundColor = UIColor.init(hexString: "FAF9DE")
        
        titleColor = UIColor.flatBlack.withAlphaComponent(0.7)
        pageColor = UIColor.flatBlack.withAlphaComponent(0.7)
        fontSize = 16.0
    }
}
