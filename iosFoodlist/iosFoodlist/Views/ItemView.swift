//
//  ItemView.swift
//  iosFoodlist
//
//  Created by Sarah Klocke on 11.07.22.
//  Copyright © 2022 orgName. All rights reserved.
//

import SwiftUI
import sharedFoodlist

struct ItemView: View {
    var itemService: ItemService
    
    @State var item: Item
    @State var errorFetching = false
    
    init(itemService: ItemService, item: Item) {
        self.itemService = itemService
        
        self.item = item
    }
    
    func load() {
        itemService.getItem(id: item.id) { result, error in
            if let result = result {
                self.item = result
            } else {
                self.errorFetching = true
            }
        }
    }
    
    var body: some View {
        VStack {
            Text(item.description_)
        }
        .navigationTitle(item.name)
        .popover(isPresented: $errorFetching) {
            Text("Failed to fetch data")
        }
        .onAppear {
            load()
        }
    }
}

struct ItemView_Previews: PreviewProvider {
    static var previews: some View {
        let storageUnitService = StorageUnitService()
        let shelfService = storageUnitService.createShelfService(storageUnitId: 2)
        let itemService = shelfService.createItemService(shelfId: 2)
        
        ItemView(itemService: itemService, item: Item(id: 2, name: "Pockies", description: "Erdbeer Pockies"))
    }
}
