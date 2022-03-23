import Combine
import Resolver
import SwiftUI

struct HistoryView: View {
    @StateObject var viewModel: HistoryViewModel = .init()
    var baseAmount: Double
    var symbols: [String]

    var body: some View {
        VStack {
            Text("\(String(format: "%.2f", baseAmount)) EUR").padding()

            HStack(spacing: 16) {
                VStack {
                    Text("Date").padding(4)
                    ForEach(viewModel.convertedCurrencies, id: \.self) { something in
                        Text(something.date).padding(4)
                        Divider()
                    }
                }

                ForEach(symbols, id: \.self) { symbol in
                    VStack {
                        Text(symbol).padding(4)
                        ForEach(viewModel.convertedCurrencies, id: \.self) { something in
                            Text(something.convertedCurrencies[symbol] ?? "").padding(4)
                            Divider()
                        }
                    }
                }
            }

            Spacer()
        }.onAppear {
            viewModel.convertCurrency(amount: baseAmount, symbols: symbols)
        }
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        Resolver.setupMockMode()
        let toReturn = Just<LatestRates>(LatestRates(success: true, timestamp: 9, base: "EUR", date: "2022-01-01", rates: ["GBP": 0.8, "JPL": 1.8])).setFailureType(to: Error.self).eraseToAnyPublisher()
        let mock = FixerApiMock()
        mock.historicalRatesToReturn = toReturn
        Resolver.mock.register { mock as FixerAPI }
        return HistoryView(baseAmount: 123.45, symbols: ["GBP", "JPL"])
    }
}
