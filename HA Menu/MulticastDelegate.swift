//
//  MulticastDelegate.swift
//  HA Menu
//
//  Created by Andrew Jackson on 25/07/2020.
//  Copyright © 2020 CodeChimp. All rights reserved.
//

import Foundation

class MulticastDelegate <T> {
    private let delegates: NSHashTable<AnyObject> = NSHashTable.weakObjects()

    func add(delegate: T) {
        delegates.add(delegate as AnyObject)
    }

    func remove(delegate: T) {
        for oneDelegate in delegates.allObjects.reversed() {
            if oneDelegate === delegate as AnyObject {
                delegates.remove(oneDelegate)
            }
        }
    }

    func invoke(invocation: (T) -> ()) {
        for delegate in delegates.allObjects.reversed() {
            invocation(delegate as! T)
        }
    }

    var count: Int {
        return delegates.count
    }
}

func += <T: AnyObject> (left: MulticastDelegate<T>, right: T) {
    left.add(delegate: right)
}

func -= <T: AnyObject> (left: MulticastDelegate<T>, right: T) {
    left.remove(delegate: right)
}
