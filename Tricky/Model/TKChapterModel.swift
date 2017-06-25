//
//  TKChapterModel.swift
//  Tricky
//
//  Created by Pillar on 2017/6/25.
//  Copyright © 2017年 unkown. All rights reserved.
//

import UIKit

class TKChapterModel : NSObject, NSCoding{
    var chapterName : String?
    var chapterUrl : String?
    override init() {
        super.init()
        
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.chapterName, forKey: "name")
        aCoder.encode(self.chapterUrl, forKey: "url")

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        self.chapterName = aDecoder.decodeObject(forKey: "name") as? String
        self.chapterUrl = aDecoder.decodeObject(forKey: "url") as? String
    }
    
}



