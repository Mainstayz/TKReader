//
//  TKNovelDataSource.swift
//  Tricky
//
//  Created by Pillar on 2017/7/14.
//  Copyright © 2017年 unkown. All rights reserved.
//

import UIKit



protocol TKNovelDataSourceDelegate {
    func beginRequest(page:(Int,Int,Int))
    func didRequest(page:(Int,Int,Int))
}

class TKNovelDataSource: NSObject {
    
    var novel : TKNovelModel!
    var downloadedChapters : Dictionary<Int,TKChapterInfoModel> = Dictionary<Int,TKChapterInfoModel>()
    var pageinfos = Dictionary<Int,[TKPageInfoModel]>()
    var page = (0,0,0)
    var delegate : TKNovelDataSourceDelegate?
    
    init(novel: TKNovelModel) {
        super.init()
        self.novel = novel
        
    }
    
    func page(from record:(Int,Int)) -> (Int,Int,Int)?{
        let info = downloadedChapters[record.0]!
        for (index,range) in info.ranges.enumerated() {
            if record.1 >= range.0 &&  record.1 < (range.0 + range.1){
                return (record.0,info.ranges.count,index)
            }
        }
        return nil
    }

    
    func parse(chapter:Int, completion:@escaping (Bool)->Void){
        
        _ =  cacheChapter(at: chapter) {[unowned self] (suc, info) in
            
            
            if info == nil{
                completion(false)
                return
            }
            
            var tempArray = [TKPageInfoModel]()
            var page = 0
            for range in info!.ranges{
                let pageModel = TKPageInfoModel()
                pageModel.title = info!.title
                pageModel.content = info!.content.subString(range: range)
                pageModel.page = (chapter,info!.ranges.count,page)
                pageModel.location = range.0
                tempArray.append(pageModel)
                page += 1
                
            }
            
            self.pageinfos.updateValue(tempArray, forKey: chapter)
            completion(true)
        }
        
        
    }
    
    func nextPage() -> (Int,Int,Int)?{
        
        if let pageModel = pageinfos[page.0] {
            // 最后一章最后一页
            if  page.0 >= novel.chapters.count - 1 &&  page.2 >= pageModel.count - 1{
                return nil
            }else if page.0 < novel.chapters.count - 1 && page.2 >= pageModel.count - 1{
                // 中间章最后一页
                if let nPageModel = pageinfos[page.0 + 1]{
                    return (page.0 + 1,nPageModel.count, 0)
                }else{
                    return nil
                }
            }else{
                return  (page.0, pageModel.count, page.2 + 1)
            }
        }
        return nil
        
    }
    
    func prePage() -> (Int,Int,Int)?{
        
        if page.0 <= 0 && page.2 <= 0{
            return nil
        }else if page.0 > 0 && page.2 <= 0{
            if let pageModel = pageinfos[page.0 - 1] {
                return (page.0 - 1,pageModel.count, pageModel.count - 1)
            }else{
                return nil
            }
        }else{
            if let pageModel = pageinfos[page.0] {
                return  (page.0, pageModel.count,page.2 - 1)
            }
            return nil
        }
    }
    
    func preChapter() -> Int?{
        if page.0 - 1 < 0 {
            return nil
        }
        return page.0 - 1
    }
    
    func nextChapter() -> Int?{
        if page.0 + 1 > novel.chapters.count - 1{
            return nil
        }
        return page.0 + 1
    }
    
    
    func pageInfo(at page:(Int,Int,Int)?) -> TKPageInfoModel? {
        
        guard page != nil else {
            return nil
        }
        
        if let pages = pageinfos[page!.0] {
            return pages[page!.2]
        }else{
            return nil
        }
    }
    
    func cacheChaptersNearby(index : Int, completion:@escaping ()->Void){
        
        let group =  DispatchGroup()
        
        if index - 1 >= 0 {
            group.enter()
            parse(chapter: index - 1, completion: {_ in
                group.leave()
            })
        }
        if index >= 0 {
            group.enter()
            parse(chapter: index, completion: {_ in 
                group.leave()
            })
        }
        if index + 1 <= novel.chapters.count - 1{
            group.enter()
            parse(chapter: index + 1, completion: {_ in 
                group.leave()
            })
        }
        
        group.notify(queue: DispatchQueue.main) {
            completion()
        }
        
    }
    
    private func cacheChapter(at index : Int, completionHandle:@escaping(Bool,TKChapterInfoModel?)->()) -> TKChapterInfoModel?{
        debugPrint("先从内存拿章节\(index)")
        let chapterInfo = self.downloadedChapters[index]
        // 在硬盘拿
        if chapterInfo == nil {
            debugPrint("内存找不到，判断是非存在硬盘中 -- ")
            
            let chapterUrl = self.novel.chapters[index].chapterUrl!
            
            let contentPath = FileManager.default.chapterPath(title: self.novel.title!, chapterUrl:chapterUrl)
            
            if contentPath == nil {
                debugPrint("硬盘找不到，网络下载 -- ")
                
                
                let chapter = self.novel.chapters[index]
                
                TKNovelRequest.chapterDetail(url: chapter.chapterUrl, source: self.novel.source) { (content) in
                    if content != nil {
                        debugPrint("下载成功，缓存数据，返回")
                        let chapterInfo = TKChapterInfoModel()
                        chapterInfo.title = self.novel.chapters[index].chapterName
                        chapterInfo.content = content!
                        chapterInfo.ranges = content!.pagination(attributes: TKConfigure.default.contentAttribute, size:TKBookDisplayRect.size)
                        // 保存到内存
                        self.downloadedChapters.updateValue(chapterInfo, forKey: index)
                        completionHandle(true,chapterInfo)
                        // 保存到硬盘
                        FileManager.default.saveNovel(title: self.novel.title!, chapterUrl:chapterUrl, content: content!)
                        
                    }else{
                        debugPrint("网络下载失败。。。")
                        completionHandle(false,nil)
                        
                    }
                }
 
                return nil
            }else{
                // 硬盘读取
                debugPrint("硬盘中找到了，保存到内存中，并返回 ")
                let data = FileManager.default.contents(atPath: contentPath!)
                let aContent = String(data: data!, encoding: .utf8)
                let chapterInfo = TKChapterInfoModel()
                chapterInfo.title = self.novel.chapters[index].chapterName
                chapterInfo.content = aContent!
                chapterInfo.ranges = aContent!.pagination(attributes: TKConfigure.default.contentAttribute, size: TKBookDisplayRect.size)
                self.downloadedChapters.updateValue(chapterInfo, forKey: index)
                
                completionHandle(true,chapterInfo)
                return chapterInfo
            }
            
        }else{
            //如果拿到了
            debugPrint("从内存中获取数据 返回")
            completionHandle(true,chapterInfo)
            return chapterInfo
        }
        
    }
       
}
