//
//  DragView.swift
//  EasyShare
//
//  Created by Michael Lee on 2020/5/4.
//  Copyright © 2020 Michael Lee. All rights reserved.
//

import Foundation
import Cocoa

protocol FileDragDelegate: class {
    func didFinishDrag(_ filePath:String)
}

class DragView: NSView {
    weak var delegate: FileDragDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.registerForDraggedTypes([
            NSPasteboard.PasteboardType.fileURL,
            NSPasteboard.PasteboardType.fileContents
        ])
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        let sourceDragMask = sender.draggingSourceOperationMask
        let pboard = sender.draggingPasteboard
        let dragTypes = pboard.types! as NSArray
        if dragTypes.contains(NSPasteboard.PasteboardType.fileContents) {
            if sourceDragMask.contains([.link]){
                return .link
            }
            if sourceDragMask.contains([.copy]){
                return .copy
            }
        }
        return .generic
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let files = sender.draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType.fileContents)! as! Array<String>
        print(files[0])
        return true
    }
    
}
