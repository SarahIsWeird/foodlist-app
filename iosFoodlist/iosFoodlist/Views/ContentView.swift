import SwiftUI
import sharedFoodlist

struct ContentView: View {
    @ObservedObject var navigation: Navigation
    
    let storageUnitService = StorageUnitService()
	let greeting = Greeting()
    
    @State var storageUnits: [PartialStorageUnit] = []
    @State var errorFetching = false
    
    func load() {
        storageUnitService.getStorageUnits() { result, error in
            if let result = result {
                DispatchQueue.main.async {
                    self.storageUnits = result
                }
            } else {
                errorFetching = true
            }
        }
    }

	var body: some View {
        List(storageUnits, id: \.id) { item in
            NavigationLink(destination: StorageUnitView(navigation, storageUnitService: storageUnitService, partialStorageUnit: item), tag: item.id, selection: $navigation.openStorageUnitId) {
                HStack {
                    switch item.storageType {
                    case StorageType.refrigerator:
                        Image(systemName: "thermometer.snowflake")
                    case StorageType.freezer:
                        Image(systemName: "snowflake")
                    default:
                        Image(systemName: "snowflake")
                            .foregroundColor(.clear)
                    }
                    
                    Text(item.name)
                }
            }
        }
        .toolbar {
            Button {
                DispatchQueue.main.async {
                    navigation.createStorageUnitViewVisible = true
                }
            } label: {
                Image(systemName: "plus")
                    .foregroundColor(.blue)
                    .font(.body)
            }
        }
        .sheet(isPresented: $navigation.createStorageUnitViewVisible, onDismiss: load) {
            CreateStorageUnitView(storageUnitService: storageUnitService)
        }
        .navigationTitle("Regale")
        .onAppear {
            load()
        }
        .popover(isPresented: $errorFetching) {
            Text("Daten konnten nicht geladen werden")
        }
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
        NavigationView {
            ContentView(navigation: Navigation())
        }
	}
}
