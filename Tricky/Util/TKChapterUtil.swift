//
//  TKChapterUtil.swift
//  Tricky
//
//  Created by Pillar on 2017/7/2.
//  Copyright © 2017年 unkown. All rights reserved.
//

import UIKit

class TKChapterUtil: NSObject {
//    private var novel : TKNovelModel!
    
//    var chapterContents = Dictionary<Int,String>()
    // 所有章节的range
    var content : String!
    
    var contentRanges : [(Int,Int)]!
    
    
    init(content : String!) {
        super.init()
        self.content = content
        self.contentRanges = content.pagination(with: TKBookConfig.sharedInstance.attDic, constrainedTo:CGSize(width: TKScreenWidth - 30, height: TKScreenHeight - 72))
    
    }
    
}
