//
//  formatTimeToKST.swift
//  SOAPFT
//
//  Created by 바견규 on 9/13/25.
//

import SwiftUI

func formatTimeToKST(_ dateString: String) -> String {
    let formatter = ISO8601DateFormatter()
    var date: Date?
    
    if let parsedDate = formatter.date(from: dateString) {
        date = parsedDate
    } else {
        // ISO8601 파싱 실패 시 다른 포맷들 시도
        let fallbackFormatter = DateFormatter()
        
        // 서버에서 올 수 있는 다양한 포맷들
        let possibleFormats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
            "yyyy-MM-dd'T'HH:mm:ss'Z'",
            "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        ]
        
        for format in possibleFormats {
            fallbackFormatter.dateFormat = format
            fallbackFormatter.timeZone = TimeZone(abbreviation: "UTC") // UTC로 파싱
            if let parsedDate = fallbackFormatter.date(from: dateString) {
                date = parsedDate
                break
            }
        }
    }
    
    guard let finalDate = date else {
        print("날짜 파싱 실패: \(dateString)")
        return dateString
    }
    
    // 한국 시간대로 변환
    let kstTimeZone = TimeZone(identifier: "Asia/Seoul")!
    var kstCalendar = Calendar.current
    kstCalendar.timeZone = kstTimeZone
    
    let kstNow = Date() // 현재 시간도 KST 기준으로 비교
    
    // 한국 시간 기준으로 날짜 포맷터 설정
    let kstFormatter = DateFormatter()
    kstFormatter.timeZone = kstTimeZone
    
    // 오늘인지 확인 (KST 기준)
    if kstCalendar.isDate(finalDate, inSameDayAs: kstNow) {
        kstFormatter.dateFormat = "HH:mm"
        return kstFormatter.string(from: finalDate)
    }
    
    // 어제인지 확인 (KST 기준)
    if let yesterday = kstCalendar.date(byAdding: .day, value: -1, to: kstNow),
       kstCalendar.isDate(finalDate, inSameDayAs: yesterday) {
        kstFormatter.dateFormat = "HH:mm"
        return "어제 \(kstFormatter.string(from: finalDate))"
    }
    
    // 올해인지 확인 (KST 기준)
    if kstCalendar.component(.year, from: finalDate) == kstCalendar.component(.year, from: kstNow) {
        kstFormatter.dateFormat = "M/d HH:mm"
        return kstFormatter.string(from: finalDate)
    }
    
    // 다른 해 (KST 기준)
    kstFormatter.dateFormat = "yyyy/M/d HH:mm"
    return kstFormatter.string(from: finalDate)
}

