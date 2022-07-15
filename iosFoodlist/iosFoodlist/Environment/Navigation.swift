//
//  Navigation.swift
//  iosFoodlist
//
//  Created by Sarah Klocke on 12.07.22.
//  Copyright © 2022 orgName. All rights reserved.
//

import Foundation

class Navigation: ObservableObject {
    @Published var storageUnitViewOpen = false
    @Published var openStorageUnitId: Int64? = 0
    
    @Published var createStorageUnitViewVisible = false
    @Published var createShelfViewVisible = false
    @Published var createItemViewVisible = false
}
