//
//  LoginViewModel.swift
//  ChatApp2
//
//  Created by Fırat AKBULUT on 10.01.2024.
//

import UIKit

protocol AuthLoginModel{
    var formIsFailed: Bool {get}
    var backgroundColor: UIColor{get}
    var buttonTitleColor: UIColor{get}
}

struct LoginViewModel: AuthLoginModel{
    
    var email: String?
    var password: String?
    
    var formIsFailed: Bool{
        return email?.isEmpty == false && password?.isEmpty == false
    }
    
    var backgroundColor: UIColor{
        return formIsFailed ? (UIColor.black) : (UIColor.black.withAlphaComponent(0.5))
    }
    
    var buttonTitleColor: UIColor{
        return formIsFailed ? (UIColor.white) : (UIColor.white.withAlphaComponent(0.7))
    }
}

struct RegisterViewModel: AuthLoginModel{
    var email: String?
    var password: String?
    var fullname: String?
    var username: String?
    
    var formIsFailed: Bool{
        return email?.isEmpty == false && password?.isEmpty == false && fullname?.isEmpty == false && username?.isEmpty == false
    }
    
    var backgroundColor: UIColor{
        return formIsFailed ? (UIColor.black) : (UIColor.black.withAlphaComponent(0.5))
    }
    
    var buttonTitleColor: UIColor{
        return formIsFailed ? (UIColor.white) : (UIColor.white.withAlphaComponent(0.7))
    }

}
