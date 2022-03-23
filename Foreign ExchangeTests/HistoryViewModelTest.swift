import Combine
import Resolver
import XCTest

@testable import Foreign_Exchange

class HistoryViewModelTest: XCTestCase {
    override func setUp() {
        Resolver.setupMockMode()
    }

    func testConvertCurrencyUpdatesCorrectVariables() {
        let toReturn = Just<LatestRates>(LatestRates(success: true, timestamp: 9, base: "EUR", date: "2022-01-01", rates: ["GBP": 0.8, "JPL": 1.8])).setFailureType(to: Error.self).eraseToAnyPublisher()
        let mock = FixerApiMock()
        mock.historicalRatesToReturn = toReturn
        Resolver.mock.register { mock as FixerAPI }

        let viewModel = HistoryViewModel()

        viewModel.convertCurrency(amount: 20, symbols: ["GBP", "JPN"])

        XCTAssert(viewModel.convertedCurrencies[0].date == "2022-01-01")
        XCTAssert(viewModel.convertedCurrencies[0].convertedCurrencies["GBP"] == "16.00")
        XCTAssert(viewModel.convertedCurrencies[0].convertedCurrencies["JPL"] == "36.00")
    }
}
