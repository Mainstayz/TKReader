//
//  TKNovelSource.swift
//  Tricky
//
//  Created by Pillar on 2017/6/24.
//  Copyright © 2017年 unkown. All rights reserved.
//

import Foundation


class TKNovelSource : TKNovelParseProtocol  {
    
    var source : String{
        return ""
    }
    func novelDetail(responseData: Data, completion: (TKNovelDetail?) -> ()) {
        
    }
    
    func chapterDetail(responseData: Data, completion: (String?) -> ()) {
        
    }
    
}


class TKBiqugeSource: TKNovelSource {
    override var source: String{
        return "1393206249994657467"
    }
    
    override func novelDetail(responseData: Data, completion: (TKNovelDetail?) -> ()) {
        
        let string = String(data: responseData, encoding: .utf8)
        
        guard (string != nil) else {
            return
        }
        
        let document = OCGumboDocument(htmlString: string)
        
        let head = document?.query("head")
        
        var model = TKNovelDetail.init()
        
        model.title = head?.find("og:novel:book_name")?.first()?.attr("content")
        model.desc = head?.find("og:description")?.first()?.attr("content")
        model.img = head?.find("og:image")?.first()?.attr("content")?.pregReplace(pattern: "\\s", with: "")
        model.category = head?.find("og:novel:category")?.first()?.attr("content")
        model.author = head?.find("og:novel:author")?.first()?.attr("content")
        model.url = head?.find("og:novel:read_url")?.first()?.attr("content")
        model.status = head?.find("og:novel:status")?.first()?.attr("content")
        model.latestChapterTime = head?.find("og:novel:update_time")?.first()?.attr("content")
        model.latestChapterName = head?.find("og:novel:latest_chapter_name")?.first()?.attr("content")
        model.latestChapterUrl = head?.find("og:novel:latest_chapter_url")?.first()?.attr("content")
        
        var temp = [TKNovelChapter]()
        
        let chapters = document?.query("body")?.find("#list")?.find("a")
        
        
        
        for chapter in (chapters)! {
            var aModel =  TKNovelChapter.init()
            aModel.chapterUrl = (chapter as! OCGumboNode).attr("href")
            aModel.chapterName = (chapter as! OCGumboNode).text()
            aModel.content = nil
            temp.append(aModel)
            
        }
        
        model.chapters = temp
        
        completion(model)
        
        
        
    }
    
    override func chapterDetail(responseData: Data, completion: (String?) -> ()) {
        let string = String(data: responseData, encoding: .utf8)
        
        guard (string != nil) else {
            return
        }
        
        let document = OCGumboDocument(htmlString: string)
        
        let content = document?.query("#content")?.first()?.text()?.trimmingCharacters(in: .whitespacesAndNewlines).pregReplace(pattern: "\\s+", with: "\n")
    
        completion(content)
        
    }
    
    
}
