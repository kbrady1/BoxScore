//
//  CloudManager.swift
//  BoxScore
//
//  Created by Kent Brady on 7/10/20.
//  Copyright © 2020 Brigham Young University. All rights reserved.
//

import Foundation
import CloudKit
import Combine

protocol CloudCreatable {
	init(records: [CKRecord]) throws
}

struct CloudResponse {
	var records: [CKRecord]?
	var error: Error?
}

class CloudManager {
	func fetch(request: Request) -> CurrentValueSubject<CloudResponse, Error> {
		let publisher = CurrentValueSubject<CloudResponse,Error>(CloudResponse(records: nil, error: nil))
		
		request.database.perform(request.query, inZoneWith: request.zone) { (records, error) in
			let _ = publisher.send(CloudResponse(records: records, error: error))
			
			let _ = publisher.send(completion: .finished)
		}
		
		return publisher
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
