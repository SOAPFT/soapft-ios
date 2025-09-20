//
//  PrivacyPolicyView.swift
//  SOAPFT
//
//  Created by 홍지우 on 9/21/25.
//

import SwiftUI

/// 개인정보처리방침 화면 (SwiftUI)
/// - 접근성/가독성에 신경 쓴 구성
/// - iOS 15+ 기준
struct PrivacyPolicyView: View {
    @Environment(\.diContainer) private var container
    @Environment(\.dismiss) private var dismiss
    private let appliedDate = "2025년 9월 18일"

    var body: some View {
        VStack(spacing: 0) {
            // 커스텀 네비게이션 바
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18))
                        .foregroundColor(.black)
                }
                Spacer()
                Text("개인정보처리방침")
                    .font(.headline)
                Spacer()
                // 오른쪽 여백용
                Color.clear.frame(width: 24, height: 24)
            }
            .padding()
            .background(Color(.systemBackground))
            .overlay(Divider(), alignment: .bottom)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    intro
                    Divider()
                    
                    Group {
                        PolicySectionView(
                            title: "1. 개인정보 처리 목적",
                            systemImage: "target",
                            content: {
                                PolicyList(
                                    items: [
                                        "소셜 로그인(애플, 카카오, 네이버)을 통한 회원 인증",
                                        "그룹 챌린지 및 커뮤니티 운영",
                                        "HealthKit 데이터 기반 습관 관리 및 기록 제공",
                                        "사진 업로드 및 프로필 관리",
                                        "챌린지 내 사용자 간 경쟁 서비스 제공",
                                        "그룹 매칭 및 사용자 간 정보 공유",
                                        "푸시 알림을 통한 서비스 안내",
                                        "서비스 개선 및 고객 문의 응대"
                                    ]
                                )
                            }
                        )
                        
                        PolicySectionView(
                            title: "2. 처리하는 개인정보 항목",
                            systemImage: "person.text.rectangle",
                            content: {
                                VStack(alignment: .leading, spacing: 12) {
                                    PolicyBullet(title: "소셜 로그인 시 제공 정보", value: "이메일, 프로필(닉네임·사진), 나이, 성별")
                                    PolicyBullet(title: "기기 접근 권한", value: "HealthKit 데이터(걸음 수, 칼로리, 운동 거리 등), 카메라(사진 촬영 및 업로드)")
                                    PolicyBullet(title: "기기 정보", value: "푸시 토큰(APNS 토큰)")
                                    PolicyBullet(title: "서비스 이용 중 생성되는 정보", value: "챌린지 인증 사진, 채팅 메시지, 서비스 이용 기록")
                                }
                            }
                        )
                        
                        PolicySectionView(
                            title: "2-1. 다른 이용자와 공유되는 개인정보",
                            systemImage: "person.2",
                            content: {
                                VStack(alignment: .leading, spacing: 14) {
                                    Text("앱 내에서 다른 이용자와 공유되는 개인정보는 다음과 같습니다:")
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text("그룹 챌린지:")
                                            .font(.headline)
                                        PolicyList(items: [
                                            "프로필 정보: 닉네임, 프로필 사진, 나이, 성별 (그룹 참가 조건 확인용)",
                                            "인증 사진: 챌린지 수행 인증을 위해 업로드한 사진"
                                        ])
                                    }
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text("전체 챌린지:")
                                            .font(.headline)
                                        PolicyList(items: [
                                            "프로필 사진, 닉네임",
                                            "HealthKit 기반 운동 데이터: 칼로리, 거리, 걸음 수 (경쟁 순위 표시용)"
                                        ])
                                    }
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text("마이페이지:")
                                            .font(.headline)
                                        PolicyList(items: [
                                            "프로필 정보: 닉네임, 프로필 사진",
                                            "인증 게시글: 본인이 업로드한 인증 사진들"
                                        ])
                                    }
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text("채팅:")
                                            .font(.headline)
                                        PolicyList(items: [
                                            "프로필 정보: 닉네임, 프로필 사진"
                                        ])
                                    }
                                }
                            }
                        )
                        
                        PolicySectionView(
                            title: "3. 개인정보의 보유 및 이용 기간",
                            systemImage: "clock.arrow.circlepath",
                            content: {
                                PolicyList(items: [
                                    "회원 탈퇴 시 즉시 파기",
                                    "단, 법령에서 일정 기간 보관을 요구하는 경우 해당 기간 동안 보관"
                                ])
                            }
                        )
                        
                        PolicySectionView(
                            title: "4. 개인정보의 제3자 제공 여부",
                            systemImage: "lock.shield",
                            content: {
                                Text("앱은 원칙적으로 이용자의 개인정보를 외부에 제공하지 않습니다. 다만, 법령에 따라 요청이 있는 경우 예외로 합니다.")
                            }
                        )
                        
                        PolicySectionView(
                            title: "5. 개인정보 처리의 위탁",
                            systemImage: "shippingbox",
                            content: {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("앱은 서비스 운영을 위해 아래와 같이 위탁할 수 있습니다.")
                                    PolicyList(items: [
                                        "서버 및 데이터 보관: Amazon Web Services(AWS)",
                                        "푸시 알림 서비스: Apple Push Notification Service(APNS)"
                                    ])
                                    Text("위탁 시 관련 법령에 따라 개인정보가 안전하게 관리되도록 조치합니다.")
                                }
                            }
                        )
                    }
                    
                    Group {
                        PolicySectionView(
                            title: "6. 개인정보의 국외 이전",
                            systemImage: "globe.asia.australia",
                            content: {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("앱은 서비스 운영을 위하여 이용자의 개인정보를 국외로 이전합니다.")
                                    GroupBox {
                                        VStack(alignment: .leading, spacing: 6) {
                                            PolicyBullet(title: "APNS 관련 이전", value: nil)
                                            PolicyBullet(title: "이전 받는 자", value: "Apple Inc.")
                                            PolicyBullet(title: "이전 국가", value: "미국")
                                            PolicyBullet(title: "이전 일시 및 방법", value: "푸시 알림 발송 시 실시간 전송")
                                            PolicyBullet(title: "이전되는 항목", value: "푸시 토큰, 알림 내용")
                                            PolicyBullet(title: "이전 목적", value: "푸시 알림 서비스 제공")
                                            PolicyBullet(title: "보유 및 이용 기간", value: "앱 삭제 또는 알림 수신 거부 시까지")
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                            }
                        )
                        
                        PolicySectionView(
                            title: "7. 개인정보의 파기 절차 및 방법",
                            systemImage: "trash",
                            content: {
                                PolicyList(items: [
                                    "회원 탈퇴 시 개인정보를 즉시 파기합니다.",
                                    "전자적 파일 형태: 복원이 불가능한 방법으로 영구 삭제",
                                    "종이 문서 형태: 분쇄 또는 소각"
                                ])
                            }
                        )
                        
                        PolicySectionView(
                            title: "8. 이용자의 권리 및 행사 방법",
                            systemImage: "person.badge.key",
                            content: {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("이용자는 언제든지 자신의 개인정보 열람, 정정, 삭제, 처리정지를 요청할 수 있습니다.")
                                    PolicyList(items: [
                                        "앱 내 고객센터 또는 이메일을 통해 요청 가능",
                                        "푸시 알림은 기기 설정에서 언제든지 수신을 거부할 수 있습니다.",
                                        "다른 이용자와의 정보 공유를 원하지 않는 경우 해당 서비스 이용을 중단할 수 있습니다.",
                                        "본 앱은 만 14세 미만 아동을 대상으로 하지 않습니다."
                                    ])
                                }
                            }
                        )
                        
                        PolicySectionView(
                            title: "9. 개인정보 보호 책임자 및 연락처",
                            systemImage: "envelope",
                            content: {
                                VStack(alignment: .leading, spacing: 8) {
                                    PolicyBullet(title: "이름", value: "박현규")
                                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                                        Text("이메일:")
                                            .fontWeight(.semibold)
                                        if let url = URL(string: "mailto:hyeongyu2002@gmail.com") {
                                            Link("hyeongyu2002@gmail.com", destination: url)
                                        } else {
                                            Text("hyeongyu2002@gmail.com")
                                        }
                                    }
                                    Text("연락처: (이메일로 문의 바랍니다)")
                                }
                            }
                        )
                        
                        PolicySectionView(
                            title: "10. 고지의 의무",
                            systemImage: "megaphone",
                            content: {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("본 개인정보처리방침은 \(appliedDate)부터 적용됩니다. 변경 시 앱 내 공지를 통해 안내합니다.")
                                }
                            }
                        )
                    }
                }
                .padding(20)
            }
            .background(Color(.systemBackground))
        }
        .navigationBarHidden(true)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("📄 개인정보처리방침")
                .font(.title)
                .fontWeight(.bold)
            Text("한땀한땀(이하 \"앱\")은 이용자의 개인정보를 소중히 여기며, 「개인정보 보호법」 등 관련 법령을 준수합니다. 본 방침은 앱에서 처리하는 개인정보 항목, 이용 목적, 보관 기간 등을 안내합니다.")
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var intro: some View {
        GroupBox {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "info.circle")
                    .imageScale(.large)
                Text("본 문서는 서비스 이용 중 수집/이용되는 정보 및 이용자 권리에 대해 설명합니다. 각 항목을 펼쳐 상세 내용을 확인할 수 있습니다.")
            }
        }
    }
}

