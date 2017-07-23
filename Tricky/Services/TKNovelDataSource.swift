//
//  TKNovelDataSource.swift
//  Tricky
//
//  Created by Pillar on 2017/7/14.
//  Copyright © 2017年 unkown. All rights reserved.
//

import UIKit



protocol TKNovelDataSourceDelegate {
    func beginRequest(page:(Int,Int))
    func didRequest(page:(Int,Int))
}


class TKNovelDataSource: NSObject {
    
    var novelModel : TKNovelModel!
    var cacheData : Dictionary<Int,TKChapterInfoModel> = Dictionary<Int,TKChapterInfoModel>()
    var pages = Dictionary<Int,[TKPageInfoModel]>()
    var page = (0,0,0)
    
    var delegate : TKNovelDataSourceDelegate?
    
    init(novel: TKNovelModel) {
        super.init()
        novelModel = novel
        let record =  TKReadingRecordManager.sharedInstance.readingRecord(key: novel.title!)
        if record.0 != 0 || record.1 != 0 {
            _ =  cacheChapterData(at: record.0) {[unowned self] (suc, info) in
                guard info != nil else {
                    return
                }
                var aPage = 0
                for range in info!.ranges{
                    if record.1 >= range.0 &&  record.1 < (range.0 + range.1){
                        self.page = (record.0,info!.ranges.count,aPage)
                    }
                    aPage += 1
                }
                
            }
        }
        
    }
    
    
    
    func parse(chapter:Int, completion:@escaping ()->Void){
        
        _ =  cacheChapterData(at: chapter) {[unowned self] (suc, info) in
            
            
            if info == nil{
                completion()
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
            
            self.pages.updateValue(tempArray, forKey: chapter)
            
            completion()
        }
        
        
    }
    
    func currentPage() -> (Int,Int,Int)?{
        return page
    }
    
    func nextPage() -> (Int,Int,Int)?{
        
        if let pageModel = pages[page.0] {
            // 最后一章最后一页
            if  page.0 >= novelModel.chapters.count - 1 &&  page.2 >= pageModel.count - 1{
                return nil
            }else if page.0 < novelModel.chapters.count - 1 && page.2 >= pageModel.count - 1{
                // 中间章最后一页
                if let nPageModel = pages[page.0 + 1]{
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
            if let pageModel = pages[page.0 - 1] {
                return (page.0 - 1,pageModel.count, pageModel.count - 1)
            }else{
                return nil
            }
        }else{
            if let pageModel = pages[page.0] {
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
        if page.0 + 1 > novelModel.chapters.count - 1{
            return nil
        }
        return page.0 + 1
    }
    
    
    func pageInfo(page:(Int,Int,Int)?) -> TKPageInfoModel? {
        
        guard page != nil else {
            return nil
        }
        
        if let pageModel = pages[page!.0] {
            return pageModel[page!.2]
        }else{
            return nil
        }
    }
    
    func cacheChaptersNearby(index : Int, completion:@escaping ()->Void){
        
        let group =  DispatchGroup()
        
        if index - 1 >= 0 {
            group.enter()
            parse(chapter: index - 1, completion: {
                group.leave()
            })
        }
        if index >= 0 {
            group.enter()
            parse(chapter: index, completion: {
                group.leave()
            })
        }
        if index + 1 <= novelModel.chapters.count - 1{
            group.enter()
            parse(chapter: index + 1, completion: {
                group.leave()
            })
        }
        
        group.notify(queue: DispatchQueue.main) {
            completion()
        }
        
    }
    
    func cacheChapterData(at index : Int, completionHandle:@escaping(Bool,TKChapterInfoModel?)->()) -> TKChapterInfoModel?{
        debugPrint("先从内存拿章节\(index)")
        let chapterInfo = self.cacheData[index]
        // 在硬盘拿
        if chapterInfo == nil {
            debugPrint("内存找不到，判断是非存在硬盘中 -- ")
            
            let chapterUrl = self.novelModel.chapters[index].chapterUrl!
            
            let contentPath = FileManager.default.chapterPath(title: self.novelModel.title!, chapterUrl:chapterUrl)
            
            if contentPath == nil {
                debugPrint("硬盘找不到，网络下载 -- ")
                
                
                let chapter = self.novelModel.chapters[index]
                
                TKNovelService.chapterDetail(url: chapter.chapterUrl, source: self.novelModel.source) { (content) in
                    if content != nil {
                        debugPrint("下载成功，缓存数据，返回")
                        let chapterInfo = TKChapterInfoModel()
                        chapterInfo.title = self.novelModel.chapters[index].chapterName
                        chapterInfo.content = content!
                        chapterInfo.ranges = content!.pagination(attributes: TKBookConfig.sharedInstance.attDic, size: TKBookConfig.sharedInstance.displayRect.size)
                        self.cacheData.updateValue(chapterInfo, forKey: index)
                        completionHandle(true,chapterInfo)
                        FileManager.default.saveNovel(title: self.novelModel.title!, chapterUrl:chapterUrl, content: content!)
                        
                    }else{
                        debugPrint("网络下载失败。。。")
                        completionHandle(false,nil)
                        
                    }
                }
                
                
                
                //
                //                self.downData(index: index, complete: {[weak self] (suc,newContent) in
                //
                //                    if let strongSelf = self {
                //
                //                        if suc == true && newContent != nil{
                //                            debugPrint("下载成功，缓存数据，返回")
                //                            let chapterInfo = TKChapterInfoModel()
                //                            chapterInfo.title = strongSelf.novelModel.chapters[index].chapterName
                //                            chapterInfo.content = newContent!
                //                            chapterInfo.ranges = newContent!.pagination(attributes: TKBookConfig.sharedInstance.attDic, size: TKBookConfig.sharedInstance.displayRect.size)
                //                            strongSelf.cacheData.updateValue(chapterInfo, forKey: index)
                //                            completionHandle(true,chapterInfo)
                //                            FileManager.default.saveNovel(title: strongSelf.novelModel.title!, chapterUrl:chapterUrl, content: newContent!)
                //                        }else{
                //                            debugPrint("网络下载失败。。。")
                //                            completionHandle(false,nil)
                //
                //                        }
                //                    }
                //
                //                })
                return nil
            }else{
                // 硬盘读取
                debugPrint("硬盘中找到了，保存到内存中，并返回 ")
                let data = FileManager.default.contents(atPath: contentPath!)
                let aContent = String(data: data!, encoding: .utf8)
                let chapterInfo = TKChapterInfoModel()
                chapterInfo.title = self.novelModel.chapters[index].chapterName
                chapterInfo.content = aContent!
                chapterInfo.ranges = aContent!.pagination(attributes: TKBookConfig.sharedInstance.attDic, size: TKBookConfig.sharedInstance.displayRect.size)
                self.cacheData.updateValue(chapterInfo, forKey: index)
                
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
    
    
    // 下载xx章数据
    func downData(index:Int, complete:@escaping (Bool,String?)->()) -> Void {
        
        let chapter = self.novelModel.chapters[index]
        
        TKNovelService.chapterDetail(url: chapter.chapterUrl, source: self.novelModel.source) { (content) in
            if content != nil {
                complete(true,content)
            }else{
                complete(false,nil)
            }
        }
    }
    
}
