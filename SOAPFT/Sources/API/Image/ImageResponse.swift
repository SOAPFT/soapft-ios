//
//  ImageResponse.swift
//  SOAPFT
//
//  Created by 바견규 on 7/19/25.
//

struct ImageUploadResponse: Decodable {
    let imageUrl: String
    let message: String
//    let fileName: String
//    let fileSize: Int
//    let uploadedAt: String
}
struct ImageDeleteResponse: Decodable {
    let message: String
    let deletedUrl: String
    let deletedAt: String
}
