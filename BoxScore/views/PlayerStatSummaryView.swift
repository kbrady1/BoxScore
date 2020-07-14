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
	
	var player: Player
	@State private var totals = [StatRow]()
	@State private var shots = [Stat]()
	@State private var points = 0.0
	
	private var showingSingleGame: Bool { games.games.count == 1 }
	
	var body: some View {
			List {
				Section {
					VStack {
						if !showingSingleGame {
							Text("Showing data for \(games.games.count) games")
								.font(.caption)
								.foregroundColor(.secondary)
						}
						HStack {
							PlayerView(player: player, shadow: true, color: .white, height: 100)
							Spacer()
							
							VStack {
								Text(getText("POINTS", "PTS PER GAME"))
									.font(.headline)
								Text(points.formatted(decimal: 1))
									.font(.system(size: 60))
							}
							.frame(minWidth: 80, maxWidth: .infinity)
							.padding()
							.background(BlurView(style: .systemThinMaterial).cornerRadius(4))
							.background(LinearGradient(gradient: Gradient(colors: [team.primaryColor, team.secondaryColor]), startPoint: .bottomLeading, endPoint: .topTrailing))
							.cornerRadius(4)
							.padding(8.0)
						}
							.padding()
					}
				}
				
				Section(header: Text("Shot Chart")) {
					ShotStatView(shotsToDisplay: shots)
				}
				
				Section(header: Text(getText("Totals", "Averages Per Game"))) {
					VStack(spacing: 12) {
						ForEach(totals) { row in
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
			.listStyle(GroupedListStyle())
			.environment(\.horizontalSizeClass, .regular)
			.navigationBarTitle("\(player.nameFirstLast)'s Stats")
				.onAppear {
					self.setup()
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
	
	private func setup() {
		var tempTotals = [StatCount]()
		var statDictionary = [StatType: [Stat]]()
		games.games.forEach {
			statDictionary.merge($0.statDictionary) { $0 + $1 }
		}
		statDictionary.keys.forEach {
			if let stats = statDictionary[$0]?.filter({ $0.playerId == player.id }) {
				if $0 == .shot {
					self.shots = stats
					
					self.points = Double(shots.sumPoints()) / Double(games.games.count)
				}
				
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
	}
	
	private func getText(_ single: String, _ season: String) -> String {
		showingSingleGame ? single : season
	}
}

struct PlayerStatSummaryView_Previews: PreviewProvider {
    static var previews: some View {
		let games = GameList(Game.statTestData)
		let player = games.games[0].team.players[0]
		let view = PlayerStatSummaryView(player: player).environmentObject(games)
		
		return view
    }
}

struct StatRow: Identifiable {
	var cells: [StatCount]
	public var id = UUID()
}
