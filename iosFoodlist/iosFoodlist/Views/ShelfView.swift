//
//  ShelfView.swift
//  iosFoodlist
//
//  Created by Sarah Klocke on 11.07.22.
//  Copyright © 2022 orgName. All rights reserved.
//

import SwiftUI
import sharedFoodlist

struct ShelfView: View {
    @ObservedObject var navigation: Navigation
    
    var shelfService: ShelfService
    var partialShelf: PartialShelf
    
    @State var shelf: Shelf
    @State var errorFetching = false
    @State var deleteDialogOpen = false
    
    init(_ navigation: Navigation, shelfService: ShelfService, partialShelf: PartialShelf) {
        self.navigation = navigation
        
        self.shelfService = shelfService
        self.partialShelf = partialShelf
        
        self.shelf = Shelf(id: partialShelf.id, name: partialShelf.name, description: partialShelf.description_, ofStorageUnit: partialShelf.ofStorageUnit, items: [])
    }
    
    func load() {
        shelfService.getShelf(id: partialShelf.id) { result, error in
            if let result = result {
                self.shelf = result
            } else {
                errorFetching = true
            }
        }
    }
    
    var body: some View {
        VStack {
            Text(shelf.description_)
            
            List(shelf.items, id: \.id) { item in
                NavigationLink {
                    ItemView(itemService: shelfService.createItemService(shelfId: shelf.id), item: item)
                } label: {
                    Text(item.name)
                }
            }
        }
        .navigationTitle(shelf.name)
        .toolbar {
            HStack {
                Button {
                    self.deleteDialogOpen = true
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.blue)
                        .font(.body)
                }
                
                Button {
                    DispatchQueue.main.async {
                        navigation.createItemViewVisible = true
                    }
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(.blue)
                        .font(.body)
                }
            }
        }
        .sheet(isPresented: $navigation.createItemViewVisible, onDismiss: load) {
            CreateItemView(itemService: shelfService.createItemService(shelfId: shelf.id))
        }
        .popover(isPresented: $errorFetching) {
            Text("Failed to fetch data")
        }
        .onAppear {
            load()
        }
    }
}

struct ShelfView_Previews: PreviewProvider {
    static var previews: some View {
        let storageUnitService = StorageUnitService()
        let shelfService = storageUnitService.createShelfService(storageUnitId: 2)
        
        ShelfView(Navigation(), shelfService: shelfService, partialShelf: PartialShelf(id: 2, name: "uwu", description: "owo", ofStorageUnit: 2))
    }
}
