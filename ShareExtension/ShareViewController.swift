//
//  ShareViewController.swift
//  ShareExtension
//
//  Created by Michael Lee on 2020/5/4.
//  Copyright © 2020 Michael Lee. All rights reserved.
//

import Cocoa
import PerfectLib
import SwiftUI

class ShareViewController: NSViewController {
    
    @IBOutlet weak var titleCell: NSTextFieldCell!
    @IBOutlet weak var imageCell: NSImageCell!
    @IBOutlet weak var urlCell: NSTextFieldCell!
    
    var id = 0
    var url = ""
    
    override var nibName: NSNib.Name? {
        return NSNib.Name("ShareViewController")
    }

    override func loadView() {
        super.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let item = self.extensionContext!.inputItems[0] as! NSExtensionItem
        let provider = item.attachments?[0]
        provider?.loadItem(forTypeIdentifier: kUTTypeURL as String, options: nil, completionHandler: {data,error in
            let nsData = data as! NSData
            let url = NSURL(dataRepresentation: nsData as Data, relativeTo: nil)
            let path = url.absoluteString
            if(path!.starts(with: "file://")){
                self.shareFile(path: url.path!)
            }else if(path!.starts(with: "http://") || path!.starts(with: "https://")){
                self.shareWeb(path: path!)
            }else{
                self.extensionContext!.completeRequest(returningItems: [NSExtensionItem()], completionHandler: nil)
            }
        })
    }

    func shareFile(path:String) {
        DbHelper.create()
        ShareServer.instance.start()
        let file = File(path)
        if(file.exists){
            let splits = file.path.split(separator: "/")
            let name = splits[splits.count-1]
            let share = ShareDTO()
            share.name = "\(name)"
            share.path = file.path.replacingOccurrences(of: "/\(name)", with: "")
            share.key = DataUtils.generateKey(name: share.name)
            do{
                try share.save{ id in
                    share.id = id as! Int
                    self.id = share.id
                }
            }catch{
                fatalError("\(error)")
            }
            self.findAllShare()
            self.showWindowInfo(
                url: "http://\(self.getIFAddresses()[0]):\(ShareServer.instance.port)/api/download/\(share.key)",
                title: share.name
            )
        }else{
            self.extensionContext!.completeRequest(returningItems: [NSExtensionItem()], completionHandler: nil)
        }
    }
    
    func shareWeb(path:String){
        self.showWindowInfo(url: path, title: "我是真的不知道Title怎么获取😅👌")
    }
    
    func showWindowInfo(url:String,title:String) {
        self.url = url
        self.urlCell.stringValue = url
        self.titleCell.stringValue = title
        self.imageCell.image = self.generateQRCodeImage(self.url, size: NSSize(width: 600, height: 600))
    }
    
    @IBAction func copy(_ sender: NSButton) {
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([NSPasteboard.PasteboardType.string], owner: nil)
        let b = pasteboard.setString(url, forType: NSPasteboard.PasteboardType.string)
        print(b)
    }
    
    @IBAction func send(_ sender: AnyObject?) {
        
        ShareServer.instance.stop()
        let share = ShareDTO()
        do{
            try share.delete(id)
        }catch{
            NSLog("\(error)")
        }
        self.extensionContext!.completeRequest(returningItems: [NSExtensionItem()], completionHandler: nil)
    }

    func generateQRCodeImage(_ content: String, size: NSSize) -> NSImage?{
        // 创建滤镜
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else {return nil}
        // 还原滤镜的默认属性
        filter.setDefaults()
        //1.3 设置生成的二维码的容错率
        //value = @"L/M/Q/H"
        filter.setValue("L", forKey: "inputCorrectionLevel")
        // 设置需要生成的二维码数据
        let contentData = content.data(using: String.Encoding.utf8)
        filter.setValue(contentData, forKey: "inputMessage")


        // 从滤镜中取出生成的图片
        guard let ciImage = filter.outputImage else {return nil}

        let context = CIContext(options: nil)
        let bitmapImage = context.createCGImage(ciImage, from: ciImage.extent)

        let colorSpace = CGColorSpaceCreateDeviceGray()
        let bitmapContext = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.none.rawValue)

        //draw image
        let scale = min(size.width / ciImage.extent.width, size.height / ciImage.extent.height)
        bitmapContext!.interpolationQuality = CGInterpolationQuality.none
        bitmapContext?.scaleBy(x: scale, y: scale)
        bitmapContext?.draw(bitmapImage!, in: ciImage.extent)

        //保存bitmap到图片
        guard let scaledImage = bitmapContext?.makeImage() else {return nil}

        return NSImage(cgImage: scaledImage, size: size)
    }
    
    func getIFAddresses() -> [String] {
        var addresses = [String]()
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>? = nil
        if getifaddrs(&ifaddr) == 0 {
          
          var ptr = ifaddr
          while ptr != nil {
            let flags = Int32((ptr?.pointee.ifa_flags)!)
            var addr = ptr?.pointee.ifa_addr.pointee
            
            // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
            if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
              if addr?.sa_family == UInt8(AF_INET) && addr?.sa_family != UInt8(AF_INET6) {
                
                // Convert interface address to a human readable string:
                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                if (getnameinfo(&addr!, socklen_t((addr?.sa_len)!), &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                  if let address = String(validatingUTF8: hostname) {
                    addresses.append(address)
                  }
                }
              }
            }
            ptr = ptr?.pointee.ifa_next
          }
 
            freeifaddrs(ifaddr)
        }
        print("Local IP \(addresses)")
        return addresses
    }
    
    func findAllShare(){
        let share = ShareDTO()
        do{
            try share.findAll()
            let rows = share.rows()
            for row in rows{
                print(row.asDataDict())
            }
        }catch{
            fatalError("\(error)")
        }
    }

}
