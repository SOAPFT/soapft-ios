//
//  ChatRoomNavBar.swift
//  SOAPFT
//
//  Created by 바견규 on 6/29/25.
//

import SwiftUI

struct homeNavBar: View {
    //DIContainer
    @Environment(\.diContainer) private var container
    @StateObject private var viewModel: MyPageViewModel
    
    init(viewModel: MyPageViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image("logoSmall")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 32)
                    .padding(.leading, 8)
                    .padding(.bottom, 4)
                
                Spacer()
                
                Button(action: {
                    container.router.push(.alert)
                }) {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "bell")
                            .foregroundStyle(Color.black)
                            .font(.system(size: 18))

                        if viewModel.notificationCount > 0 {
                            Text("\(viewModel.notificationCount)")
                                .font(.caption2)
                                .foregroundStyle(.white)
                                .padding(5)
                                .background(Color.red)
                                .clipShape(Circle())
                                .offset(x: 8, y: -8)
                        }
                    }
                }
                
                Button(action: {container.router.push(.ChallengeSearchWrapper)}) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.black)
                        .font(.system(size: 18))
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 20)
            
            Divider()
        }
        .onAppear {
            viewModel.fetchNotificationCount()
        }
    }
}

#Preview {
    
}
