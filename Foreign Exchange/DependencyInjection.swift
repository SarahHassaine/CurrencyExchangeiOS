import Foundation
import Resolver

extension Resolver {
    static var mock: Resolver!
    static func setupMockMode() {
        Resolver.mock = Resolver(child: .main)
        Resolver.root = .mock
    }
}

extension Resolver: ResolverRegistering {
    public static func registerAllServices() {
        register { ApiClient() }
        register { FixerAPI() }
    }
}
