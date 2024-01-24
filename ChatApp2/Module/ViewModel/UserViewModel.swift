//
//  UserViewModel.swift
//  ChatApp2
//
//  Created by Fırat AKBULUT on 12.01.2024.
//

import UIKit

struct UserViewModel{
    
    let user: User
    
    var fullname: String {return user.fullname}
    var username: String {return user.username}

    var profileImageURL: URL?{
        return URL(string: user.profileImageURL)
    }
    
    init(user: User) {
        self.user = user
    }
}

