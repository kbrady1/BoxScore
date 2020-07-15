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
			game.playerIdsInGame = playersInGame.map { $0.id }
		}
	}
	
	@Published var playersOnBench: [Player]
	@Published var statViewModel: StatViewModel
	
	var cancellable: AnyCancellable?
	var receivable: AnyCancellable?
	
	var opponentScoreOptions: [(String, Int)] {
		//Return -1, 1
		[
			("-1", -1),
			("+1", 1),
			("+2", 2),
			("+3", 3)
		].filter { $0.1 + game.opponentScore >= 0 }
	}
	
	init(team: Team, game: Game?) {
		let createdGame = game ?? Game.createGame(teamId: team.id)
		self.game = createdGame
		self.team = team
		
		let playersInGame = game?.playerIdsInGame.compactMap { (id) in
			team.players.first { $0.id == id }
		} ?? []
		self.playersInGame = playersInGame
		self.playersOnBench = team.players.filter { !playersInGame.contains($0) }
		
		self.statViewModel = StatViewModel(id: createdGame.id, type: .game)
		
		cancellable = self.game.objectWillChange.sink(receiveValue: { (_) in
			self.objectWillChange.send()
		})
	}
	
	//MARK: Methods
	
	func createOrStart() {
		let playersInGame = game.playerIdsInGame.compactMap { (id) in
			team.players.first { $0.id == id }
		}
		self.playersInGame = playersInGame
		self.playersOnBench = team.players.filter { !playersInGame.contains($0) }
		
		game.start()
		statViewModel.fetch(request: statViewModel.request)
		
		receivable = statViewModel.objectWillChange.sink {
			//On completion check the value and get the dictionary to write out

			if let values = self.statViewModel.loadable.value {
				self.game.statDictionary = values.stats
				values.stats.keys.forEach {
					if let count = values.stats[$0]?.count, count > 0 {
						self.game.statCounter[$0] = count
					}
				}
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
	}
	
	func recordStat(_ stat: Stat) {
		stat.joinedStats.forEach {
			self.recordStat($0)
		}
		
		game.statDictionary[stat.type] = (game.statDictionary[stat.type] ?? []) + [stat]
		//Update values
		game.statCounter[stat.type] = (game.statCounter[stat.type] ?? 0) + 1
		
		if stat.type == .shot {
			game.teamScore += stat.pointsOfShot ?? 0
		}
		
		CloudManager.shared.addRecordToSave(record: stat.recordToSave())
	}
	
}
