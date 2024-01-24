//
//  AuthService.swift
//  ChatApp2
//
//  Created by Fırat AKBULUT on 10.01.2024.
//

import FirebaseAuth
import UIKit
import Firebase

struct AuthCredential{
    let email: String
    let password: String
    let username: String
    let fullname: String
    let profileImage: UIImage
}

typealias AuthDataResultCallback = (AuthDataResult?, Error?) -> Void

struct AuthCredentialEmail{
    let email: String
    let uid: String
    let username: String
    let fullname: String
    let profileImage: UIImage
}

struct AuthService{
    
    
    static func loginUser(email: String, password: String, completion: @escaping(AuthDataResultCallback)){
        Auth.auth().signIn(withEmail: email, password: password, completion: completion)
    }
    
    static func registerUser(credential: AuthCredential, completion: @escaping(Error?)->Void){
        
        FileUploader.uploadImage(image: credential.profileImage) { imageURL in
            Auth.auth().createUser(withEmail: credential.email, password: credential.password) { result, error in
                if let error = error{
                    print(error.localizedDescription)
                    return
                }
                guard let uid = result?.user.uid else{return}
                
                let data: [String: Any] = [
                    "email": credential.email,
                    "username": credential.username,
                    "fullname": credential.fullname,
                    "uid": uid,
                    "profileImageURL": imageURL
                ]
                COLLECTION_USER.document(uid).setData(data, completion: completion)
            }
        }
    }
    
    static func registerWithGoogle(credential: AuthCredentialEmail, completion: @escaping(Error?)->Void){
        FileUploader.uploadImage(image: credential.profileImage) { imageURL in
            let data: [String: Any] = [
                "email": credential.email,
                "username": credential.username,
                "fullname": credential.fullname,
                "uid": credential.uid,
                "profileImageURL": imageURL
            ]
            
            COLLECTION_USER.document(credential.uid).setData(data, completion: completion)
        }
    }
}
