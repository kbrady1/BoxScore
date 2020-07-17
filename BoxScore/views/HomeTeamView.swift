//
//  HomeTeamView.swift
//  StatTracker
//
//  Created by Kent Brady on 5/11/20.
//  Copyright © 2020 Kent Brady. All rights reserved.
//

import SwiftUI

//TODO: On changing of teams, reload the games
struct HomeTeamView: View {
	@ObservedObject var playersViewModel: PlayersViewModel
	@ObservedObject var seasonViewModel: SeasonViewModel
	@ObservedObject var settings = StatSettings()
	@ObservedObject var league: League
	
	@State var showModal: Bool = false
	@State var showSettings: Bool = false
	@State var showPrimaryColorSheet: Bool = false
	@State var showSecondaryColorSheet: Bool = false
	
	var body: some View {
		ZStack(alignment: .bottom) {
			List {
				Section {
					VStack(alignment: .center) {
						HStack {
							Text("Team: ")
								.font(.caption)
								.padding([.vertical, .leading])
							TextField("Team Name", text: $league.currentSeason.team.name)
								.font(.largeTitle)
						}
						.background(BlurView(style: .systemMaterial))
						.cornerRadius(8)
						.padding()
						HStack {
							Spacer()
							Button(action: {
								self.showPrimaryColorSheet.toggle()
							}) {
								RoundedRectangle(cornerRadius: 8.0)
									.frame(width: 60, height: 60)
									.foregroundColor(league.currentSeason.team.primaryColor)
									.overlay(RoundedRectangle(cornerRadius: 8.0).stroke(Color.white, lineWidth: 2.0))
									.shadow(radius: 4)
							}
							.sheet(isPresented: $showPrimaryColorSheet) {
								ColorPickerView(chosenColor: self.$league.currentSeason.team.primaryColor)
							}
							Spacer()
							Button(action: {
								self.showSecondaryColorSheet.toggle()
							}) {
								RoundedRectangle(cornerRadius: 8.0)
									.frame(width: 60, height: 60)
									.foregroundColor(league.currentSeason.team.secondaryColor)
									.overlay(RoundedRectangle(cornerRadius: 8.0).stroke(Color.white, lineWidth: 2.0))
									.shadow(radius: 4)
							}
							.sheet(isPresented: $showSecondaryColorSheet) {
								ColorPickerView(chosenColor: self.$league.currentSeason.team.secondaryColor)
							}
							Spacer()
						}
						.padding(.bottom)
					}
					.buttonStyle(PlainButtonStyle())
					
					//Load season games
					seasonViewModel.loadable.isLoading {
						Text("Loading")
					}
					seasonViewModel.loadable.hasError { (error) in
						Text(error.readableMessage)
					}
					seasonViewModel.loadable.hasLoaded { (games) in
						NavigationLink(destination:
							SeasonView(season: self.league.currentSeason.withGames(games: games.games))
								.environmentObject(self.settings)
								.environmentObject(self.seasonViewModel)
						) {
							Text("All Games")
								.font(.headline)
								.padding(.leading)
						}
					}
				}
				Section(header: Text("Players")) {
					playersViewModel.loadable.isLoading {
						Text("Loading Players")
					}
					playersViewModel.loadable.hasError { error in
						Text("Error")
					}
					playersViewModel.loadable.hasLoaded { players in
						self.displayTeam(players: players.players)
					}
				}
				
			}
			.listStyle(GroupedListStyle())
			.onAppear {
				UITableView.appearance().separatorColor = .clear
			}
			
			NavigationLink(destination: LiveGameView()
				//Create a new game if one does not exist
				.environmentObject(LiveGame(team: league.currentSeason.team, game: league.currentSeason.currentGame))
				.environmentObject(settings)
				.environmentObject(league.currentSeason)
				.environmentObject(self.seasonViewModel)
			) {
				Text(league.currentSeason.currentGame == nil ? "New Game" : "Continue Game")
					.bold()
					.font(.system(size: 28))
					.frame(minWidth: 300, maxWidth: .infinity)
					.padding(.vertical, 6.0)
					.background(league.currentSeason.team.primaryColor)
					.foregroundColor(Color.white)
					.cornerRadius(8.0)
					.shadow(radius: 4.0)
					.disabled(playersViewModel.loadable.loading || seasonViewModel.loadable.loading)
					.opacity(playersViewModel.loadable.loading || seasonViewModel.loadable.loading ? 0.5 : 1.0)
					.animation(.default)
			}
			.padding([.horizontal, .bottom])
		}
		.navigationBarItems(
			leading:
			Button(action: {
				self.showSettings.toggle()
			}) {
				Image(systemName: "gear")
					.font(.system(size: 28))
					.foregroundColor(league.currentSeason.team.primaryColor)
			}.sheet(isPresented: $showSettings) {
				SettingsView(league: self.league,
							 settings: self.settings,
							 leftGesture: self.settings.leftGesture,
							 rightGesture: self.settings.rightGesture,
							 upGesture: self.settings.upGesture,
							 downGesture: self.settings.downGesture)
					.environmentObject(self.playersViewModel)
					.environmentObject(self.seasonViewModel)
			},
			trailing:
			Button(action: {
				self.showModal.toggle()
			}) {
				Image(systemName: "plus.circle.fill")
					.font(.system(size: 36))
					.foregroundColor(league.currentSeason.currentGame != nil ? Color.gray : league.currentSeason.team.primaryColor)
			}.sheet(isPresented: $showModal) {
				AddPlayerView(teamViewModel: self.playersViewModel)
					.environmentObject(self.league.currentSeason.team)
			}
			.disabled(league.currentSeason.currentGame != nil)
		)
			.onAppear {
				self.seasonViewModel.onAppear()
				self.playersViewModel.onAppear()
		}
	}
	
	private func displayTeam(players: [Player]) -> some View {
		league.currentSeason.team.players = players
		
		return ForEach(league.currentSeason.team.players, id: \.number) { (player) in
			NavigationLink(
				destination: PlayerStatSummaryView(viewModel: StatViewModel(id: player.id, type: .player), useLoadedStats: false, player: player)
					.environmentObject(GameList(self.league.currentSeason.previousGames))
					.environmentObject(self.league.currentSeason.team)
					.environmentObject(self.playersViewModel)
			) {
				HStack(spacing: 16) {
					Text(String(player.number))
						.frame(width: 40, height: 40)
						.background(DefaultCircleView())
					Text(player.nameFirstLast)
				}
				.padding(.vertical, 4.0)
			}
		}
	}
	
	private func displayAllGames(teamGames: TeamGames) -> some View {
		league.currentSeason.previousGames = teamGames.games.filter { $0.isComplete }
		league.currentSeason.currentGame = teamGames.games.first { !$0.isComplete }
		
		return NavigationLink(destination:
			SeasonView(season: league.currentSeason)
				.environmentObject(settings)
		) {
			Text("All Games")
				.font(.headline)
				.padding(.leading)
		}
	}
}
