//
//  TKBookshelfService.swift
//  Tricky
//
//  Created by Pillar on 2017/6/25.
//  Copyright © 2017年 unkown. All rights reserved.
//

import UIKit

let TKBookshelfNotificationDidAddBook : String = "TKBookshelfNotificationDidAddBook"
let TKBookshelfNotificationDidGetBooksFromCache : String = "TKBookshelfNotificationDidGetBooksFromCache"

class TKBookshelfService: NSObject {
    
    // books数组
    var books = [TKNovelModel]()
    
    
    static let sharedInstance = TKBookshelfService.init()
    
    private override init() {
        super.init()
    }
    
    
    func add(book:TKNovelModel) -> Void {
        self.books.append(book)
        NotificationCenter.default.post(name:.init(TKBookshelfNotificationDidAddBook), object: nil, userInfo: nil)
    }
    
    // 进入首页的时候，更新书架上所有书本的信息，就是获取最新章节
    
    func updateBookshelf(progress: @escaping (Bool,Int,TKNovelModel?)->Void, completion handle:@escaping()->Void){
        
        let group =  DispatchGroup()
        // 编辑当前书架所有的书
        for i in 0 ..< self.books.count {
            group.enter()
            
            let bookInfo = self.books[i]
            // 更新小说的信息。获取最新章节
            TKNovelRequest.novelDetail(url: bookInfo.url, source: bookInfo.source, completion: { (novel) in
                if novel != nil {
                    self.books[i] = novel!
                    progress(true,i,novel)
                }else{
                    progress(false,i,novel)
                }
                group.leave()
            })
        }
        
        group.notify(queue: DispatchQueue.main) { 
            handle()
        }
    }
    // 读取已经缓存的书本数组
    
    func booksFromCache(completion:@escaping ([TKNovelModel]?)->()){
        
        
        let queue = DispatchQueue(label: "com.booksFromCache.tk")
        queue.async {
            // 书架books数组的缓存路径
            
            let archiverPath = self.archiverPath()
            
            print(archiverPath)
            //声明文件管理器
            let defaultManager = FileManager.default
            
            //通过文件地址判断数据文件是否存在
            if defaultManager.fileExists(atPath: archiverPath) {
                //读取bookshelf文件数据
                let data = defaultManager.contents(atPath: archiverPath)
                //解码器
                let unarchiver:NSKeyedUnarchiver = NSKeyedUnarchiver(forReadingWith: data!)
                // 解码
                let books = unarchiver.decodeObject(forKey: "books") as? [TKNovelModel]
                
                // 有效的数组
                let vaild =  books?.filter({ (model) -> Bool in
                     return model.url != nil
                })
                // 解码完成
                unarchiver.finishDecoding()
        
                completion(vaild)
                
            }else{
                completion(nil)
            }
  
        }

        
    }
    
    // 判断 书本 是否在书架上
    func novelExists(title: String) -> Bool{
    
        if self.books.count == 0 {
            return false
        }
        
        for novel in self.books{
            if novel.title == title{
                return true
            }
        }
        return false
        
    }
    
    // 缓存所有的书本信息
    func cacheBooks(completion:@escaping (Bool)->()) -> Void {
        
        let archiverPath = self.archiverPath()
        print(archiverPath)
        
        if books.count == 0 {
            do {
                try FileManager.default.removeItem(atPath: archiverPath)
            } catch let error as NSError  {
                debugPrint(error)
                completion(false)
                return
            }
            
            completion(true)
            return
        }
        
        
        
        let queue = DispatchQueue(label: "com.cacheBooks.tk")
        queue.async {

            let data =  NSMutableData()
            let archiver = NSKeyedArchiver(forWritingWith: data)
            archiver.encode(self.books, forKey: "books")
            archiver.finishEncoding()
            let suc =  data.write(toFile: archiverPath, atomically: true)
            completion(suc)
        }
    }
    
    // 返回一个归档的路径
    func archiverPath() -> String {

        return NSHomeDirectory() + "/Documents/bookshelf"
    }
}
