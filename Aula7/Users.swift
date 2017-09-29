//
//  Users.swift
//  Aula7
//
//  Created by HC5MAC11 on 28/09/17.
//  Copyright © 2017 Lucas. All rights reserved.
//

import CoreData

class Users: NSManagedObject {
    
    
    func preencherDados(name: String, username: String) {
        self.name = name
        self.username = username
    }

}
