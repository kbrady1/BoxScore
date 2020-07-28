//
//  LiveGame.swift
//  BoxScore
//
//  Created by Kent Brady on 7/11/20.
//  Copyright © 2020 Kent Brady. All rights reserved.
//

import Foundation
import Combine

class LiveGame: ObservableObject {
	@Published var game: Game
	@Published var team: Team
	
	@Published var playersInGame: [Player] {
		didSet {
			game.playersInGame = playersInGame
		}
	}
	
	@Published var playersOnBench: [Player]
	@Published var statViewModel: StatViewModel
	
	var cancellable: AnyCancellable?
	
	var opponentScoreOptions: [(String, Int)] {
		//Return -1, 1
		[
			("-1", -1),
			("+1", 1),
			("+2", 2),
			("+3", 3)
		].filter { $0.1 + game.opponentScore >= 0 }
	}
	
	init(team: Team, game: Game) {
		let createdGame = game
		self.game = createdGame
		self.team = team
		
		let playersInGame = game.playersInGame
		self.playersInGame = playersInGame
		self.playersOnBench = team.players.filter { !playersInGame.contains($0) }
		
		self.statViewModel = StatViewModel(game: createdGame.model)
		
		cancellable = self.game.objectWillChange.sink(receiveValue: { (_) in
			self.objectWillChange.send()
		})
	}
	
	//MARK: Methods
	
	func setUp() {
		self.playersInGame = game.playersInGame
		self.playersOnBench = team.players.filter { !game.playersInGame.contains($0) }
		
		self.game.statDictionary = statViewModel.fetch().0.stats
		self.game.statDictionary.keys.forEach {
			if let count = self.game.statDictionary[$0]?.count, count > 0 {
				self.game.statCounter[$0] = count
			}
		}
	}
	
	func swapPlayers(fromBench benchPlayer: Player?, toLineUp playerOnCourt: Player?) {
		if let benchPlayer = benchPlayer,
			let benchIndex = playersOnBench.firstIndex(of: benchPlayer),
			(playersInGame.count < 5 || playerOnCourt != nil) {
			
			playersOnBench.remove(at: benchIndex)
			playersInGame.append(benchPlayer)
			
			if let playerOnCourt = playerOnCourt {
				playersOnBench.insert(playerOnCourt, at: benchIndex)
				
				if let courtIndex = playersInGame.firstIndex(of: playerOnCourt) {
					playersInGame.remove(at: courtIndex)
				}
			}
		} else if let playerOnCourt = playerOnCourt,
			let courtIndex = playersInGame.firstIndex(of: playerOnCourt) {
			//If benchPlayer was nil and playerOnCourt isn't
			playersInGame.remove(at: courtIndex)
			playersOnBench.insert(playerOnCourt, at: 0)
		}
		
		self.objectWillChange.send()
	}
	
	func recordStat(_ stat: StatInput) {
		stat.joinedStats.forEach {
			self.recordStat($0)
		}
		
		let recordedStat = stat.toStat()
		
		game.statDictionary[recordedStat.type] = (game.statDictionary[recordedStat.type] ?? []) + [recordedStat]
		//Update values
		game.statCounter[recordedStat.type] = (game.statCounter[recordedStat.type] ?? 0) + 1
		
		if recordedStat.type == .shot && recordedStat.shotWasMake {
			game.teamScore += recordedStat.pointsOfShot ?? 0
		}
		
		AppDelegate.instance.saveContext()
	}
	
}
