//
//  ServiceAgreementView.swift
//  SOAPFT
//
//  Created by 홍지우 on 9/21/25.
//

import SwiftUI

struct ServiceAgreementView: View {
    @Environment(\.diContainer) private var container
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // 네비게이션 바
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18))
                        .foregroundColor(.black)
                }
                Spacer()
                Text("서비스 이용 약관")
                    .font(.headline)
                Spacer()
                Color.clear.frame(width: 24, height: 24)
            }
            .padding()
            .background(Color(.systemBackground))
            .overlay(Divider(), alignment: .bottom)
            
            // 본문
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    SectionView(title: "제1조 (목적)", text: "본 약관은 한땀한땀(이하 “앱”)이 제공하는 서비스의 이용조건 및 절차, 권리와 의무, 기타 필요한 사항을 규정함을 목적으로 합니다.")
                    
                    SectionView(title: "제2조 (용어 정의)", text:
                        """
                        1. “회원”이라 함은 본 약관에 동의하고 앱이 제공하는 서비스를 이용하는 자를 말합니다.
                        2. “서비스”라 함은 앱이 제공하는 모든 기능(소셜 로그인, 챌린지 참여, 커뮤니티, HealthKit 연동 등)을 의미합니다.
                        3. 그 외 용어는 관련 법령 및 서비스 안내에서 정하는 바에 따릅니다.
                        """
                    )
                    
                    SectionView(title: "제3조 (약관의 효력 및 변경)", text:
                        """
                        1. 본 약관은 앱 내 고지하거나 전자우편 등으로 공지함으로써 효력이 발생합니다.
                        2. 앱은 관련 법령을 위반하지 않는 범위에서 약관을 개정할 수 있으며, 변경 시 사전 공지 후 효력이 발생합니다.
                        """
                    )
                    
                    SectionView(title: "제4조 (회원 가입 및 이용 계약)", text:
                        """
                        1. 이용자는 앱이 정한 절차에 따라 회원가입을 신청하고, 앱이 이를 승낙함으로써 계약이 성립합니다.
                        2. 앱은 다음의 경우 회원가입 신청을 거절하거나 사후에 이용 계약을 해지할 수 있습니다.
                           - 타인의 명의·이메일을 도용한 경우
                           - 허위 정보를 기재한 경우
                           - 만 14세 미만 아동이 법정대리인 동의 없이 가입한 경우
                        """
                    )
                    
                    SectionView(title: "제5조 (서비스 제공 및 변경)", text:
                        """
                        1. 앱은 회원에게 다음과 같은 서비스를 제공합니다.
                           - 소셜 로그인 및 계정 관리
                           - 챌린지 및 커뮤니티 운영
                           - HealthKit 기반 데이터 기록 및 공유
                           - 푸시 알림 서비스
                        2. 앱은 서비스 내용 및 운영상, 기술상 필요에 따라 일부 또는 전부를 변경할 수 있습니다.
                        """
                    )
                    
                    SectionView(title: "제6조 (회원의 의무)", text:
                        """
                        회원은 다음 행위를 하여서는 안 됩니다.
                        1. 타인의 계정을 도용하거나 개인정보를 무단으로 사용하는 행위
                        2. 법령 위반, 공공질서 및 미풍양속을 해치는 행위
                        3. 앱이 제공하는 서비스를 영리 목적으로 무단 사용하는 행위
                        4. 허위 정보 게시, 타인 명예 훼손, 욕설·비방 행위
                        """
                    )
                    
                    SectionView(title: "제7조 (서비스 이용 제한 및 해지)", text:
                        """
                        1. 앱은 회원이 본 약관을 위반하는 경우 서비스 이용을 제한하거나 계약을 해지할 수 있습니다.
                        2. 회원은 언제든지 앱 내 탈퇴 기능을 통해 계약을 해지할 수 있습니다.
                        """
                    )
                    
                    SectionView(title: "제8조 (개인정보 보호)", text: "앱은 개인정보 보호법 등 관련 법령을 준수하며, 개인정보 처리에 관한 사항은 「개인정보처리방침」에 따릅니다.")
                    
                    SectionView(title: "제9조 (면책조항)", text:
                        """
                        1. 앱은 천재지변, 불가항력, 회원의 귀책사유로 인한 서비스 이용 장애에 대해 책임을 지지 않습니다.
                        2. 앱은 회원 상호 간의 분쟁에 개입하지 않으며, 이로 인한 손해에 대해서는 책임을 지지 않습니다.
                        """
                    )
                    
                    SectionView(title: "제10조 (준거법 및 관할)", text: "본 약관은 대한민국 법률에 따라 해석되며, 서비스 이용과 관련하여 분쟁이 발생한 경우 관할 법원은 민사소송법에 따릅니다.")
                }
                .padding(20)
            }
            .background(Color(.systemBackground))
        }
        .navigationBarHidden(true)
    }
}

private struct SectionView: View {
    let title: String
    let text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            Text(text)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Preview
struct TermsOfServiceView_Previews: PreviewProvider {
    static var previews: some View {
        ServiceAgreementView()
    }
}


#Preview {
    ServiceAgreementView()
}
