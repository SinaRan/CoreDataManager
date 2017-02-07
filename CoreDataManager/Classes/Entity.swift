//
//  Entities.swift
//  CoreDataManager
//
//  Created by DT-iOS on 2/5/17.
//  Copyright © 2017 DT-iOS. All rights reserved.
//

import Foundation

public class Entity {
    private var _attributes : [String]? = nil
    private var _name : String! = nil
    
    internal var attributes : [String]? { get{return _attributes} }
    internal var name : String! { get{ return _name}}
    
   public init(attributes:[String],name:String) {
        _attributes = attributes
        _name = name
    }
}