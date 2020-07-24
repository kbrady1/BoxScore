//
//  Season.swift
//  StatTracker
//
//  Created by Kent Brady on 7/3/20.
//  Copyright © 2020 Kent Brady. All rights reserved.
//

import Foundation
import Combine

class Season: ObservableObject {
	@Published var team: Team
	@Published var previousGames: [Game]
	@Published var currentGame: Game? {
		didSet {
			currentlyInGame = currentGame != nil
		}
	}
	@Published var currentlyInGame: Bool = false
	
	var cancellable: AnyCancellable?
	var bag: Set<AnyCancellable> = Set()
	
	init(team: Team, currentGame: Game? = nil, previousGames: [Game] = []) {
		self.team = team
		
		self.previousGames = previousGames.sorted { $0.endDate ?? Date() > $1.endDate ?? Date() }
		self.currentGame = currentGame
		self.currentlyInGame = currentGame != nil
		
		bag.insert(team.objectWillChange.sink { (_) in
			self.objectWillChange.send()
		})
		if let currentGame = currentGame {
			bag.insert(currentGame.objectWillChange.sink { (_) in
				self.objectWillChange.send()
			})
		}
		previousGames.map {
			$0.objectWillChange.sink { (_) in
				self.objectWillChange.send()
			}
		}.forEach {
			bag.insert($0)
		}
	}
	
	func completeGame() {
		guard let currentGame = currentGame else { return }
		
		currentGame.isComplete = true
		previousGames.insert(currentGame, at: 0)
		self.currentGame = nil
		
		AppDelegate.instance.saveContext()
	}
	
	func delete(game: Game) {
		previousGames.removeAll { $0 == game }
		
		AppDelegate.context.delete(game.model)
		AppDelegate.instance.saveContext()
	}
}
