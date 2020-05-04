//
//  ContentView.swift
//  EasyShare
//
//  Created by Michael Lee on 2020/5/2.
//  Copyright © 2020 Michael Lee. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("选中要分享的文件，右键->共享->EasyShare，默认端口12580，要修改的话自己去看数据库。本来这里是想做成配置窗口的，但是太难了，就啥也没做，好了，这个窗口可以点关闭了。对了，分享页面，扫码下载完成之后再点完成按钮，不然会断开链接的。")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
