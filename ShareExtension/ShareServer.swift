//
//  Server.swift
//  EasyShare
//
//  Created by Michael Lee on 2020/5/3.
//  Copyright © 2020 Michael Lee. All rights reserved.
//

import Foundation
import PerfectHTTP
import PerfectLib
import PerfectHTTPServer

class ShareServer{

    static let instance = ShareServer()
    
    init() {
        addApi()
        addWeb()
        routes.add(api)
        routes.add(web)
    }
    
    var state = 0
    
    var port :UInt16 = 8899
    
    let queue = DispatchQueue.global()
    
    var httpServer = HTTPServer()
    
    var routes = Routes()
    
    var api = Routes(baseUri: "/api")
    
    var web = Routes(baseUri: "/web")

    func start(){
        if state == 1 {
            return
        }
        state = 1
        httpServer.serverName = "EasyShare"
        httpServer.addRoutes(routes)
        do{
            try httpServer.serverPort = UInt16(DbHelper.getConfig(key: ConfigMap.port).value) ?? port
        }catch{
            httpServer.serverPort = port
        }
        port = httpServer.serverPort
        
        queue.async {
            do{
                try self.httpServer.start()
            }catch{
                self.state = 0
                fatalError("\(error)")
            }
        }
    }
    
    func stop(){
        httpServer.stop()
        state = 0
    }
    
    func addApi() {
        /// 获取分享详情
        api.add(method: .get, uri: "/info/{key}", handler: {request,response in
            let key = request.urlVariables["key"]
            let share = ShareDTO()
            do {
                try share.find([("key",key!)])
            }catch{
                do{
                    try response.setBody(json: self.createResponseBody(code: 500, message: "key error", data: nil))
                }catch{
                    response.setBody(string: "\(error)")
                }
                response.completed()
                return
            }
            if(share.id == 0){
                do{
                    try response.setBody(json: self.createResponseBody(code: 404, message: "key not found", data: nil))
                }catch{
                    response.setBody(string: "\(error)")
                }
                response.completed()
            }else{
                do{
                    try response.setBody(json:
                        self.createResponseBody(
                            code: 200,
                            message: "success",
                            data: share.asDataDict()))
                }catch{
                    response.setBody(string: "\(error)")
                }
                response.completed()
            }
        })
        
        api.add(method: .get, uri: "/download/{key}", handler: {request,response in
            let share = ShareDTO()
            let key = request.urlVariables["key"]
            do {
                try share.find([("key",key!)])
            }catch{
                do{
                    try response.setBody(json: self.createResponseBody(code: 500, message: "key error", data: nil))
                }catch{
                    response.setBody(string: "\(error)")
                }
                response.completed()
                return
            }
            
            if(share.id == 0){
                do{
                    try response.setBody(json: self.createResponseBody(code: 404, message: "key not found", data: nil))
                }catch{
                    response.setBody(string: "\(error)")
                }
                response.completed()
                return
            }
            //重定向
            
            //获取文件
            let file = File(share.path + "/" + share.name)
            if(file.exists && !file.isDir){
                do{
                    try file.open()
                    let size = file.size
                    let contentType = MimeType.forExtension(file.path.filePathExtension)
                    response.status = .ok
                    response.isStreaming = false
                    response.setHeader(.contentType, value: contentType)
                    response.setHeader(.contentLength, value: "\(size)")
                    response.setHeader(.acceptRanges, value: "bytes")
                    response.setHeader(.contentDisposition, value: "attachment;filename=\"\(share.name)\"")
                    let readSize = 50 * 1024 * 1024//每次读50m
                    var bytes :[UInt8]
                    repeat {
                        do {
                            bytes = try file.readSomeBytes(count: readSize)
                        }catch{
                            bytes = [UInt8]()
                        }
                        response.appendBody(bytes: bytes)
                    } while bytes.count > 0
//                    try response.appendBody(bytes: file.readSomeBytes(count: size))
                    file.close()
//                    let handler = StaticFileHandler(documentRoot: share.path)
//                    request.path = share.name
//                    handler.handleRequest(request: request, response: response)
                }catch{
                    response.setBody(string: "\(error)")
                }
                response.completed()
            }else{
                //文件不存在
                do{
                    try response.setBody(json: self.createResponseBody(code: 404, message: "file not exists", data: nil))
                }catch{
                    response.setBody(string: "\(error)")
                }
                response.completed()
            }
        })
        
    }
    
    func addWeb() {
    }
    
    func createResponseBody(code:Int,message:String,data:Any?) -> [String:Any] {
        return ["code":code,"message":message,"data":data ?? [String:Any]()]
    }
    
}
