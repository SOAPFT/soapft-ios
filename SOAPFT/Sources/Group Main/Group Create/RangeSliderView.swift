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
            let sidePadding: CGFloat = 15 // 양쪽 슬라이더 반지름
            let maxSliderWidth = reader.size.width - sidePadding * 2 // 양쪽 패딩 빼중
            let minmunDistance = minimumDistance == 0 ? 0 : (minimumDistance / (range.upperBound - range.lowerBound)) * maxSliderWidth
            
            VStack {
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray)
                        .frame(width: maxSliderWidth, height: 5)
                        .offset(x: 0)
                    
                    // MARK: - 세로선 표시
                    ForEach(snapMarkers(maxWidth: maxSliderWidth, sidePadding: sidePadding), id: \.self) { offset in
                        Capsule()
                            .fill(Color.gray)
                            .frame(width: 5, height: 9)
                            .offset(x: offset - sidePadding)
                    }
                    
                    
                    /// Sliders
                    HStack(spacing: 0) {
                        Circle()
                            .fill(tint)
                            .frame(width: 15, height: 15)
                            .contentShape(.rect)
                            .offset(x: slider1.offset)
                            .overlay(alignment: .leading) {
                                Rectangle()
                                    .fill(tint)
                                    .frame(width: indicatorWidth, height: 5)
                                    .offset(x: slider1.offset)
                                    .allowsHitTesting(false)
                            }
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        /// Calculating Offset
                                        var translation = value.translation.width + slider1.lastStoredOffset
                                        translation = min(max(translation, 0), slider2.offset - minmunDistance) // 2번째 슬라이더의 limit
                                        slider1.offset = translation
                                        calculateNewRange(maxWidth: maxSliderWidth)
                                    }.onEnded { _ in
                                        /// 드래그 끝날 때 10의 배수로 스냅
                                        snapSlider1ToNearestMultiple(maxWidth: maxSliderWidth)
                                        slider1.lastStoredOffset = slider1.offset
                                    }
                            )
                        
                        Circle()
                            .fill(tint)
                            .frame(width: 15, height: 15)
                            .contentShape(.rect)
                            .offset(x: slider2.offset - sidePadding)
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        /// Calculating Offset
                                        var translation = value.translation.width + slider2.lastStoredOffset
                                        translation = min(max(translation, slider1.offset + minmunDistance), maxSliderWidth) // 2번째 슬라이더가 1번째 슬라이더에 접근하면 드래스 제한
                                        slider2.offset = translation
                                        
                                        calculateNewRange(maxWidth: maxSliderWidth)
                                    }.onEnded { _ in
                                        /// Storing Previous Offset
                                        snapSlider2ToNearestMultiple(maxWidth: maxSliderWidth)
                                        slider2.lastStoredOffset = slider2.offset
                                    }
                            )
                    }
                }
                .frame(maxWidth: .infinity)
                .task {
                    guard !isInitial else { return }
                    isInitial = true
                    
                    let lowerOffset = valueToOffset(value: selection.lowerBound, maxWidth: maxSliderWidth)
                    let upperOffset = valueToOffset(value: selection.upperBound, maxWidth: maxSliderWidth)
                    
                    slider1.offset = lowerOffset
                    slider1.lastStoredOffset = lowerOffset
                    
                    slider2.offset = upperOffset
                    slider2.lastStoredOffset = upperOffset
                    
                    calculateNewRange(maxWidth: maxSliderWidth)
                }
                
                Spacer().frame(height: 4)
                
                // MARK: - 범위값 표시
                HStack(spacing: 0) {
                    let labels = ["20-", "20", "30", "40", "50", "50+"]
                    
                    ForEach(labels.indices, id: \.self) { i in
                        Text(labels[i])
                            .font(Font.Pretend.pretendardRegular(size: 14))
                            .foregroundStyle(Color.gray)
                            .frame(width: maxSliderWidth / CGFloat(labels.count - 1), alignment: .center)
                    }
                }
                .frame(width: maxSliderWidth)
            }
            .frame(width: reader.size.width, height: 60)
        }
        .frame(height: 60)
    }
    
    private func snapSlider1ToNearestMultiple(maxWidth: CGFloat) {
        let value = offsetToValue(offset: slider1.offset, maxWidth: maxWidth)
        let snapped = floor(value / snapToMultiple) * snapToMultiple
        let snappedOffset = valueToOffset(value: snapped, maxWidth: maxWidth)
        
        let minDistanceOffset = minimumDistance == 0 ? 0 : (minimumDistance / (range.upperBound - range.lowerBound)) * maxWidth
        let maxAllowedOffset = slider2.offset - minDistanceOffset
        
        slider1.offset = min(snappedOffset, maxAllowedOffset)
        calculateNewRange(maxWidth: maxWidth)
    }
    
    private func snapSlider2ToNearestMultiple(maxWidth: CGFloat) {
        let value = offsetToValue(offset: slider2.offset, maxWidth: maxWidth)
        let snapped = floor(value / snapToMultiple) * snapToMultiple + (snapToMultiple - 1)
        let snappedOffset = valueToOffset(value: snapped, maxWidth: maxWidth)

        let minDistanceOffset = minimumDistance == 0 ? 0 : (minimumDistance / (range.upperBound - range.lowerBound)) * maxWidth
        let minAllowedOffset = slider1.offset + minDistanceOffset

        slider2.offset = max(snappedOffset, minAllowedOffset)
        calculateNewRange(maxWidth: maxWidth)
    }
    
    private func calculateNewRange(maxWidth: CGFloat) {
        indicatorWidth = slider2.offset - slider1.offset
        
        let lowerValue = offsetToValue(offset: slider1.offset, maxWidth: maxWidth)
        let upperValue = offsetToValue(offset: slider2.offset, maxWidth: maxWidth)
        
        /// Updating Selection
        selection = lowerValue...upperValue
    }
    
    private func valueToOffset(value: CGFloat, maxWidth: CGFloat) -> CGFloat {
        ((value - range.lowerBound) / (range.upperBound - range.lowerBound)) * maxWidth
    }
    
    private func offsetToValue(offset: CGFloat, maxWidth: CGFloat) -> CGFloat {
        range.lowerBound + (offset / maxWidth) * (range.upperBound - range.lowerBound)
    }
    
    private struct GestureProperties {
        var offset: CGFloat = 0
        var lastStoredOffset: CGFloat = 0
    }
    
    private func snapMarkers(maxWidth: CGFloat, sidePadding: CGFloat) -> [CGFloat] {
        stride(from: range.lowerBound, through: range.upperBound, by: snapToMultiple).map { value in
            valueToOffset(value: value, maxWidth: maxWidth) + sidePadding
        }
    }
    
    private func markerLabel(for index: Int) -> String {
        let base = Int(range.lowerBound) + (index * Int(snapToMultiple))
        if index == 0 {
            return "20-"
        } else if CGFloat(base) >= range.upperBound {
            return "50+"
        } else {
            return "\(base)"
        }
    }
}

/// Interpolation
//extension CGFloat {
//    func interpolate(inputRange: [CGFloat], outputRange: [CGFloat]) -> CGFloat {
//        /// 초기 입력 범위보다 작은 값인 경우
//        let x = self
//        let length = inputRange.count - 1
//        if x <= inputRange[0] { return outputRange[0] }
//        
//        for index in 1...length {
//            let x1 = inputRange[index - 1]
//            let x2 = inputRange[index]
//            
//            let y1 = outputRange[index - 1]
//            let y2 = outputRange[index]
//            
//            /// 선형 보간 공식:  y1 + ((y2-y1) / (x2-x1)) * (x-x1)
//            if x <= inputRange[index] {
//                let y = y1 + ((y2-y1) / (x2-x1)) * (x-x1)
//                return y
//            }
//        }
//        
//        /// 값이 최대 입력 범위를 초과하면
//        return outputRange[length]
//    }
//}

#Preview {
    RangeSliderPreview()
}

struct RangeSliderPreview: View {
    @State private var selection: ClosedRange<CGFloat> = 20...40

    var body: some View {
        RangeSliderView(
            selection: $selection,
            range: 10...60,
            minimumDistance: 0
        )
        .padding()
        .frame(height: 50)
    }
}
