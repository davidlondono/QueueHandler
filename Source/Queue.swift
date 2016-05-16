//
//  Queues.swift
//  David Alejandro
//
//  Created by David Alejandro on 4/1/16.
//  Copyright © 2016 David Alejandro. All rights reserved.
//
import Foundation

struct Queue {
    
    private let queue: dispatch_queue_t
    
    
    
    init(_ queue: dispatch_queue_t) {
        self.queue = queue
    }
    
    init() {
        self.init(DISPATCH_CURRENT_QUEUE_LABEL)
    }
    
    func sync(block: ()->()) {
        dispatch_async(queue, block)
    }
    
    func async(block: ()->()) {
        dispatch_async(queue,block)
    }
    
    func after(when: dispatch_time_t, block: ()->()) {
        dispatch_after(when, queue, block)
    }
    
    
    static var GlobalUserInteractive: dispatch_queue_t {
        return dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)
    }
    static var GlobalUserInitiated: dispatch_queue_t {
        return dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)
    }
    
    
    static var Main: Queue {
        let queue = dispatch_get_main_queue()
        return Queue(queue)
    }
    
}

extension Queue {
    struct Global {
        private init() {}
        struct Priority {
            private init() {}
            static var Background: Queue {
                let queue =  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
                return Queue(queue)
            }
            
            static var Default: Queue {
                let queue =  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                return Queue(queue)
            }
            
            static var Hight: Queue {
                let queue =  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
                return Queue(queue)
            }
            
            static var Low: Queue {
                let queue =  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)
                return Queue(queue)
            }
            
        }
    }
    
}



typealias dispatch_cancelable_closure = (cancel: Bool) -> Void

class Delay {
    private let time: NSTimeInterval
    private var closure: dispatch_block_t?
    private let queue: dispatch_queue_t
    private func dispatch_later(clsr:()->Void) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(time * Double(NSEC_PER_SEC))
            ),
            queue, clsr)
    }


    init(_ time: NSTimeInterval, queue: dispatch_queue_t = dispatch_get_main_queue(), closure: dispatch_block_t) {
        self.time = time
        self.closure = closure
        self.queue = queue

        dispatch_later { [weak self] in
            self?.closure?()
            self?.closure = nil
        }
    }

    deinit {
        cancel()
    }

    func cancel() {
        closure = nil
    }
}
