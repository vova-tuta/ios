import Foundation

protocol ExperimentsStorageProtocol {
    func saveExperiments(_ experiments: ExperimentsResponse)
    func getExperiments() -> ExperimentsResponse?
    func clearExperiments()
}

class ExperimentsStorage: ExperimentsStorageProtocol, ObservableObject {
    static let shared = ExperimentsStorage()
    
    @Published private var experiments: ExperimentsResponse?
    
    private init() {}
    
    func saveExperiments(_ experiments: ExperimentsResponse) {
        self.experiments = experiments
    }
    
    func getExperiments() -> ExperimentsResponse? {
        return experiments
    }
    
    func clearExperiments() {
        experiments = nil
    }
} 