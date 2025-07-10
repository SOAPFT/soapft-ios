//
//  CalendarModel.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/4/25.
//

import SwiftUI
import SwiftData

@Model
class CalendarModel {
    var date: Date
    var imageURL: String?
    
    init(date: Date, imageURL: String? = nil) {
        self.date = date
        self.imageURL = imageURL
    }
}
