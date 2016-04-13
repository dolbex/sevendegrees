//
//  Match.swift
//  SceneKit Tutorial
//
//  Created by Gary Williams on 4/7/16.
//  Copyright © 2016 Gary Williams. All rights reserved.
//

import Foundation
import RealmSwift

class Match: Object {
    
    dynamic var id: String = ""
    dynamic var rank: Int = 0
    dynamic var map: String = ""
    dynamic var dnf: Bool = false
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
