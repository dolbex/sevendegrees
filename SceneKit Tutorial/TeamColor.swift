//
//  TeamColor.swift
//  SceneKit Tutorial
//
//  Created by Gary Williams on 4/13/16.
//  Copyright © 2016 Gary Williams. All rights reserved.
//

/*
 {
 // A localized name, suitable for display to users.
 "name": "string",
 
 // A localized description, suitable for display to users.
 "description": "string",
 
 // A seven-character string representing the team color in "RGB Hex" notation. This
 // notation uses a "#" followed by a hex triplet.
 "color": "string",
 
 // A reference to an image for icon use. This may be null if there is no image
 // defined.
 "iconUrl": "string",
 
 // The ID that uniquely identifies this color. This will be the same as the team's ID
 // in responses from the Stats API.
 "id": "int",
 
 // Internal use only. Do not use.
 "contentId": "guid"
 }
 */


import Foundation
import RealmSwift

class TeamColor: Object {
    
    // From the API
    dynamic var id: Int = 0
    dynamic var name: String = ""
    dynamic var color: String = ""
    dynamic var iconUrl: String = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
}