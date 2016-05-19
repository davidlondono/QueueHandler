//
//  Queues.swift
//  David Alejandro
//
//  Created by David Alejandro on 4/1/16.
//  Copyright © 2016 David Alejandro. All rights reserved.
//
import Foundation

public struct Queue {
    
    public enum QueueConcurrency {
        case Serial
        case Concurrent
    }
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
    
    func after(when when: dispatch_time_t, block: ()->()) {
        dispatch_after(when, queue, block)
    }
    
    func after(after: NSTimeInterval, block: ()->()) {
        let when = dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(after * Double(NSEC_PER_SEC))
        )
        dispatch_after(when, queue, block)
    }
    
    
    static var GlobalUserInteractive: dispatch_queue_t {
        return dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)
    }
    static var GlobalUserInitiated: dispatch_queue_t {
        return dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)
    }
    
    
}


extension Queue {
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
        static var Current: Queue {
            let queue =  DISPATCH_CURRENT_QUEUE_LABEL
            return Queue(queue)
        }

        
    }
    
}

extension Queue {
    struct QOS {
        struct User {
            static var Interactive: Queue {
                return self.Interactive()
            }
            static func Interactive(flags: UInt = 0) -> Queue {
                let queue =  dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, flags)
                return Queue(queue)
            }
            static var Initiated: Queue {
                return self.Initiated()
            }
            static func Initiated(flags: UInt = 0) -> Queue {
                let queue =  dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, flags)
                return Queue(queue)
            }
        }
        static var Default: Queue {
            return self.Default()
        }
        static func Default(flags: UInt = 0) -> Queue {
            let queue =  dispatch_get_global_queue(QOS_CLASS_DEFAULT, flags)
            return Queue(queue)
        }
        static var Utility: Queue {
            return self.Utility()
        }
        static func Utility(flags: UInt = 0) -> Queue {
            let queue =  dispatch_get_global_queue(QOS_CLASS_UTILITY, flags)
            return Queue(queue)
        }
        static var Background: Queue {
            return self.Background()
        }
        static func Background(flags: UInt = 0) -> Queue {
            let queue =  dispatch_get_global_queue(QOS_CLASS_BACKGROUND, flags)
            return Queue(queue)
        }
        static var Unespecified: Queue {
            return self.Default(0)
        }
        static func Unespecified(flags: UInt = 0) -> Queue {
            let queue =  dispatch_get_global_queue(QOS_CLASS_UNSPECIFIED, flags)
            return Queue(queue)
        }
    }
    
}

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
