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
	@EnvironmentObject var teamViewModel: PlayersViewModel
	
	@ObservedObject var viewModel: StatViewModel
	
	@State private var deletePlayerConfirmation: Bool = false
	@State private var editConfirmation: Bool = false
	@State private var showEditPlayerView: Bool = false
	
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
									.actionSheet(isPresented: self.$deletePlayerConfirmation) {
										ActionSheet(title: Text("Confirm Delete Player?"), message: Text("Are you sure you want to delete \(self.player.nameFirstLast)? This will delete all stats associated with this player. This action cannot be undone."), buttons: [
											ActionSheet.Button.destructive(Text("Delete Player"), action: {
//												CloudManager.shared.addRecordToDelete(record: self.player.record)
												self.team.players.removeAll { $0.id == self.player.id }
												self.teamViewModel.update(team: self.team)
												self.teamViewModel.skipCall = true
												self.presentationMode.wrappedValue.dismiss()
											}),
											ActionSheet.Button.cancel()
										])
									}
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
			.if(!self.useLoadedStats) {
				$0.navigationBarItems(trailing: Button(action: {
					self.editConfirmation.toggle()
				}) {
					//TODO: Use triple dot button?
					Text("Edit")
				}
				.actionSheet(isPresented: self.$editConfirmation) {
					//TODO: update text and add edit options here that will launch modal to update player name and number
					ActionSheet(title: Text("Select an Option"), buttons: [
						ActionSheet.Button.default(Text("Edit Player"), action: {
							self.showEditPlayerView.toggle()
						}),
						ActionSheet.Button.destructive(Text("Delete Player"), action: {
							self.deletePlayerConfirmation.toggle()
						}),
						ActionSheet.Button.cancel()
					])
				})
			}
			.onAppear {
				//This view doesn't need to reload stats when coming from a game summary view
				if self.useLoadedStats {
					self.viewModel.loadable = .success(StatGroup(stats: self.games.statDictionary.mapValues { $0.filter { $0.player.id?.uuidString == self.player.id }
					}))
					self.viewModel.objectWillChange.send()
				} else {
					self.viewModel.fetch()
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
		return (stats[.shot] ?? []).sumPoints().safeDivide(by: games.games.count)
	}
	
	func totals(statDict: [StatType: [Stat]]) -> [StatRow] {
		var totals = [StatRow]()
		var tempTotals = [StatCount]()
		statDict.keys.forEach {
			if let stats = statDict[$0]?.filter({ $0.player.id?.uuidString == player.id }) {
				tempTotals.append(StatCount(stat: $0, total: stats.count.safeDivide(by: games.games.count)))
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

struct StatRow: Identifiable {
	var cells: [StatCount]
	public var id = UUID()
}
