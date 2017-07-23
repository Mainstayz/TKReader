//
//  TKNovelModel.swift
//  Tricky
//
//  Created by Pillar on 2017/6/25.
//  Copyright © 2017年 unkown. All rights reserved.
//

import UIKit

enum TKNovelSourceKey:String{
    case Buquge
    case Dingdian
}



class TKNovelModel: NSObject, NSCoding{
    var title : String?
    var img : String?
    var desc : String?
    var url : String?
    var author : String?
    var category : String?
    var status : String?
    var latestChapterName : String?
    var latestChapterUrl : String?
    var latestChapterTime : String?
    var source: TKNovelSourceKey?
    var chapters : [TKChapterListModel] = [TKChapterListModel]()

    override init() {
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(self.title, forKey: "title")
        aCoder.encode(self.img, forKey: "img")
        aCoder.encode(self.desc, forKey: "desc")
        aCoder.encode(self.url, forKey: "url")
        aCoder.encode(self.author, forKey: "author")
        aCoder.encode(self.category, forKey: "category")
        aCoder.encode(self.status, forKey: "status")
        aCoder.encode(self.latestChapterName, forKey: "latestChapterName")
        aCoder.encode(self.latestChapterUrl, forKey: "latestChapterUrl")
        aCoder.encode(self.latestChapterTime, forKey: "latestChapterTime")
        aCoder.encode(self.source?.rawValue, forKey: "source")
        aCoder.encode(self.chapters, forKey: "chapters")

        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        self.title = aDecoder.decodeObject(forKey: "title") as? String
        self.img = aDecoder.decodeObject(forKey: "img") as? String
        self.desc = aDecoder.decodeObject(forKey: "desc") as? String
        self.url = aDecoder.decodeObject(forKey: "url") as? String
        self.author = aDecoder.decodeObject(forKey: "author") as? String
        self.category = aDecoder.decodeObject(forKey: "category") as? String
        self.status = aDecoder.decodeObject(forKey: "status") as? String
        self.latestChapterName = aDecoder.decodeObject(forKey: "latestChapterName") as? String
        self.latestChapterUrl = aDecoder.decodeObject(forKey: "latestChapterUrl") as? String
        self.latestChapterTime = aDecoder.decodeObject(forKey: "latestChapterTime") as? String
        self.source = (aDecoder.decodeObject(forKey: "source") as? String).map { TKNovelSourceKey(rawValue: $0) }!
        self.chapters = aDecoder.decodeObject(forKey: "chapters") as? [TKChapterListModel] ?? [TKChapterListModel]()
    }
    
    
}

