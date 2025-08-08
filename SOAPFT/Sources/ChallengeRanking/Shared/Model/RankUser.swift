//
//  RankUser.swift
//  SOAPFT
//
//  Created by 바견규 on 8/7/25.
//

import Foundation

// 모델
public struct RankUser: Codable, Identifiable, Equatable {
    public let id: UUID
    public var rank: Int
    public let name: String
    public let image: String
    public let score: Int

    public init(rank: Int, name: String, image: String, score: Int) {
        self.id = UUID()
        self.rank = rank
        self.name = name
        self.image = image
        self.score = score
    }
}

//애플워치용 데이터 경량화
public struct RankUserDTO: Codable, Equatable {
    public let name: String
    public let rank: Int
    public let score: Int

    public init(name: String, rank: Int, score: Int) {
        self.name = name
        self.rank = rank
        self.score = score
    }
}
