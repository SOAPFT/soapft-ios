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
        message.sender.userUuid == currentUserUuid
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


struct ChatMessageView: View {
    let message: ChatMessage
    let currentUserUuid: String

    var isMe: Bool {
        message.sender.userUuid == currentUserUuid
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if isMe { Spacer() }



            if !isMe {
                //프로필 이미지
                AsyncImage(url: URL(string: message.sender.profileImage ?? "")) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFill()
                    } else {
                        Circle().fill(Color.gray.opacity(0.2))
                    }
                }
                .frame(width: 32, height: 32)
                .clipShape(Circle())
                //텍스트
                MessageText(message: message, currentUserUuid: currentUserUuid)
            }

            if isMe {
                //텍스트
                MessageText(message: message, currentUserUuid: currentUserUuid)
                
                //프로필 이미지
                AsyncImage(url: URL(string: message.sender.profileImage ?? "")) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFill()
                    } else {
                        Circle().fill(Color.gray.opacity(0.2))
                    }
                }
                .frame(width: 32, height: 32)
                .clipShape(Circle())
            }

            if !isMe { Spacer() }
        }
        .padding(.horizontal)
    }
}


#Preview {
}
