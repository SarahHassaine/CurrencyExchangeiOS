import Combine
import Foundation
import Resolver

enum ApiError: Error {
    case invalidURL
}

class FixerAPI {
    @Injected private var client: ApiClient
    private var components = URLComponents()

    init() {
        components.scheme = "http"
        components.host = "data.fixer.io"
    }

    func latestRates(base: String = "EUR", symbols: [String] = ["USD", "EUR", "JPY", "GBP", "AUD", "CAD", "CHF", "CNY", "SEK", "NZD"]) -> AnyPublisher<LatestRates, Error> {
        components.path = "/api/latest"
        components.queryItems = [
            URLQueryItem(name: "access_key", value: apiKey),
            URLQueryItem(name: "base", value: base),
            URLQueryItem(name: "symbols", value: symbols.joined(separator: ","))
        ]
        guard let url = components.url else {
            return Fail(error: ApiError.invalidURL).eraseToAnyPublisher()
        }

        let request = URLRequest(url: url)
        return client.run(request)
            .map(\.value)
            .eraseToAnyPublisher()
    }

    func historicalRates(base: String = "EUR", symbols: [String], date: Date) -> AnyPublisher<LatestRates, Error> {
        let dateformat = DateFormatter()
        dateformat.dateFormat = "yyyy-MM-dd"
        let formattedDate = dateformat.string(from: date)
        components.path = "/api/\(formattedDate)"
        components.queryItems = [
            URLQueryItem(name: "access_key", value: apiKey),
            URLQueryItem(name: "base", value: base),
            URLQueryItem(name: "symbols", value: symbols.joined(separator: ","))
        ]
        guard let url = components.url else {
            return Fail(error: ApiError.invalidURL).eraseToAnyPublisher()
        }

        let request = URLRequest(url: url)
        return client.run(request)
            .map(\.value)
            .eraseToAnyPublisher()
    }
}

struct LatestRates: Codable {
    let success: Bool
    let timestamp: Int
    let base, date: String
    let rates: [String: Double]
}

private var apiKey: String {
    guard let filePath = Bundle.main.path(forResource: "Info", ofType: "plist") else {
        fatalError("Couldn't find file 'Info.plist'.")
    }
    let plist = NSDictionary(contentsOfFile: filePath)
    guard let value = plist?.object(forKey: "API_KEY") as? String else {
        fatalError("Couldn't find key 'FixerApiKey' in 'Info.plist'.")
    }
    return value
}
