import Combine
import Foundation
import Resolver

class HistoryViewModel: ObservableObject {
    @Injected private var fixerApi: FixerAPI

    @Published private(set) var convertedCurrencies: [DateCurrencies] = []

    private var cancellables = Set<AnyCancellable>()

    func convertCurrency(amount: Double, symbols: [String]) {
        let publishers = getHistoricalRatesPublishers(symbols: symbols)
        Publishers.MergeMany(publishers)
            .print()
            .collect()
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] historicalRates in
                      self?.convertedCurrencies = []
                      for rate in historicalRates {
                          let converted = rate.rates.mapValues { rate in
                              String(format: "%.2f", rate * amount)
                          }
                          let dateCurrency = DateCurrencies(date: rate.date, convertedCurrencies: converted)
                          self?.convertedCurrencies.append(dateCurrency)
                          self?.convertedCurrencies.sort { $0.date < $1.date }
                      }
                  })
            .store(in: &cancellables)
    }

    private func getHistoricalRatesPublishers(symbols: [String]) -> [AnyPublisher<LatestRates, Error>] {
        var dates: [Date?] = []
        for i in 0 ... 4 {
            dates.append(Calendar.current.date(byAdding: .day, value: -i, to: Date()))
        }
        return dates.compactMap { $0 }.map { fixerApi.historicalRates(symbols: symbols, date: $0) }
    }
}

struct DateCurrencies: Hashable, Identifiable {
    let id = UUID()
    let date: String
    let convertedCurrencies: [String: String]
}
