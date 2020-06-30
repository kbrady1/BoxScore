//
//  ShotStatView.swift
//  StatTracker
//
//  Created by Kent Brady on 5/14/20.
//  Copyright © 2020 Brigham Young University. All rights reserved.
//

import SwiftUI

enum ShotFilter: Hashable {
	case all, misses, makes
}

struct ShotStatView: View {
	@EnvironmentObject var game: Game
	@State private var filterMakes = ShotFilter.all
	@State var shotsToDisplay: [Stat]
	@State private var data: [Row] = []
	
    var body: some View {
        VStack {
			VStack {
				Picker("Filter Shots", selection: $filterMakes) {
					Text("All").tag(ShotFilter.all)
					Text("Makes").tag(ShotFilter.makes)
					Text("Misses").tag(ShotFilter.misses)
				}.pickerStyle(SegmentedPickerStyle())
				ZStack {
					Image("BasketballCourt")
						.resizable()
						.frame(minWidth: 300, maxWidth: .infinity)
						.frame(minHeight: 200, maxHeight: 200)
					ForEach(shotsToDisplay.filter {
						switch (filterMakes) {
						case .all:
							return true
						case .makes:
							return $0.shotWasMake
						case .misses:
							return !$0.shotWasMake
						}
					}) {
						ShotView(make: $0.shotWasMake)
							.position($0.shotLocation!)
					}
					.animation(.default)
				}
				.frame(minWidth: 300, maxWidth: .infinity)
				.frame(minHeight: 200, maxHeight: 200)
			}
			
			VStack(spacing: 8.0) {
				HStack {
					Spacer()
					Spacer().frame(width: 0)
					Spacer()
					Text("MAKES")
						.bold()
					Spacer()
					Text("TAKEN")
					.bold()
					Spacer()
					Text("%")
					.bold()
					Spacer()
				}
				ForEach(data) { (row) in
					HStack {
						ForEach(row.cells) { (cell) in
							Text(cell)
								.frame(width: 60)
								.font(.system(size: 18))
							Spacer()
						}
						.padding(.vertical, 2.0)
					}
					
					.background(BlurView(style: .systemThinMaterial).cornerRadius(4.0))
					.background(LinearGradient(gradient: Gradient(colors: [self.game.team.primaryColor, self.game.team.secondaryColor]), startPoint: .bottom, endPoint: .top).cornerRadius(4.0))
					.padding(.horizontal, 4.0)
				}
			}
			
		}.onAppear {
			self.data = self.calculateData()
		}
    }
	
	private func calculateData() -> [Row] {
		//Repeat for FG, 3P, FT
		let threes = shotsToDisplay.filter { ($0.pointsOfShot ?? 0) == 3 }
		let freeThrows = shotsToDisplay.filter { ($0.pointsOfShot ?? 0) == 1 }
		let fgs = shotsToDisplay.filter { ($0.pointsOfShot ?? 0) == 2 || ($0.pointsOfShot ?? 0) == 3 }
		
		return [getRow(label: "3-PT", shots: threes), getRow(label: "FG", shots: fgs), getRow(label: "FT", shots: freeThrows)]
	}
	
	private func getRow(label: String, shots: [Stat]) -> Row {
		//Create cell for makes, taken, percentage (out of 100)
		let makes = shots.filter { $0.shotWasMake }
		
		let percent = String(format: "%.1f", shots.count == 0 ? 0 : Double(makes.count * 100) / Double(shots.count).rounded()) + "%"
		return Row(cells: [label, "\(makes.count)", "\(shots.count)", percent])
	}
}

struct ShotStatView_Previews: PreviewProvider {
    static var previews: some View {
		let game = Game.statTestData
		let shots = game.statDictionary[.shot] ?? []
		let view = ShotStatView(shotsToDisplay: shots).environmentObject(game)
		
		return view.previewLayout(.fixed(width: 300, height: 400))
    }
}

extension String: Identifiable {
	public var id: String {
		return self.description
	}
}

struct Row: Identifiable {
	var cells: [String]
	
	var id: Int {
		return cells.hashValue
	}
}