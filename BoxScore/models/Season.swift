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
	
	convenience init(model: TeamCD) throws {
		let team = try Team(model: model)
		let games = team.model.game?.compactMap { $0 as? GameCD }.compactMap { try? Game(model: $0) } ?? []
		var previousGames = games.filter { $0.isComplete }
		let activeGames = games.filter { !$0.isComplete }
		
		var currentGame = activeGames.first
		if activeGames.count > 1 {
			//If somehow extra games were started, take the newest and keep it, and end the other games
			var extraActives = activeGames.sorted { $0.startDate ?? Date() < $1.startDate ?? Date() }
			currentGame = extraActives.popLast()
			
			extraActives.forEach { $0.isComplete = true }
			
			previousGames.append(contentsOf: extraActives)
		}
		
		self.init(
			team: team,
			currentGame: currentGame,
			previousGames: previousGames
		)
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
