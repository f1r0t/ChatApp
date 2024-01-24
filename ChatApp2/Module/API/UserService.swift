//
//  UserService.swift
//  ChatApp2
//
//  Created by Fırat AKBULUT on 11.01.2024.
//

import Foundation
import Firebase

struct UserService{
    
    static func fetchUser(uid: String, completion: @escaping(User)->Void){
        COLLECTION_USER.document(uid).getDocument { snapshot, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let dictionary = snapshot?.data() else{return}
            let user = User(dictionary: dictionary)
            completion(user)
        }
    }
    
    static func fetchUsers(completion: @escaping([User])->Void){
        COLLECTION_USER.getDocuments { snapshot, error in
            guard let snapshot = snapshot else{return}
            let users = snapshot.documents.map({User(dictionary: $0.data())})
            completion(users)
        }
    }
    
    static func setNewUserData(data: [String: Any], completion: @escaping(Error?)->Void){
        guard let uid = Auth.auth().currentUser?.uid else{return}
        
        COLLECTION_USER.document(uid).updateData(data, completion: completion)
    }
}
