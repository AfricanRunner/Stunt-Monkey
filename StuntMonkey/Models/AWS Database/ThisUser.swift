//
//  ThisUser.swift
//  StuntMonkey
//
//  Created by Daniël du Preez on 4/15/21.
//

import Foundation

struct ThisUser {
    let email: String
    var name: String
    
    init(email: String, name: String) {
        self.email = email
        self.name = name
    }
    
    init(listUser: ListUsersQuery.Data.ListUser) {
        self.email = listUser.email
        self.name = listUser.name
    }
    
    init(createUser: CreateUserMutation.Data.CreateUser) {
        self.email = createUser.email
        self.name = createUser.name
    }
    
    func createUserInput() -> CreateUserInput {
        return CreateUserInput(email: email, name: name)
    }
}
