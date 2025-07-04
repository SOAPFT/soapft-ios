//
//  PostModel.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/3/25.
//

import Foundation

struct PostModel: Identifiable, Decodable, Equatable {
    let id: String
    let title: String
    let content: String
    let imageUrl: [String]
    
    enum CodingKeys: String, CodingKey {
        case id = "postUuid"
        case title, content, imageUrl
    }
}

struct PostResponse: Decodable {
    let message: String
    let total: Int
    let page: Int
    let limit: Int
    let posts: [PostModel]
}
