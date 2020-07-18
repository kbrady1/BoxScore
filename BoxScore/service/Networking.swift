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

protocol GenericRequest {
	var database: CKDatabase { get }
	var zone: CKRecordZone.ID? { get }
}

protocol FetchRequest2: GenericRequest {
	var query: CKQuery { get }
}

protocol SaveRequest: GenericRequest {
	var recordModel: RecordModel { get set }
}

protocol DeleteRequest: GenericRequest {
	var recordId: CKRecord.ID { get }
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
