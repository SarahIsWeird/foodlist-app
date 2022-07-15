//
//  StorageUnitView.swift
//  iosFoodlist
//
//  Created by Sarah Klocke on 10.07.22.
//  Copyright © 2022 orgName. All rights reserved.
//

import SwiftUI
import sharedFoodlist

struct StorageUnitView: View {
    @ObservedObject var navigation: Navigation
    
    var storageUnitService: StorageUnitService
    var partialStorageUnit: PartialStorageUnit
    
    @State var storageUnit: StorageUnit = StorageUnit(id: 0, name: "", description: "", storageType: StorageType.shelf, shelves: [])
    @State var errorFetching = false
    @State var deleteDialogOpen = false
    
    init(_ navigation: Navigation, storageUnitService: StorageUnitService, partialStorageUnit: PartialStorageUnit) {
        self.navigation = navigation
        self.storageUnitService = storageUnitService
        self.partialStorageUnit = partialStorageUnit
        
        self.storageUnit = StorageUnit(id: partialStorageUnit.id, name: partialStorageUnit.name, description: partialStorageUnit.description_, storageType: partialStorageUnit.storageType, shelves: [])
    }
    
    func load() {
        storageUnitService.getStorageUnit(id: partialStorageUnit.id) { result, error in
            if let result = result {
                self.storageUnit = result
            } else {
                errorFetching = true
            }
        }
    }
    
    var body: some View {
        VStack {
            Text(storageUnit.description_)
            
            List(storageUnit.shelves, id: \.id) { shelf in
                NavigationLink(destination: ShelfView(navigation, shelfService: storageUnitService.createShelfService(storageUnitId: partialStorageUnit.id), partialShelf: shelf)) {
                    Text(shelf.name)
                }
            }
        }
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
                        navigation.createShelfViewVisible = true
                    }
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(.blue)
                        .font(.body)
                }
            }
        }
        .sheet(isPresented: $navigation.createShelfViewVisible, onDismiss: load) {
            CreateShelfView(shelfService: storageUnitService.createShelfService(storageUnitId: storageUnit.id))
        }
        .navigationTitle(storageUnit.name)
        .popover(isPresented: $errorFetching) {
            Text("Failed to fetch data")
        }
        .onAppear {
            load()
        }
        .confirmationDialog("Regal löschen", isPresented: $deleteDialogOpen) {
            Button("'\(storageUnit.name)' löschen", role: .destructive) {
                storageUnitService.deleteStorageUnit(id: storageUnit.id) { result, error in
                    DispatchQueue.main.async {
                        navigation.openStorageUnitId = nil
                    }
                }
            }
        }
    }
}

struct StorageUnitView_Previews: PreviewProvider {
    static let storageUnitService = StorageUnitService()
    
    static var previews: some View {
        StorageUnitView(Navigation(), storageUnitService: storageUnitService, partialStorageUnit: PartialStorageUnit(id: 2, name: "Test", description: "uwu", storageType: StorageType.shelf))
    }
}
