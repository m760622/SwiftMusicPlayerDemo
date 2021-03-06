//
//  Music.swift
//  Rodeo
//
//  Created by Admin on 17/04/18.
//  Copyright © 2018 AstroWorld. All rights reserved.
//

import Foundation
import FirebaseDatabase
import SwiftyJSON

class Music: NSObject {
    
    var name: String = ""
    var songURL: URL? = nil
    var coverImage: URL? = nil
    var artistName: String = ""
    var key: String = ""
    
    convenience init(snapshot: DataSnapshot) {
        
        self.init()
        
        let data = JSON(snapshot.value!)
        
        self.name = data["name"].stringValue
        self.songURL = URL(string: data["song"].stringValue)
        self.coverImage = URL(string: data["cover"].stringValue)
        self.artistName = data["artist"].stringValue
        self.key = snapshot.key
        
    }
    
}
