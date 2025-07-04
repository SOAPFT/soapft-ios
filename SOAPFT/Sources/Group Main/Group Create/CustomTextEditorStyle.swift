//
//  CustomTextEditorStyle.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/1/25.
//

import SwiftUI

struct CustomTextEditorStyle: ViewModifier {
    let placeholder: String
    @Binding var text: String // 글자 수 받기 위해 @Binding 사용
    let showCount: Bool
    
    func body(content: Content) -> some View {
        content
            .padding(6)
            .background(alignment: .topLeading) {
                if text.isEmpty {
                    Text(placeholder)
                        .lineSpacing(8)
                        .padding(12)
                        .padding(.top, 2)
                        .font(Font.Pretend.pretendardLight(size: 14))
                        .foregroundStyle(Color(UIColor.systemGray2))
                }
            }
            .autocorrectionDisabled()
            .background(Color(UIColor.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .scrollContentBackground(.hidden)
            .font(Font.Pretend.pretendardLight(size: 14))
            .modifier(ConditionalOverlay(show: showCount, text: $text))
    }
}

struct ConditionalOverlay: ViewModifier {
    let show: Bool
    @Binding var text: String
    
    func body(content: Content)
    -> some View {
        if show {
            content.overlay(alignment: .bottomTrailing) {
                Text("\(text.count) / 500")
                    .font(Font.Pretend.pretendardLight(size: 12))
                    .foregroundStyle(Color(UIColor.systemGray2))
                    .padding(.trailing, 15)
                    .padding(.bottom, 15)
                    .onChange(of: text) {
                        if text.count > 500 {
                            text = String(text.prefix(500))
                        }
                    }
            }
        } else {
            content
        }
    }
}

extension TextEditor {
    func customStyleEditor(
        placeholder: String,
        userInput: Binding<String>,
        showCount: Bool = true
    ) -> some View {
        self.modifier(CustomTextEditorStyle(
            placeholder: placeholder,
            text: userInput,
            showCount: showCount
        ))
    }
}
