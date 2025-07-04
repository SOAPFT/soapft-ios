//
//  DIContainer.swift
//  SOAPFT
//
//  Created by 바견규 on 7/5/25.
//

import SwiftUI

final class DIContainer {
    let router: AppRouter
    
    // ...기타 서비스들

    init(router: AppRouter/*, postService: PostService, authService: AuthService*/) {
        self.router = router
    }
}
