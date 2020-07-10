//
//  NetworkViewModel.swift
//  BoxScore
//
//  Created by Kent Brady on 7/10/20.
//  Copyright © 2020 Brigham Young University. All rights reserved.
//

import Foundation
import Combine

protocol NetworkViewModel: ObservableObject {

	associatedtype CloudResource: CloudCreatable

	var objectWillChange: ObservableObjectPublisher { get }
	var loadable: Loadable<CloudCreatable> { get set }
	var manager: CloudManager { get set }
	var request: Request { get set }
	var bag: Set<AnyCancellable> { get set }

	func onAppear()
}

extension NetworkViewModel {

	func fetch(request: Request) {
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
				} else {
					self.loadable = .error(DisplayableError(error: response.error))
				}
				
				self.objectWillChange.send()
			})
			.store(in: &bag)
	}

	func onAppear() {
		fetch(request: request)
	}
}
