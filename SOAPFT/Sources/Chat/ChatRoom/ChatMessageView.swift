//
//  SwiftUIView.swift
//  SOAPFT
//
//  Created by 바견규 on 6/29/25.
//

import SwiftUI

struct MessageText: View {
    let message: ChatMessage
    let currentUserUuid: String

    var isMe: Bool {
        message.sender?.userUuid == currentUserUuid
    }

    var body: some View {
        VStack(alignment: isMe ? .trailing : .leading, spacing: 4) {
            // 본문 메시지
            Group {
                if message.type == "TEXT" {
                    Text(message.content)
                        .padding()
                        .background(isMe ? Color.orange01.opacity(0.2) : Color.gray.opacity(0.2))
                        .cornerRadius(12)
                } else if let imageUrl = message.imageUrl, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: 200)
                                .cornerRadius(12)
                        default:
                            Color.gray.opacity(0.2)
                                .frame(width: 200, height: 150)
                                .cornerRadius(12)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - 채팅 메시지 뷰
struct ChatMessageView: View {
    let message: ChatMessage
    let currentUserUuid: String
    
    var body: some View {
        // 시스템 메시지인 경우
        if message.type == "SYSTEM" {
            SystemMessageView(message: message)
        } else {
            // 일반 채팅 메시지
            HStack(alignment: .bottom, spacing: 8) {
                if message.isMyMessage {
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        HStack(spacing: 4) {
                            
                            Text(formatTimeToKST(message.createdAt))
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                        
                        Text(message.content)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(16, corners: [.topLeft, .topRight, .bottomLeft])
                            .textSelection(.enabled)
                    }
                    .frame(maxWidth: .infinity * 0.7, alignment: .trailing)
                } else {
                    VStack(alignment: .leading, spacing: 4) {
                        if let sender = message.sender {
                            Text(sender.nickname)
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.leading, 4)
                        }
                        
                        HStack(alignment: .bottom, spacing: 4) {
                            Text(message.content)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(16, corners: [.topLeft, .topRight, .bottomRight])
                                .textSelection(.enabled)
                            
                            Text(formatTimeToKST(message.createdAt))
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(maxWidth: .infinity * 0.7, alignment: .leading)
                    
                    Spacer()
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
}

// MARK: - 시스템 메시지 뷰
struct SystemMessageView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            Spacer()
            VStack(spacing: 4) {
                Text(message.content)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                
                Text(formatDateTimeToKST(message.createdAt))
                    .font(.caption2)
                    .foregroundColor(.gray.opacity(0.7))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }
    
}

#Preview {
}
