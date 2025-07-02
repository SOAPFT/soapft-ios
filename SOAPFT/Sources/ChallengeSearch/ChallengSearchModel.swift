//
//  ChallengSearchModel.swift
//  SOAPFT
//
//  Created by 바견규 on 7/3/25.
//

import Foundation

struct ChallengSearchModel: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let startDate: String
    let endDate: String
    let challengeImageURL: String
}
