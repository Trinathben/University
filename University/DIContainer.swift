//
//  DIContainer.swift
//  University
//
//  Created by Trinath Vikkurthi on 1/20/25.
//

import Swinject

class DIContainer {
    static let shared = DIContainer()

    let container: Container

    private init() {
        container = Container()
        registerDependencies()
    }

    private func registerDependencies() {
        container.register(UniversityViewModel.self) { _ in
            UniversityViewModel(apiService: ApiService())
        }
        container.register(ApiServiceProtocol.self) { _ in
            ApiService()
        }
    }

    func resolve<T>(_ type: T.Type) -> T? {
        container.resolve(type)
    }
}

