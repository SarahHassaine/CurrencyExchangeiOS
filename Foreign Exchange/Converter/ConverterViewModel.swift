import Combine
import Foundation
import Resolver

class ConverterViewModel: ObservableObject {
    @Injected private var fixerApi: FixerAPI

    @Published private(set) var convertedCurrencies: [ConvertedCurrency] = []

    private var cancellables = Set<AnyCancellable>()

    func convertCurrency(amount: Double) {
        fixerApi.latestRates()
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] latestRates in
                      self?.convertedCurrencies = []
                      for rate in latestRates.rates {
                          self?.convertedCurrencies.append(ConvertedCurrency(name: rate.key, amount: String(format: "%.2f", rate.value * amount)))
                          self?.convertedCurrencies.sort { $0.name < $1.name }
                      }
                  })
            .store(in: &cancellables)
    }

    func getSymbols(selectedCurrencies: Set<UUID>) -> [String] {
        return convertedCurrencies.filter { selectedCurrencies.contains($0.id) }.map { $0.name }
    }
}

struct ConvertedCurrency: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let amount: String
}
