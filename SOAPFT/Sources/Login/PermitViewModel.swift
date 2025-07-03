//
//  PermitViewModel.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/3/25.
//

import Foundation
import Combine
import SwiftUI

class PermitViewModel: ObservableObject {
    
    @Published var allPermit: Bool = false
    @Published var fourteenPermit: Bool = false
    @Published var termsOfServicePermit: Bool = false
    @Published var informationPermit: Bool = false
    
    private var allSelected = false
    private var store: [AnyCancellable] = []
    
    init() {
        $allPermit
            .sink {
                [weak self] newValue in
                guard let self = self else { return }
                
                if newValue && !allSelected {
                    allSelected = true
                    self.fourteenPermit = true
                    self.termsOfServicePermit = true
                    self.informationPermit = true
                } else if !newValue && allSelected {
                    allSelected = false
                    self.fourteenPermit = false
                    self.termsOfServicePermit = false
                    self.informationPermit = false
                }
            }
            .store(in: &store)
        
        Publishers.CombineLatest3($fourteenPermit, $termsOfServicePermit, $informationPermit)
            .sink {
                [weak self] fourteen, terms, info in
                guard let self = self else { return }
                
                if allSelected { // 모두 선택되었을 떄
                    if self.allPermit {
                        allSelected = false
                        self.allPermit = false
                    }
                } else {
                    if fourteen && terms && info {
                        self.allPermit = true
                    }
                }
            }
            .store(in: &store)
    }
}
