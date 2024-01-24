//
//  MessageService.swift
//  ChatApp2
//
//  Created by Fırat AKBULUT on 12.01.2024.
//

import Foundation
import Firebase

struct MessageService{
    
    static func fetchMessages(otherUser: User, completion: @escaping([Message])->Void){
        guard let uid = Auth.auth().currentUser?.uid else{return}
        
        var messages = [Message]()
        let query = COLLECTION_MESSAGE.document(uid).collection(otherUser.uid).order(by: "timestamp")
        
        query.addSnapshotListener { snapshot, _ in
            guard let documentChanges = snapshot?.documentChanges.filter({$0.type == .added}) else {return}
            messages.append(contentsOf: documentChanges.map({Message(dictionary: $0.document.data())}))
            completion(messages)
        }
    }
    
    static func fetchRecentMessages(completion: @escaping([Message])->Void){
        guard let uid = Auth.auth().currentUser?.uid else{return}
        
        let query = COLLECTION_MESSAGE.document(uid).collection("recent-message").order(by: "timestamp", descending: true)
        
        query.addSnapshotListener { snapshot, _ in
            guard let documentChanges = snapshot?.documentChanges else {return}
            let messages = documentChanges.map({Message(dictionary: $0.document.data())})
            completion(messages)
        }
    }
    
    static func uploadMessages(message: String = "", imageURL: String = "", videoURL: String = "", audioURL: String = "", locationURL: String = "", currentUser: User, otherUser: User, unReadCount: Int, completion: ((Error?)->Void)?){
        let dataFrom: [String: Any] = [
            "text": message,
            "fromID": currentUser.uid,
            "toID": otherUser.uid,
            "timestamp": Timestamp(date: Date()),
            
            "username": otherUser.username,
            "fullname": otherUser.fullname,
            "profileImageURL": otherUser.profileImageURL,
            
            "newMessage": 0,
            "imageURL": imageURL,
            "videoURL": videoURL,
            "audioURL": audioURL,
            "locationURL": locationURL
        ]
        
        let dataTo: [String: Any] = [
            "text": message,
            "fromID": currentUser.uid,
            "toID": otherUser.uid,
            "timestamp": Timestamp(date: Date()),
            
            "username": currentUser.username,
            "fullname": currentUser.fullname,
            "profileImageURL": currentUser.profileImageURL,
            
            "newMessage": unReadCount,
            "imageURL": imageURL,
            "videoURL": videoURL,
            "audioURL": audioURL,
            "locationURL": locationURL
            
        ]
        
        COLLECTION_MESSAGE.document(currentUser.uid).collection(otherUser.uid).addDocument(data: dataFrom) { _ in
            COLLECTION_MESSAGE.document(otherUser.uid).collection(currentUser.uid).addDocument(data: dataTo, completion: completion)
            COLLECTION_MESSAGE.document(currentUser.uid).collection("recent-message").document(otherUser.uid).setData(dataFrom)
            COLLECTION_MESSAGE.document(otherUser.uid).collection("recent-message").document(currentUser.uid).setData(dataTo)
        }
    }
    
    static func fetchSingleRecentMessage(otherUser: User, completion: @escaping(Int)->Void){
        guard let uid = Auth.auth().currentUser?.uid else{return}
        
        COLLECTION_MESSAGE.document(otherUser.uid).collection("recent-message").document(uid).getDocument { snapshot, _ in
            guard let data = snapshot?.data() else{
                completion(0)
                return
            }
            
            let message = Message(dictionary: data)
            completion(message.newMessage)
        }
    }
    
    static func markReadAllMessage(otherUser: User){
        guard let uid = Auth.auth().currentUser?.uid else{return}
        
        let dataUpdate: [String: Any] = [
            "newMessage": 0
        ]
        
        COLLECTION_MESSAGE.document(uid).collection("recent-message").document(otherUser.uid).updateData(dataUpdate)
    }
    
    static func deleteMessages(otherUser: String, completion: @escaping(Error?)->Void){
        guard let uid = Auth.auth().currentUser?.uid else{return}
        
        //TODO: - Get all conversations
        COLLECTION_MESSAGE.document(uid).collection(otherUser).getDocuments { snapshot, _ in
            //TODO: - Delete all conversations
            snapshot?.documents.forEach({ document in
                let documentID = document.documentID
                COLLECTION_MESSAGE.document(uid).collection(otherUser).document(documentID).delete()
            })
            //TODO: - Delete recent message
            let ref = COLLECTION_MESSAGE.document(uid).collection("recent-message").document(otherUser)
            ref.delete(completion: completion)
        }
    }
}
