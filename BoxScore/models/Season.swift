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
	
	init(team: Team, currentGame: Game? = nil, previousGames: [Game] = []) {
		self.team = team
		
		self.previousGames = previousGames
		self.currentGame = currentGame
		self.currentlyInGame = currentGame != nil
		
		cancellable = team.objectWillChange.sink { (_) in
			self.objectWillChange.send()
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
