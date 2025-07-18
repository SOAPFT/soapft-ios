//
//  ImageAPI.swift
//  SOAPFT
//
//  Created by 바견규 on 7/19/25.
//

import Foundation
import Moya

enum ImageAPI {
    case uploadImage(imageData: Data)
    case deleteImage(imageURL: String)
}
extension ImageAPI: TargetType {
    var baseURL: URL {
        guard let baseUrlString = Bundle.main.object(forInfoDictionaryKey: "API_URL") as? String,
              let url = URL(string: baseUrlString) else {
            fatalError("❌ API_URL not found or invalid in Info.plist")
        }
        return url
    }

    var path: String {
        switch self {
        case .uploadImage:
            return "/upload/image"
        case .deleteImage(let imageURL):
            return "/upload/image/\(imageURL)"
        }
    }

    var method: Moya.Method {
        switch self {
        case .uploadImage:
            return .post
        case .deleteImage:
            return .delete
        }
    }

    var sampleData: Data {
        return Data()
    }

    var task: Task {
            switch self {
            case let .uploadImage(imageData):
                let formData = MultipartFormData(
                    provider: .data(imageData),
                    name: "file",
                    fileName: "upload.jpeg",
                    mimeType: "image/jpeg"
                )
                return .uploadMultipart([formData])

            case .deleteImage:
                return .requestPlain
            }
        }

    var headers: [String : String]? {
        var headers: [String: String] = [
            "Accept-Language": "ko-KR,ko;q=0.9,en-US;q=0.8,en;q=0.7",
            "accept": "application/json"
        ]

        if let accessToken = KeyChainManager.shared.readAccessToken() {
            headers["Authorization"] = "Bearer \(accessToken)"
        } else {
            print("❌ accessToken 없음: 인증이 필요한 요청입니다.")
        }

        return headers
    }
}
