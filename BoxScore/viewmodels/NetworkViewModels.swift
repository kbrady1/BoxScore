//
//  NetworkReadViewModel.swift
//  BoxScore
//
//  Created by Kent Brady on 7/10/20.
//  Copyright © 2020 Kent Brady. All rights reserved.
//

import Foundation
import Combine

protocol GenericNetworkViewModel: ObservableObject {
	associatedtype CloudResource: GenericCloudType

	var objectWillChange: ObservableObjectPublisher { get }
	var loadable: Loadable<CloudResource> { get set }
	var manager: CloudManager { get set }
	var bag: Set<AnyCancellable> { get set }
}

protocol NetworkReadViewModel: GenericNetworkViewModel where CloudResource: CloudCreatable {
	var request: FetchRequest { get set }
	
	func onAppear()
}

extension NetworkReadViewModel {

	func fetch(request: FetchRequest) {
		manager.fetch(request: request)
			.receive(on: RunLoop.main)
			.sink(receiveCompletion: { completion in
				switch completion {
				case .failure(let error):
					print(error)
					self.loadable = .error(DisplayableError())
					self.objectWillChange.send()
				default:
					break
				}
			}, receiveValue: { response in
				if let records = response.records {
					do {
						self.loadable = .success(try CloudResource(records: records))
					} catch BoxScoreError.invalidModelError(let message) {
						self.loadable = .error(DisplayableError(error: response.error, readableMessage: message))
						} catch {
							self.loadable = .error(DisplayableError(error: response.error))
						}
				} else if let error = response.error {
					self.loadable = .error(DisplayableError(error: error))
				}
				
				self.objectWillChange.send()
			})
			.store(in: &bag)
	}
	
	func onAppear() {
		fetch(request: request)
	}
}

protocol NetworkWriteViewModel: GenericNetworkViewModel where CloudResource: CloudUpdated {
	var saveRequest: SaveRequest { get set }
	var deleteRequest: DeleteRequest { get set }
	var record: RecordModel { get set }
}

extension NetworkWriteViewModel {
	func save(request: SaveRequest) {
		manager.save(request: request)
			.receive(on: RunLoop.main)
			.sink(receiveCompletion: { completion in
				switch completion {
				case .failure(let error):
					print(error)
					self.loadable = .error(DisplayableError())
					self.objectWillChange.send()
				default:
					break
				}
			}, receiveValue: { response in
				if let record = response.record, response.error == nil {
					//Update record
					self.record.record = record
					
					self.loadable = .success(CloudResource(error: response.error, complete: response.complete, record: record))
				} else if let error = response.error {
					self.loadable = .error(DisplayableError(error: error))
				}
				
				self.objectWillChange.send()
			})
			.store(in: &bag)
	}
	
	func delete(request: DeleteRequest) {
		manager.delete(request: request)
			.receive(on: RunLoop.main)
			.sink(receiveCompletion: { completion in
				switch completion {
				case .failure(let error):
					print(error)
					self.loadable = .error(DisplayableError())
					self.objectWillChange.send()
				default:
					break
				}
			}, receiveValue: { response in
				if let error = response.error {
					self.loadable = .error(DisplayableError(error: error))
				} else {
					self.loadable = .success(CloudResource(error: response.error, complete: response.complete, record: nil))
				}
				
				self.objectWillChange.send()
			})
			.store(in: &bag)
	}
}
