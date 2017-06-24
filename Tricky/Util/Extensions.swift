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
}

