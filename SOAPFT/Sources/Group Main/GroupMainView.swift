import SwiftUI

struct GroupMainView: View {
    @State private var GroupMainViewModel: GroupMainViewModel = .init()
    
    var body: some View {
        VStack {
            HStack {
                // 로고
                
                Spacer()
                
                Button(action: {
                    
                }, label: {
                    Image(systemName: "bell")
                        .foregroundStyle(Color.black)
                })
                
                Button(action: {
                    
                }, label: {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(Color.black)
                })
            }
            .padding(.bottom, 8)
            .padding(.horizontal, 12)
            
            ScrollView {
                Spacer()
                
                // 광고 배너
                
                NewChallenge // 새로운 챌린지 만들기 버튼
                
                WholeChallenge
                
                HotChallenge // 지금 인기 있는 챌린지
                
                RecentChallenge // 최근 개설된 챌린지
            }
            .padding(.horizontal, 12)
        }
    }
    
    private var NewChallenge: some View {
        HStack {
            Text("새로운 챌린지 만들기")
                .font(.caption2)
            
            Spacer()
            
            Button(action: {
                print("new challenge")
            }, label: {
                Image(systemName: "plus.circle.fill")
                    .foregroundStyle(Color.black)
            })
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(Color.black, lineWidth: 0.8)
                .background(Color.clear)
        )
        .frame(maxWidth: .infinity)
    }
    
    private var WholeChallenge: some View {
        VStack {
            Text("지금 새로운 챌린지가 열렸습니다!")
                .font(.caption)
            
            Spacer()
            
            Button(action: {
                print("지금 참여하기")
            }, label: {
                ZStack {
                    Rectangle()
                        .foregroundStyle(Color.orange01)
                        .frame(width: 100, height: 25)
                        .cornerRadius(8)
                        
                    Text("지금 참여하기")
                        .font(.caption2)
                        .foregroundStyle(Color.white)
                }
            })
        }
        .padding(.horizontal)
        .padding(.vertical)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(Color.black, lineWidth: 0.8)
                .background(Color.clear)
        )
        .frame(maxWidth: .infinity)
    }
    
    private var HotChallenge: some View {
        VStack {
            HStack {
                Text("지금 인기 있는 챌린지 🔥")
                    .font(.caption)
                
                Spacer()
                
                Button(action: {
                    print("더보기")
                }, label: {
                    HStack {
                        Text("더보기")
                            .font(.caption2)
                            .foregroundStyle(Color.gray)
                        Image(systemName: "chevron.right")
                            .resizable()
                            .frame(width: 6, height: 6)
                            .foregroundStyle(Color.gray)
                    }
                })
            }
            
            ScrollView (.horizontal) {
                LazyHStack (spacing: 17) {
                    ForEach(GroupMainViewModel.Hot, id: \.self) { challenge in
                        ChallengeCard(Name: challenge.imageName, Title: challenge.title)
                    }
                }
            }
        }
    }
    
    private func ChallengeCard(Name: String, Title: String) -> some View {
        VStack {
            Image(Name)
                .resizable()
                .frame(width: 80, height: 80)
            
            Text(Title)
                .font(.caption2)
        }
    }
    
    private var RecentChallenge: some View {
        VStack {
            HStack {
                Text("최근 개설된 챌린지 🌱")
                    .font(.caption)
                
                Spacer()
                
                Button(action: {
                    print("더보기")
                }, label: {
                    HStack {
                        Text("더보기")
                            .font(.caption2)
                            .foregroundStyle(Color.gray)
                        Image(systemName: "chevron.right")
                            .resizable()
                            .frame(width: 6, height: 6)
                            .foregroundStyle(Color.gray)
                    }
                })
            }
            
            ScrollView (.horizontal) {
                LazyHStack (spacing: 17) {
                    ForEach(GroupMainViewModel.Recent, id: \.self) { challenge in
                        ChallengeCard(Name: challenge.imageName, Title: challenge.title)
                    }
                }
            }
        }
    }
}

#Preview {
    GroupMainView()
}
