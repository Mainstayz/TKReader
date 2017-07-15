//
//  TKNovelDataSource.swift
//  Tricky
//
//  Created by Pillar on 2017/7/14.
//  Copyright © 2017年 unkown. All rights reserved.
//

import UIKit




class TKNovelDataSource: NSObject {

    var novelModel : TKNovelModel!
    var cacheData : Dictionary<Int,TKChapterInfoModel> = Dictionary<Int,TKChapterInfoModel>()
    var pages : [TKPageInfoModel]!
    var page = 0
    
    init(novel: TKNovelModel) {
        super.init()
        novelModel = novel
        pages = novel.chapters.map({ (model) -> TKPageInfoModel in
            let pageModel = TKPageInfoModel()
            pageModel.title = model.chapterName
            return pageModel
        })
        
        cacheChapterData(at: novelModel.indexOfChapter) {[unowned self] (suc, info) in
            var tempArray = [TKPageInfoModel]()
            var page = 0
            for range in info!.ranges{
                let pageModel = TKPageInfoModel()
                pageModel.title = info!.title
                pageModel.content = info!.content.subString(range: range)
                pageModel.page = (self.novelModel.indexOfChapter,page)
                pageModel.location = range.0
                if (self.novelModel.location < range.0 + range.1) && (self.novelModel.location >= range.0) {
                    self.page = page
                }
                tempArray.append(pageModel)
                page += 1
                
            }
            self.pages.replaceSubrange(0..<1, with: tempArray)
    
        }
    }
    
    func currentPage() -> TKPageInfoModel? {
        let pageModel = self.pages[page]
        novelModel.location = pageModel.location
        return pageModel
    }
    
    func nextPage() -> TKPageInfoModel?{
        if page == pages.count - 1{
            return nil

        }else{
            let pageModel = pages[page + 1]
            novelModel.location = pageModel.location
            return pageModel
        }
    }
    
    func prePage() -> TKPageInfoModel?{
        if page <= 0{
            return nil
        }else{
            let pageModel = pages[page - 1]
            novelModel.location = pageModel.location
            return pageModel
        }
        
    }
    // 缓存xxx章数据
    func cacheChapterData(at index : Int, completion:@escaping(Bool,TKChapterInfoModel?)->()) -> Void{
        debugPrint("先从内存拿章节\(index)")
        let chapterInfo = self.cacheData[index]
        // 在硬盘拿
        if chapterInfo == nil {
            debugPrint("内存找不到，判断是非存在硬盘中 -- ")
            
            let chapterUrl = self.novelModel.chapters[index].chapterUrl!
            
            let contentPath = FileManager.default.chapterPath(title: self.novelModel.title!, chapterUrl:chapterUrl)
            
            if contentPath == nil {
                debugPrint("硬盘找不到，网络下载 -- ")
                
                self.downData(index: index, complete: {[unowned self] (suc,newContent) in
                    
                    if suc == true && newContent != nil{
                        debugPrint("下载成功，缓存数据，返回")
                        let chapterInfo = TKChapterInfoModel()
                        chapterInfo.title = self.novelModel.chapters[index].chapterName
                        chapterInfo.content = newContent!
                        chapterInfo.ranges = newContent!.pagination(attributes: TKBookConfig.sharedInstance.attDic, size: TKBookConfig.sharedInstance.displayRect.size)
                        self.cacheData.updateValue(chapterInfo, forKey: index)
                        completion(true,chapterInfo)
                        FileManager.default.saveNovel(title: self.novelModel.title!, chapterUrl:chapterUrl, content: newContent!)
                    }else{
                        debugPrint("网络下载失败。。。")
                        completion(false,nil)
                        
                    }
                })
                return
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
        
                completion(true,chapterInfo)
                return
            }
            
        }else{
            //如果拿到了
            debugPrint("从内存中获取数据 返回")
            completion(true,chapterInfo)
            return
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
