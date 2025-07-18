//
//  ImageService.swift
//  SOAPFT
//
//  Created by 바견규 on 7/19/25.
//



import Foundation
import Moya
import PhotosUI

final class ImageService {
    private let provider = MoyaProvider<ImageAPI>()

    // 이미지 업로드
    func uploadImage(image: UIImage, completion: @escaping (Result<ImageUploadResponse, Error>) -> Void) {
            guard let jpegData = image.jpegData(compressionQuality: 0.9) else {
                completion(.failure(NSError(domain: "ImageService", code: -1, userInfo: [NSLocalizedDescriptionKey: "이미지를 JPEG로 변환할 수 없습니다."])))
                return
            }

            provider.request(.uploadImage(imageData: jpegData)) { result in
                self.handleResponse(result, type: ImageUploadResponse.self, completion: completion)
            }
        }


    // 이미지 삭제
    func deleteImage(imageURL: String, completion: @escaping (Result<ImageDeleteResponse, Error>) -> Void) {
        provider.request(.deleteImage(imageURL: imageURL)) { result in
            self.handleResponse(result, type: ImageDeleteResponse.self, completion: completion)
        }
    }

    // 공통 응답 처리
    private func handleResponse<T: Decodable>(
        _ result: Result<Moya.Response, MoyaError>,
        type: T.Type,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        switch result {
        case .success(let response):
            do {
                let decoded = try JSONDecoder().decode(T.self, from: response.data)
                completion(.success(decoded))
            } catch {
                print("📦 Raw JSON Response:\n" + (String(data: response.data, encoding: .utf8) ?? "nil"))
                completion(.failure(error))
            }
        case .failure(let error):
            completion(.failure(error))
        }
    }
}
