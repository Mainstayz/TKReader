//
//  TKNovelService.swift
//  Tricky
//
//  Created by Pillar on 2017/6/24.
//  Copyright © 2017年 unkown. All rights reserved.
//

import Foundation
import Alamofire



class TKNovelService{
    
    
    static func searchNovel(source: TKNovelSourceKey, keyword: String?, page:Int, completion: @escaping([TKNovelModel]?)->()) -> Void {
        
        let aSource = self.sourceInstalce(type: source)
    
        Alamofire.request("http://zhannei.baidu.com/cse/search", method: .get, parameters: ["q":keyword ?? "","p":page,"s":aSource.source], encoding: URLEncoding.default, headers: nil).responseData { (responseData) in
            if let data = responseData.data{
                self.parseSearchData(html: data, source: source, completion: { (result) in
                    completion(result)
                })
            }
        }
    }
    
    
    static func novelDetail(url: String?, source:TKNovelSourceKey?,completion: @escaping (_ detail : TKNovelModel?)->()){
        guard url != nil && source != nil else {
            completion(nil)
            return
        }
        
        Alamofire.request(url!, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseData { (responseData) in
            if let data = responseData.data{
                let aSource = self.sourceInstalce(type: source!)
                aSource.novelDetail(responseData: data, completion: { (datail) in
                    datail?.source = source
                    completion(datail)
                })
            }
        }
    }
    
    
    static func chapterDetail(url: String?, source:TKNovelSourceKey?,completion: @escaping (_ detail : String?)->()){
        guard url != nil && source != nil else {
            completion(nil)
            return
        }
        
        Alamofire.request(url!, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseData { (responseData) in
            if let data = responseData.data{
                let source = self.sourceInstalce(type: source!)
                source.chapterDetail(responseData: data, completion: { (content) in
                    completion(content)
                })
            }
        }
    }
    
    
    
    
    static func parseSearchData(html: Data,source: TKNovelSourceKey , completion:([TKNovelModel]?) -> ()){
        
        let string = String(data: html, encoding: .utf8)
        
        guard (string != nil) else {
            return
        }
        
        
        
        var list = [TKNovelModel]()
        
        let document = OCGumboDocument(htmlString: string)
        
        let result = document?.query("#results")?.find(".result-list")?.first()
        
        guard result != nil else {
            completion(nil)
            return
        }
        
        let elements : [OCGumboElement] = result?.childNodes.filter({ (item) -> Bool in
            return item is OCGumboElement
        }) as! [OCGumboElement]
        
        for item in elements{
            
            let imgUrl =  item.query("img.result-game-item-pic-link-img")?.first()?.attr("src")
            let detailUrl =  item.query("a.result-game-item-title-link")?.first()?.attr("href")
            let title =  item.query("a.result-game-item-title-link")?.first()?.attr("title")
            let desc = item.query("p.result-game-item-desc")?.first()?.text()?.pregReplace(pattern: "\\s", with: "")
            let info = item.query("div.result-game-item-info")?.first()
            
            let model = TKNovelModel()
            
            model.img = imgUrl
            model.title = title
            model.url = detailUrl
            model.desc = desc
            model.source = source
            
            for infoNode in (info?.childNodes.filter({ (item) -> Bool in
                return item is OCGumboElement
            })) as! [OCGumboElement]! {
                let content = infoNode.text()?.pregReplace(pattern: "\\s", with: "")
                
                if let content = content {
                    if content.contains("作者") {
                        model.author = content.components(separatedBy: "：").last
                    }
                }
                
            }
            
            list.append(model)
            
        }
        completion(list)
        
    }
    
    
    private static func sourceInstalce(type: TKNovelSourceKey) -> TKNovelSource {
        switch type {
        case .Buquge:
            return Biquge.sharedInstance
        default:
            return TKNovelSource()
        }
    }
}