// MARK: - Subviews

struct PolicySectionView<Content: View>: View {
    let title: String
    let systemImage: String
    @ViewBuilder var content: Content

    @State private var expanded: Bool = true

    var body: some View {
        DisclosureGroup(isExpanded: $expanded) {
            VStack(alignment: .leading, spacing: 12) {
                content
            }
            .padding(.top, 8)
        } label: {
            HStack(spacing: 10) {
                Image(systemName: systemImage)
                    .frame(width: 20)
                Text(title)
                    .font(.headline)
            }
            .accessibilityElement(children: .combine)
        }
        .padding(16)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.secondary.opacity(0.15), lineWidth: 1)
        )
        .tint(Color.orange01)
    }
}

struct PolicyList: View {
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(items.indices, id: \.self) { idx in
                HStack(alignment: .top, spacing: 8) {
                    Text("•")
                    Text(items[idx])
                        .fixedSize(horizontal: false, vertical: true)
                }
                .accessibilityElement(children: .combine)
            }
        }
    }
}

struct PolicyBullet: View {
    let title: String
    let value: String?

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text("\(title):")
                .fontWeight(.semibold)
            if let value { Text(value) }
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

// MARK: - Preview
struct PrivacyPolicyView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView { PrivacyPolicyView() }
            .preferredColorScheme(.light)
        NavigationView { PrivacyPolicyView() }
            .preferredColorScheme(.dark)
    }
}


#Preview {
    PrivacyPolicyView()
}
