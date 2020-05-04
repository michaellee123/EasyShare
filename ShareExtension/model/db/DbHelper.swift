//
//  DbHelper.swift
//  EasyShare
//
//  Created by Michael Lee on 2020/5/3.
//  Copyright © 2020 Michael Lee. All rights reserved.
//

import Foundation
import SQLiteStORM

class DbHelper{
    static func create() {
        SQLiteConnector.db = "./EasyShare.sqlite"
        do {
            try ConfigDTO().setup()
            //设置端口号
            let portConfig = ConfigDTO()
            portConfig.key = ConfigMap.port
            portConfig.value = "12580"
            portConfig.remark = "端口号"
            try createConfig(config: portConfig)
        }catch{
            fatalError("\(error)")
        }
        do{
            try ShareDTO().setup()
        }catch{
            fatalError("\(error)")
        }
    }
    
    /// 读取配置
    static func getConfig(key:String) throws ->ConfigDTO{
        let config = ConfigDTO()
        try config.get(key)
        return config
    }
    
    /// 创建配置，如果已经有了就不会再写入了
    static func createConfig(config:ConfigDTO) throws {
        let createConfig = ConfigDTO()
        createConfig.key = config.key
        try createConfig.get()
        if (createConfig.value.count == 0) {
            try config.create()
        }
    }
    
}
