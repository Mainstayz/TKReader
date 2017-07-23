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
    
    var books = [TKNovelModel]()
    
    
    static let sharedInstance = TKBookshelfService.init()
    
    private override init() {
        super.init()
    }
    
    
    func add(book:TKNovelModel) -> Void {
        self.books.append(book)
        NotificationCenter.default.post(name:.init(TKBookshelfNotificationDidAddBook), object: nil, userInfo: nil)
    }
    
    
    func updateBookshelf(progress: @escaping (Bool,Int,TKNovelModel?)->Void, completion handle:@escaping()->Void){
        
        let group =  DispatchGroup()
        for i in 0 ..< self.books.count {
            group.enter()
            let bookInfo = self.books[i]
            TKNovelService.novelDetail(url: bookInfo.url, source: bookInfo.source, completion: { (novel) in
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
    
    
    func booksFromCache(completion:@escaping ([TKNovelModel]?)->()){
        
        
        let queue = DispatchQueue(label: "com.booksFromCache.tk")
        queue.async {
            let archiverPath = self.archiverPath()
            print(archiverPath)
            //声明文件管理器
            let defaultManager = FileManager.default
            //通过文件地址判断数据文件是否存在
            if defaultManager.fileExists(atPath: archiverPath) {
                //读取文件数据
                
                let data = defaultManager.contents(atPath: archiverPath)
                //解码器
                let unarchiver:NSKeyedUnarchiver = NSKeyedUnarchiver(forReadingWith: data!)
                // 解码
                let books = unarchiver.decodeObject(forKey: "books") as? [TKNovelModel]
                
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
    func cacheBooks(completion:@escaping (Bool)->()) -> Void {
        
        let queue = DispatchQueue(label: "com.cacheBooks.tk")
        queue.async {
            let archiverPath = self.archiverPath()
            print(archiverPath)
            let data =  NSMutableData()
            let archiver = NSKeyedArchiver(forWritingWith: data)
            archiver.encode(self.books, forKey: "books")
            archiver.finishEncoding()
            let suc =  data.write(toFile: archiverPath, atomically: true)
            completion(suc)
        }
    }
    
    
    func archiverPath() -> String {

        return NSHomeDirectory() + "/Documents/bookshelf"
    }
}
