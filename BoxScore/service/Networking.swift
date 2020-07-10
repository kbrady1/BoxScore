//
//  Networking.swift
//  BoxScore
//
//  Created by Kent Brady on 7/10/20.
//  Copyright © 2020 Kent Brady. All rights reserved.
//

import Foundation
import CloudKit
import SwiftUI

protocol Request {
	var database: CKDatabase { get }
	var query: CKQuery { get }
	var zone: CKRecordZone.ID? { get }
}

enum Loadable<T> {
	case loading
	case success(T)
	case error(DisplayableError)
	
	var loading: Bool {

        if case .loading = self {
            return true
        }

        return false
    }

    var error: DisplayableError? {
        switch self {
        case .error(let error):
            return error
        default:
            return nil
        }
    }

    var value: T? {
        switch self {
        case .success(let value):
            return value
        default:
            return nil
        }
    }
	
//    func transform<S>(_ t: @escaping (T) -> S) -> Loadable<S> {
//        switch self {
//        case .loading:
//            return .loading
//        case .error(let error):
//            return .error(error)
//        case .success(let value):
//            return .success(t(value))
//        }
//    }

    func isLoading<Content: View>(@ViewBuilder content: @escaping () -> Content) -> Content? {

        if loading {
            return content()
        }

        return nil
    }

    func hasLoaded<Content: View>(@ViewBuilder content: @escaping (T) -> Content) -> Content? {
        if let value = value {
            return content(value)
        }

        return nil
    }

    func hasError<Content: View>(@ViewBuilder content: @escaping (DisplayableError) -> Content) -> Content? {

        if let error = error {
            return content(error)
        }

        return nil
    }
}
