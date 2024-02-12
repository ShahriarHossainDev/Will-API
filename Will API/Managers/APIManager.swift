//
//  APIManager.swift
//  Will API
//
//  Created by Shishir_Mac on 9/2/24.
//

import Foundation
import Alamofire

struct API_K {
    static let BaseURLStr = "https://jsonplaceholder.typicode.com/"
    static let postStr = "posts"
    static let commentStr = "comments"
}

// MARK: - APIManager
class APIManager {
    // user Posts Request
    func userPostsRequest(completion: @escaping (Result<[Posts], Error>) -> Void) {
        let postURL = API_K.BaseURLStr + API_K.postStr
        AF.request(postURL)
            .responseDecodable(of: [Posts].self) { response in
                switch response.result {
                case .success(let posts):
                    completion(.success(posts))
                    
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    // fetch Comments Request by post id
    func fetchCommentsRequest(postId: Int, completion: @escaping (Result<[Comments], Error>) -> Void) {
        let commentURL = API_K.BaseURLStr + API_K.postStr + "/\(postId)/" + API_K.commentStr
        AF.request(commentURL)
            .responseDecodable(of: [Comments].self) { response in
                switch response.result {
                case .success(let posts):
                    completion(.success(posts))
                    
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    // create Post
    func createPost(title: String, body: String, userId: Int, completion: @escaping (Result<Posts, Error>) -> Void) {
        let postURL = API_K.BaseURLStr + API_K.postStr
        
        let parameters: [String: Any] = [
            "title": title,
            "body": body,
            "userId": userId
        ]
        
        AF.request(postURL, method: .post,
                   parameters: parameters,
                   encoding: JSONEncoding.default,
                   headers: ["Content-type": "application/json; charset=UTF-8"])
            .responseDecodable(of: Posts.self) { response in
                switch response.result {
                case .success(let posts):
                    completion(.success(posts))
                    
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    // delete Post
    func deletePost(postId: Int, completion: @escaping (Result<Posts, Error>) -> Void) {
        let postUrl = API_K.BaseURLStr + API_K.postStr + "/\(postId)"
        
        AF.request(postUrl,
                   method: .delete,
                   headers: ["Content-type": "application/json; charset=UTF-8"])
            .responseDecodable(of: Posts.self) { response in
                switch response.result {
                case .success(let posts):
                    completion(.success(posts))
                    
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}
