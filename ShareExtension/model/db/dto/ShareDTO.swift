//
//  ShareDTO.swift
//  EasyShare
//
//  Created by Michael Lee on 2020/5/3.
//  Copyright © 2020 Michael Lee. All rights reserved.
//

import Foundation

import SQLiteStORM
import StORM

/// 分享配置
class ShareDTO :SQLiteStORM{
    var id :Int = 0
    /// 文件名
    var name :String = ""
    /// 分享key，分享的url后面跟这个
    var key :String = ""
    /// 文件路径
    var path :String = ""
    /// 创建时间
    var createTime :Int64 = Int64(NSDate().timeIntervalSince1970)
    
    override func table() -> String {
        return "tb_share"
    }
    
    override func to(_ this: StORMRow) {
        id = this.data["id"] as! Int
        name = this.data["name"] as! String
        key = this.data["key"] as! String
        path = this.data["path"] as! String
        createTime = Int64(this.data["createTime"] as! String)!
    }
    
    func rows() -> [ShareDTO] {
        var rows = [ShareDTO]()
        for i in 0..<self.results.rows.count{
            let row = ShareDTO()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
    
}
