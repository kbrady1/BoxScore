//
//  PlayerStatSummaryView.swift
//  StatTracker
//
//  Created by Kent Brady on 5/14/20.
//  Copyright © 2020 Kent Brady. All rights reserved.
//

import SwiftUI

struct PlayerStatSummaryView: View {
	@Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
	@EnvironmentObject var games: GameList
	@EnvironmentObject var team: Team
	
	@ObservedObject var viewModel: StatViewModel
	
	var useLoadedStats: Bool
	var player: Player
	
	private var showingSingleGame: Bool { games.games.count == 1 }
	
	var body: some View {
			List {
				viewModel.loadable.isLoading {
					Section {
						VStack {
							Text("Loading")
						}
						.padding()
					}
				}
				
				viewModel.loadable.hasError { (error) in
					Section {
						VStack {
							Text(error.readableMessage)
						}
						.padding()
					}
				}
				
				viewModel.loadable.hasLoaded { (stats) in
					Section {
						VStack {
							if !self.showingSingleGame {
								Text("Showing data for \(self.games.games.count) games")
									.font(.caption)
									.foregroundColor(.secondary)
							}
							HStack {
								PlayerView(player: self.player, shadow: true, color: .white, height: 100)
								Spacer()
								
								VStack {
									Text(self.getText("POINTS", "PTS PER GAME"))
										.font(.headline)
									Text(self.points(for: stats.stats).formatted(decimal: 1))
										.font(.system(size: 60))
								}
								.frame(minWidth: 80, maxWidth: .infinity)
								.padding()
								.background(BlurView(style: .systemThinMaterial).cornerRadius(4))
								.background(LinearGradient(gradient: Gradient(colors: [self.team.primaryColor, self.team.secondaryColor]), startPoint: .bottomLeading, endPoint: .topTrailing))
								.cornerRadius(4)
								.padding(8.0)
							}
								.padding()
						}
					}
					
					Section(header: Text("Shot Chart")) {
						ShotStatView(shotsToDisplay: stats.stats[.shot] ?? [])
					}
					
					Section(header: Text(self.getText("Totals", "Averages Per Game"))) {
						VStack(spacing: 12) {
							ForEach(self.totals(statDict: stats.stats)) { row in
								HStack {
									Spacer()
									ForEach(row.cells) {
										self.cell(stat: $0)
										Spacer()
									}
								}
								
							}
						}
					}
				}
			}
			.listStyle(GroupedListStyle())
			.environment(\.horizontalSizeClass, .regular)
			.navigationBarTitle("\(player.nameFirstLast)'s Stats")
			.onAppear {
				//This view doesn't need to reload stats when coming from a game summary view
				if self.useLoadedStats {
					self.viewModel.loadable = .success(StatGroup(stats: self.games.statDictionary.mapValues { $0.filter { $0.playerId == self.player.id }
					}))
					self.viewModel.objectWillChange.send()
				} else {
					self.viewModel.onAppear()
				}
			}
    }
	
	private func cell(stat: StatCount) -> some View {
		VStack {
			Text(stat.stat.abbreviation())
				.font(.headline)
				.padding([.top])
			Text(stat.totalText)
				.font(.system(size: 40))
		}
		.frame(minWidth: 55, maxWidth: .infinity)
		.background(BlurView(style: .systemThinMaterial).cornerRadius(4))
		.background(LinearGradient(gradient: Gradient(colors: [team.primaryColor, team.secondaryColor]), startPoint: .bottomLeading, endPoint: .topTrailing))
		.cornerRadius(4)
		.padding(8.0)
	}
	
	func points(for stats: [StatType: [Stat]]) -> Double {
		return Double((stats[.shot] ?? []).sumPoints()) / Double(games.games.count)
	}
	
	func totals(statDict: [StatType: [Stat]]) -> [StatRow] {
		var totals = [StatRow]()
		var tempTotals = [StatCount]()
		statDict.keys.forEach {
			if let stats = statDict[$0]?.filter({ $0.playerId == player.id }) {
				tempTotals.append(StatCount(stat: $0, total: Double(stats.count) / Double(games.games.count)))
			}
		}
		
		let recordedStats = tempTotals.map { $0.stat }
		StatType.all.filter { !recordedStats.contains($0) }.forEach {
			tempTotals.append(StatCount(stat: $0, total: 0))
		}
		
		while !tempTotals.isEmpty {
			let toRemove = tempTotals.prefix(3)
			tempTotals = Array(tempTotals.dropFirst(toRemove.count))
			totals.append(StatRow(cells: Array(toRemove)))
		}
		
		return totals
	}
	
	private func getText(_ single: String, _ season: String) -> String {
		showingSingleGame ? single : season
	}
}

struct PlayerStatSummaryView_Previews: PreviewProvider {
    static var previews: some View {
		let games = GameList(Game.previewData.game)
		let player = games.games[0].team.players[0]
		let view = PlayerStatSummaryView(viewModel: StatViewModel(id: "", type: .player), useLoadedStats: true, player: player).environmentObject(games)
		
		return view
    }
}

struct StatRow: Identifiable {
	var cells: [StatCount]
	public var id = UUID()
}