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
    
    // Items directly from the API
    dynamic var id: String = ""
    dynamic var rank: Int = 0
    dynamic var map: String = ""
    dynamic var isTeamGame: Bool = true
    dynamic var dnf: Bool = false
    dynamic var matchCompletedDate: NSDate?
    
    // Calculated values
    dynamic var didWin: Bool = false
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
