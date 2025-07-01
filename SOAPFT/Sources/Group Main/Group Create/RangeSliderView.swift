//
//  RangeSliderView.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/1/25.
//

import SwiftUI

struct RangeSliderView: View {
    @Binding var selection: ClosedRange<CGFloat>
    var range: ClosedRange<CGFloat>
    var minimumDistance: CGFloat = 0
    var tint: Color = .primary
    var snapToMultiple: CGFloat = 10 // 10의 배수로 스냅
    
    /// View Properties
    @State private var slider1: GestureProperties = .init()
    @State private var slider2: GestureProperties = .init()
    @State private var indicatorWidth: CGFloat = 0
    @State private var isInitial: Bool = false
    var body: some View {
        GeometryReader { reader in
            let maxSliderWidth = reader.size.width - 30 // 30은 양쪽 슬라이더의 total width
            let minmunDistance = minimumDistance == 0 ? 0 : (minimumDistance / (range.upperBound - range.lowerBound)) * maxSliderWidth
            
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(tint.tertiary)
                    .frame(height: 5)
                
                /// Sliders
                HStack(spacing: 0) {
                    Circle()
                        .fill(tint)
                        .frame(width: 15, height: 15)
                        .contentShape(.rect)
                        .overlay(alignment: .leading) {
                            Rectangle()
                                .fill(tint)
                                .frame(width: indicatorWidth, height: 5)
                                .offset(x: 15)
                                .allowsHitTesting(false)
                        }
                        .offset(x: slider1.offset)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    /// Calculating Offset
                                    var translation = value.translation.width + slider1.lastStoredOffset
                                    translation = min(max(translation, 0), slider2.offset - minmunDistance) // 2번째 슬라이더의 limit
                                    slider1.offset = translation
                                    
                                    calculateNewRange(reader.size)
                                }.onEnded { _ in
                                    /// 드래그 끝날 때 10의 배수로 스냅
                                    snapSlider1ToNearestMultiple(reader.size)
                                    slider1.lastStoredOffset = slider1.offset
                                }
                        )
                    
                    Circle()
                        .fill(tint)
                        .frame(width: 15, height: 15)
                        .contentShape(.rect)
                        .offset(x: slider2.offset)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    /// Calculating Offset
                                    var translation = value.translation.width + slider2.lastStoredOffset
                                    translation = min(max(translation, slider1.offset + minmunDistance), maxSliderWidth) // 2번째 슬라이더가 1번째 슬라이더에 접근하면 드래스 제한
                                    slider2.offset = translation

                                    calculateNewRange(reader.size)
                                }.onEnded { _ in
                                    /// Storing Previous Offset
                                    snapSlider2ToNearestMultiple(reader.size)
                                    slider2.lastStoredOffset = slider2.offset
                                }
                        )
                }
            }
            .frame(maxWidth: .infinity)
            .task {
                guard !isInitial else { return }
                isInitial = true
                try? await Task.sleep(for: .seconds(0))
                let maxWidth = reader.size.width - 30
                
                /// Converting Selection Range ino offset
                let start = selection.lowerBound.interpolate(inputRange: [range.lowerBound, range.upperBound], outputRange: [0, maxWidth])
                let end = selection.upperBound.interpolate(inputRange: [range.lowerBound, range.upperBound], outputRange: [0, maxWidth])
                
                slider1.offset = start
                slider1.lastStoredOffset = start
                
                slider2.offset = end
                slider2.lastStoredOffset = end
                
                calculateNewRange(reader.size)
            }
        }
        .frame(height: 20)
    }
    
    private func snapSlider1ToNearestMultiple(_ size: CGSize) {
        let maxWidth = size.width - 30
        let progress = slider1.offset / maxWidth
        let currentValue = range.lowerBound.interpolated(towards: range.upperBound, amount: progress)
        
        // 연령대 하한값: 해당 연령이 속한 연령대의 시작값 (예: 25세 → 20대)
        let snappedValue = floor(currentValue / snapToMultiple) * snapToMultiple
        let clampedValue = min(max(snappedValue, range.lowerBound), range.upperBound)
        
        // 스냅된 값을 다시 offset으로 변환
        let snappedOffset = clampedValue.interpolate(inputRange: [range.lowerBound, range.upperBound], outputRange: [0, maxWidth])
        
        // 최소 거리 제한 확인
        let minDistanceOffset = minimumDistance == 0 ? 0 : (minimumDistance / (range.upperBound - range.lowerBound)) * maxWidth
        let maxAllowedOffset = slider2.offset - minDistanceOffset
        
        slider1.offset = min(snappedOffset, maxAllowedOffset)
        calculateNewRange(size)
    }
    
    private func snapSlider2ToNearestMultiple(_ size: CGSize) {
        let maxWidth = size.width - 30
        let progress = slider2.offset / maxWidth
        let currentValue = range.lowerBound.interpolated(towards: range.upperBound, amount: progress)
        
        // 연령대 상한값: 해당 연령이 속한 연령대의 끝값 (예: 25세 → 20대, 30세 → 30대)
        let ageDecade = floor(currentValue / snapToMultiple) * snapToMultiple
        let snappedValue = ageDecade + (snapToMultiple - 1) // 20대면 29, 30대면 39
        let clampedValue = min(max(snappedValue, range.lowerBound), range.upperBound)
        
        // 스냅된 값을 다시 offset으로 변환
        let snappedOffset = clampedValue.interpolate(inputRange: [range.lowerBound, range.upperBound], outputRange: [0, maxWidth])
        
        // 최소 거리 제한 확인
        let minDistanceOffset = minimumDistance == 0 ? 0 : (minimumDistance / (range.upperBound - range.lowerBound)) * maxWidth
        let minAllowedOffset = slider1.offset + minDistanceOffset
        
        slider2.offset = max(snappedOffset, minAllowedOffset)
        calculateNewRange(size)
    }
    
    private func calculateNewRange(_ size: CGSize) {
        indicatorWidth = slider2.offset - slider1.offset
        
        let maxWidth = size.width - 30
        
        /// 새로운 범위 값 계산
        let startProgress = slider1.offset / maxWidth
        let endProgress = slider2.offset / maxWidth
        
        /// 상한과 하한 사이의 보간
        let newRangeStart = range.lowerBound.interpolated(towards: range.upperBound, amount: startProgress)
        let newRangeEnd = range.lowerBound.interpolated(towards: range.upperBound, amount: endProgress)
        
        /// Updating Selection
        selection = newRangeStart...newRangeEnd
    }
    
    private struct GestureProperties {
        var offset: CGFloat = 0
        var lastStoredOffset: CGFloat = 0
    }
}

/// Interpolation
extension CGFloat {
    func interpolate(inputRange: [CGFloat], outputRange: [CGFloat]) -> CGFloat {
        /// 초기 입력 범위보다 작은 값인 경우
        let x = self
        let length = inputRange.count - 1
        if x <= inputRange[0] { return outputRange[0] }
        
        for index in 1...length {
            let x1 = inputRange[index - 1]
            let x2 = inputRange[index]
            
            let y1 = outputRange[index - 1]
            let y2 = outputRange[index]
            
            /// 선형 보간 공식:  y1 + ((y2-y1) / (x2-x1)) * (x-x1)
            if x <= inputRange[index] {
                let y = y1 + ((y2-y1) / (x2-x1)) * (x-x1)
                return y
            }
        }
        
        /// 값이 최대 입력 범위를 초과하면
        return outputRange[length]
    }
}
