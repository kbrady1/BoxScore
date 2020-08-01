//
//  Networking.swift
//  BoxScore
//
//  Created by Kent Brady on 7/10/20.
//  Copyright © 2020 Kent Brady. All rights reserved.
//

import Foundation
import SwiftUI

enum Loadable<T> {
	case loading
	case success(T)
	case error(DisplayableError)
	case empty
	
	var loading: Bool {

        if case .loading = self {
            return true
        }

        return false
    }
	
	var empty: Bool {
		if case .empty = self {
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
	
	func isEmpty<Content: View>(@ViewBuilder content: @escaping () -> Content) -> Content? {
		if empty {
			return content()
		}
		
		return nil
	}
}

struct DisplayableError {
	var error: Error?
	var title: String = "🏀 Shoot! 🏀"
	var readableMessage: String = "That wasn't supposed to happen... Please try again."
}

enum BoxScoreError: Error {
	case invalidModelError(message: String = "Server returned invalid information. Please try again")
	case requestFailed(error: Error, message: String = "That wasn't supposed to happen... Please try again.")
}
