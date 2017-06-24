//
//  TKNovelService.swift
//  Tricky
//
//  Created by Pillar on 2017/6/24.
//  Copyright © 2017年 unkown. All rights reserved.
//

import Foundation
import Alamofire


struct TKNovelDetail {
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
    
    var chapters : [TKNovelChapter]?
    var info : [String]?
    var record: (Int,Int)?
    

}
struct TKNovelChapter{
    
    var chapterName : String?
    var chapterUrl : String?
    var content : String?
}



protocol TKNovelParseProtocol {
    
    var source : String {get}
    
    func novelDetail(responseData:Data, completion:(_ obj:TKNovelDetail?) -> ())
    func chapterDetail(responseData:Data, completion:(_ obj:String?) -> ())
    
}


class TKNovelService{
    
    
    static func searchNovel(source: String, keyword:String, page:Int, completion: @escaping(_ list:[Any])->()) -> Void {
        Alamofire.request("http://zhannei.baidu.com/cse/search", method: .get, parameters: ["q":keyword,"p":page,"s":source], encoding: URLEncoding.default, headers: nil).responseData { (responseData) in
            
            if let data = responseData.data{
                self.parseSearchData(html: data, completion: { (result) in
                    completion(result)
                })
            }
        }
    }
    
    
    static func novelDetail(url: String, source:TKNovelSource,completion: @escaping (_ detail : TKNovelDetail?)->()){
        Alamofire.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseData { (responseData) in
            if let data = responseData.data{
                    source.novelDetail(responseData: data, completion: { (datail) in
                        completion(datail)
                    })
                }
            }
        }
    
    
    static func chapterDetail(url: String, source:TKNovelSource,completion: @escaping (_ detail : String?)->()){
        Alamofire.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseData { (responseData) in
            if let data = responseData.data{
                source.chapterDetail(responseData: data, completion: { (content) in
                    completion(content)
                })
            }
        }
    }

    
    
    
    static func parseSearchData(html: Data, completion:(_ lists:[Dictionary<String, Any>]) -> ()){
        
        let string = String(data: html, encoding: .utf8)
        
        guard (string != nil) else {
            return
        }
        
        
        
        var list = [Dictionary<String, Any>]()
        
        
        let document = OCGumboDocument(htmlString: string)
        
        
        
        let result = document?.query("#results")?.find(".result-list")?.first()
        
        let elements : [OCGumboElement] = result?.childNodes.filter({ (item) -> Bool in
            return item is OCGumboElement
        }) as! [OCGumboElement]
        
        for item in elements{
            
            var dic = Dictionary<String,Any>()
            
            let imgUrl =  item.query("img.result-game-item-pic-link-img")?.first()?.attr("src")
            let detailUrl =  item.query("a.result-game-item-title-link")?.first()?.attr("href")
            let title =  item.query("a.result-game-item-title-link")?.first()?.attr("title")
            let desc = item.query("p.result-game-item-desc")?.first()?.text()?.pregReplace(pattern: "\\s", with: "")
            let info = item.query("div.result-game-item-info")?.first()
            
            var tmp = [String]()
            
            
            
            for infoNode in (info?.childNodes.filter({ (item) -> Bool in
                return item is OCGumboElement
            })) as! [OCGumboElement]! {
                let content = infoNode.text()?.pregReplace(pattern: "\\s", with: "")
//                let array =  content?.components(separatedBy: "：")
                tmp.append(content!)
            }
            
            
            
            dic["img"] = imgUrl
            dic["name"] = title
            dic["desc"] = desc
            dic["url"] = detailUrl
            dic["info"] = tmp
            
            list.append(dic)
            
        }
        completion(list)
        
    }
    
    
}
