import Combine
import Foundation

class FixerApiMock: FixerAPI {
    var historicalRatesToReturn: AnyPublisher<LatestRates, Error> = Fail(error: ApiError.invalidURL).eraseToAnyPublisher()

    override func latestRates(base: String, symbols: [String]) -> AnyPublisher<LatestRates, Error> {
        return Fail(error: ApiError.invalidURL).eraseToAnyPublisher()
    }

    override func historicalRates(base: String = "EUR", symbols: [String] = [], date: Date) -> AnyPublisher<LatestRates, Error> {
        return historicalRatesToReturn
    }
}
