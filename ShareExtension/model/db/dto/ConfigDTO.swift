//
//  ConfigDTO.swift
//  EasyShare
//
//  Created by Michael Lee on 2020/5/3.
//  Copyright © 2020 Michael Lee. All rights reserved.
//

import SQLiteStORM
import StORM


/// 配置表，key是主键，根据实际需求存储
class ConfigDTO :SQLiteStORM{
    var key:String = ""
    var value:String = ""
    ///备注
    var remark:String = ""
    override open func table() -> String {
        return "tb_config"
    }
    
    override open func to(_ this: StORMRow) {
        key = this.data["key"] as! String
        value = this.data["value"] as! String
        remark = this.data["remark"] as! String
    }
    
    func rows() -> [ConfigDTO] {
        var rows = [ConfigDTO]()
        for i in 0..<self.results.rows.count {
            let row = ConfigDTO()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
}
