//
//  SettingsView.swift
//  StatTracker
//
//  Created by Kent Brady on 6/29/20.
//  Copyright © 2020 Brigham Young University. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
	@Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
	
	@State var settings: StatSettings
	@State var team: Team
	@State var selectedTeam: Team
	
	@State var leftGesture: StatType
	@State var rightGesture: StatType
	@State var upGesture: StatType
	@State var downGesture: StatType
	
	var teams: [Team] {
		return [team]
	}
	
    var body: some View {
		NavigationView {
			List {
				Section(header:
					Text("Teams")
						.font(Font.system(size: 32))
						.bold()
				) {
					ForEach(teams, id: \.name) { (team) in
						Button(action: {
							self.selectedTeam = team
						}) {
							HStack {
								Text(team.name)
									.bold()
									.foregroundColor(team.name == self.selectedTeam.name ? team.primaryColor : Color.gray)
								Spacer()
								if team.name == self.selectedTeam.name {
									Image(systemName: "checkmark.circle.fill")
										.foregroundColor(team.secondaryColor)
								}
							}
						}
					}
					Button(action: {
						//TODO: This should send you back home to the HomeTeamView with empty data
					}) {
						Text("Add Team")
					}
				}
				Section(header:
					Text("Stat Gestures")
						.font(Font.system(size: 32))
						.bold()
				) {
					gestureButton(for: .up, selection: $settings.upGesture)
					gestureButton(for: .left, selection: $leftGesture)
					gestureButton(for: .right, selection: $settings.rightGesture)
					gestureButton(for: .down, selection: $settings.downGesture)
				}
				
				Button(action: {
					//TODO:
				}) {
					Text("Delete Data")
						.foregroundColor(.red)
				}
				
			}
			.listStyle(GroupedListStyle())
			.environment(\.horizontalSizeClass, .regular)
			.navigationBarTitle("Settings")
			.navigationBarItems(trailing: Button(action: {
				self.presentationMode.wrappedValue.dismiss()
			}) {
				Text("Done")
					.bold()
			})
		}
    }
	
	private func gestureButton(for direction: MoveDirection, selection: Binding<StatType>) -> some View {
		VStack(spacing: 8) {
			Text("\(direction.rawValue.capitalized)")
				.bold()
			ScrollView(.horizontal, showsIndicators: false) {
				HStack(spacing: 16) {
					ForEach(StatType.all, id: \.hashValue) { (stat) in
						Text(stat.abbreviation())
							.if(selection.wrappedValue.id == stat.id) { $0.bold() }
							.frame(width: 60, height: 60)
							.if(selection.wrappedValue.id == stat.id) {
								$0.background(CircleView(color: Binding.constant(self.team.primaryColor), shadow: false))
							}
							.if(selection.wrappedValue.id != stat.id) {
								$0.background(CircleView(color: Binding.constant(Color.white), shadow: false))
							}
							.onTapGesture {
								selection.wrappedValue = stat
								switch direction {
								case .left:
									self.settings.leftGesture = stat
								case .right:
									self.settings.rightGesture = stat
								case .down:
									self.settings.downGesture = stat
								case.up:
									self.settings.upGesture = stat
								}
							}
					}
				}
				.padding(.vertical)
			}
			.frame(height: 60)
		}
	}
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
		SettingsView(
			settings: StatSettings(),
			team: Team(name: "Cougars", primaryColor: .blue, secondaryColor: .black),
			selectedTeam: Team(name: "Cougars", primaryColor: .blue, secondaryColor: .black),
			leftGesture: .shot,
			rightGesture: .rebound,
			upGesture: .steal,
			downGesture: .block
		)
    }
}
