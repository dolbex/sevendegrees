//
//  Team.swift
//  SceneKit Tutorial
//
//  Created by Gary Williams on 4/13/16.
//  Copyright © 2016 Gary Williams. All rights reserved.
//

import Foundation
import RealmSwift

class Team: Object {
    
    // From the API
    dynamic var id: String = ""
    dynamic var teamId: Int = 0
    dynamic var rank: Int = 0
    dynamic var score: Int = 0
    
    override static func primaryKey() -> String? {
        return "id"
    }
}