//
//  Extensions.swift
//  Tricky
//
//  Created by Pillar on 2017/6/24.
//  Copyright © 2017年 unkown. All rights reserved.
//

import UIKit

extension String {

    var count: Int {
        let string = self as NSString
        return string.length
    }
    

    func pregReplace(pattern: String, with: String,
                     options: NSRegularExpression.Options = []) -> String {
        let regex = try! NSRegularExpression(pattern: pattern, options: options)
        return regex.stringByReplacingMatches(in: self, options: [],
                                              range: NSMakeRange(0, self.count),
                                              withTemplate: with)
    }
    
    
    func md5() -> String{
        let cStr = self.cString(using: String.Encoding.utf8);
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 16)
        CC_MD5(cStr!,(CC_LONG)(strlen(cStr!)), buffer)
        let md5String = NSMutableString();
        for i in 0 ..< 16{
            md5String.appendFormat("%02x", buffer[i])
        }
        free(buffer)
        return md5String as String
    }
    
    func subString(range:(Int,Int)) -> String {
        let startIndex = self.index(self.startIndex, offsetBy: range.0)
        let endIndex = self.index(self.startIndex, offsetBy: range.0 + range.1)
        return self.substring(with: Range(startIndex..<endIndex))
    }
 
    func pagination(attributes:Dictionary<String,Any>,size:CGSize) -> [(Int,Int)] {
        var resultRange = [(Int,Int)]()
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let attributedString = NSAttributedString(string: self, attributes: attributes)
        var rangeIndex = 0
        repeat{
            let length = [750,attributedString.length - rangeIndex].min()!
            let subString = attributedString.attributedSubstring(from: NSMakeRange(rangeIndex, length))
            let childFramesetter = CTFramesetterCreateWithAttributedString(subString)
            let bezierPath = UIBezierPath(rect: rect)
            let frame = CTFramesetterCreateFrame(childFramesetter, CFRangeMake(0, 0), bezierPath.cgPath, nil)
            let range = CTFrameGetVisibleStringRange(frame)
            let r = (rangeIndex, range.length)
            if r.1 > 0 {
                resultRange.append(r)
            }
            rangeIndex += r.1
        }while(rangeIndex < attributedString.length && attributedString.length > 0)
        return resultRange
    }
}
