import Foundation
import DataCacheKit

func caching<T: Codable>(
    forKey key: String, in cache: some Caching<String, Data>, fetcher: @escaping () async throws -> T
) async throws -> T {
    func cached() async -> T? {
        do {
            guard let data = try await cache.value(for: key) else { return nil }
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            return nil
        }
    }

    if let value = await cached() {
        return value
    } else {
        let result = try await fetcher()
        do {
            let data = try JSONEncoder().encode(result)
            cache.store(data, for: key)
        } catch {}
        return result
    }
}
