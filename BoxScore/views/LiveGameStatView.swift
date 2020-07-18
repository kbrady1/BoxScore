//
//  LiveGameStatView.swift
//  BoxScore
//
//  Created by Kent Brady on 7/13/20.
//  Copyright © 2020 Kent Brady. All rights reserved.
//

import SwiftUI

struct LiveGameStatView: View {
	@Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
	@EnvironmentObject var game: LiveGame
	
	@State private var teamTotals = [StatCount]()
	@State private var highlightedPlayer: Player? = nil
	
    var body: some View {
		NavigationView {
			List {
				Section(header: Text("Team Totals")) {
					totalScrollView(list: getTeamTotals(dict: game.game.statDictionary))
				}
				
				Section(header: Text("Shot Chart")) {
					ShotStatView(shotsToDisplay: game.game.statDictionary[.shot] ?? [])
						.environmentObject(game.team)
				}
				
				Section(header: Text("Player Stats")) {
					ScrollView(.horizontal, showsIndicators: false) {
						HStack() {
							ForEach(game.team.players) { (player) in
								Button(action: {
									if self.highlightedPlayer == player {
										self.highlightedPlayer = nil
									} else {
										self.highlightedPlayer = player
									}
								}) {
									PlayerView(player: player, shadow: false)
										.if(player.id == self.highlightedPlayer?.id) {
											$0.background(LinearGradient(gradient: Gradient(colors: [self.game.team.primaryColor, self.game.team.secondaryColor]), startPoint: .bottomLeading, endPoint: .topTrailing))
										}
										.if(player.id != self.highlightedPlayer?.id) {
											$0.background(Color.white)
										}
									.clipShape(Circle())
									.padding([.vertical, .trailing])
									.foregroundColor(Color(UIColor.label))
								}
							}
						}
					}
					if highlightedPlayer != nil {
						//Once a player is selected, show their personal stats here
						statView(for: highlightedPlayer!)
					}
				}
			}
			.environment(\.horizontalSizeClass, .regular)
			.listStyle(GroupedListStyle())
			.navigationBarTitle("Game Stats")
			.navigationBarItems(trailing: Button(action: {
				self.presentationMode.wrappedValue.dismiss()
			}) {
				Text("Done")
					.bold()
			})
		}
    }
	
	private func totals(for player: Player, dict: [StatType: [Stat]]) -> [StatRow] {
		let statDict = dict.mapValues { $0.filter { $0.player.id?.uuidString == player.id } }
		var totals = [StatRow]()
		var tempTotals = [StatCount]()
		statDict.keys.forEach {
			if let stats = statDict[$0]?.filter({ $0.player.id?.uuidString == player.id }) {
				tempTotals.append(StatCount(stat: $0, total: stats.count.asDouble))
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
	
	private func getTeamTotals(dict: [StatType: [Stat]]) -> [StatCount] {
		return StatType.all.map { (type) in
			if type == .shot, let shots = dict[type]?.sumPoints() {
				return StatCount(stat: type, total: shots.asDouble)
			}
			
			return StatCount(stat: type, total: (dict[type]?.count ?? 0).asDouble)
		}
	}

	private func statView(for player: Player) -> some View {
		VStack(spacing: 12) {
			ForEach(totals(for: player, dict: game.game.statDictionary)) { row in
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
		.background(LinearGradient(gradient: Gradient(colors: [game.team.primaryColor, game.team.secondaryColor]), startPoint: .bottomLeading, endPoint: .topTrailing))
		.cornerRadius(4)
		.padding(8.0)
	}

	private func totalScrollView(list: [StatCount]) -> some View {
		ScrollView(.horizontal, showsIndicators: false) {
			HStack() {
				ForEach(list) { stat in
					VStack {
						Text(stat.stat == .shot ? "PTS" : stat.stat.abbreviation())
							.font(.headline)
						Text(stat.totalText)
							.font(.system(size: 40))

					}
					.frame(width: 60)
					.padding()
					.background(BlurView(style: .systemThinMaterial).cornerRadius(4))
					.background(LinearGradient(gradient: Gradient(colors: [self.game.team.primaryColor, self.game.team.secondaryColor]), startPoint: .bottomLeading, endPoint: .topTrailing))
					.cornerRadius(4)
					.padding(8.0)
				}
			}
		}
	}
}
