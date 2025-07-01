import Foundation
import SwiftUI

@Observable
class GroupMainViewModel {
    
    var Hot = [
        GroupMainModel(imageName:"팀예시", title: "블라블라"),
        GroupMainModel(imageName:"팀예시", title: "블라블라"),
        GroupMainModel(imageName:"팀예시", title: "블라블라"),
        GroupMainModel(imageName:"팀예시", title: "블라블라"),
        GroupMainModel(imageName:"팀예시", title: "블라블라")
    ]
    
    var Recent = [
        GroupMainModel(imageName:"팀예시", title: "블라블라"),
        GroupMainModel(imageName:"팀예시", title: "블라블라"),
        GroupMainModel(imageName:"팀예시", title: "블라블라"),
        GroupMainModel(imageName:"팀예시", title: "블라블라"),
        GroupMainModel(imageName:"팀예시", title: "블라블라")
    ]
    
    enum ChallengeViewType {
        case hot
        case recent
        
        var title: String {
            switch self {
            case .hot:
                return "지금 인기있는 챌린지 🔥"
            case .recent:
                return "최근 개설된 챌린지 🌱"
            }
        }
    }
    
    func getChallenges(for type: ChallengeViewType) -> [GroupMainModel] {
        switch type {
        case .hot:
            return Hot
        case .recent:
            return Recent
        }
    }
}
