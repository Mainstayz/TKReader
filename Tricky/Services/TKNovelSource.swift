//
//  TKNovelSource.swift
//  Tricky
//
//  Created by Pillar on 2017/6/24.
//  Copyright © 2017年 unkown. All rights reserved.
//

import Foundation
import CoreText

class TKNovelSource{
    
    var source : String{
        return ""
    }
    func contentUrl(with chapterUrl:String) -> String{
        return ""
    }
    func novelDetail(responseData: Data, completion: (TKNovelModel?) -> ()) {
        
    }
    
    func chapterDetail(responseData: Data, completion: (String?) -> ()) {
        
    }
    
}


class Biquge : TKNovelSource {
    
    static let sharedInstance = Biquge.init()
    
    private override init() {
        
    }
    
    
    override var source: String{
        return "1393206249994657467"
    }
    
    override func contentUrl(with chapterUrl: String?) -> String {
        
        var host = "http://www.xs.la"
        if let chapterUrl = chapterUrl {
            host += chapterUrl
        }
        return host
    }
    
    // http://www.xs.la/78_78031/
    override func novelDetail(responseData: Data, completion: (TKNovelModel?) -> ()) {
        
        let string = String(data: responseData, encoding: .utf8)
        
        guard (string != nil) else {
            return
        }
        
        let document = OCGumboDocument(htmlString: string)
        
        
        let model = TKNovelModel.init()
        
        model.title = document?.query("@og:novel:book_name")?.first()?.attr("content")
        model.desc = document?.query("@og:description")?.first()?.attr("content")
        model.img = document?.query("@og:image")?.first()?.attr("content")?.pregReplace(pattern: "\\s", with: "")
        model.category = document?.query("@og:novel:category")?.first()?.attr("content")
        model.author = document?.query("@og:novel:author")?.first()?.attr("content")
        model.url = document?.query("@og:novel:read_url")?.first()?.attr("content")
        model.status = document?.query("@og:novel:status")?.first()?.attr("content")
        model.latestChapterTime = document?.query("@og:novel:update_time")?.first()?.attr("content")
        model.latestChapterName = document?.query("@og:novel:latest_chapter_name")?.first()?.attr("content")
        model.latestChapterUrl = document?.query("@og:novel:latest_chapter_url")?.first()?.attr("content")
        
        var temp = [TKChapterListModel]()
        
        let chapters = document?.query("body")?.find("#list")?.find("a")
        
        
        
        for chapter in (chapters)! {
            let aModel =  TKChapterListModel()
            aModel.chapterUrl = self.contentUrl(with:(chapter as! OCGumboNode).attr("href"))
            aModel.chapterName = (chapter as! OCGumboNode).text()
    
            temp.append(aModel)
            
        }
        
        model.chapters = temp
        
        completion(model)
        
        
        
    }
    // http://www.xs.la/78_78031/4387358.html
    override func chapterDetail(responseData: Data, completion: (String?) -> ()) {
        let string = String(data: responseData, encoding: .utf8)
        
        guard (string != nil) else {
            completion(nil)
            return
        }
        
        let document = OCGumboDocument(htmlString: string)
        
        let content = document?.query("#content")?.first()?.text()?.trimmingCharacters(in: .whitespacesAndNewlines).pregReplace(pattern: "\\s+", with: "\n")
        
        
        
        
        if (content != nil){
            let paragraph = content?.components(separatedBy: "\n")
            
            var result : String = String()
            
            // 分段落 段首部缩进
            for tempString in paragraph! {
                result += "　　"
                result += tempString
                result += "\n"
            }
            
            completion(result)

        }else{
            completion(nil)
            return
        }
        
        
    }

}



