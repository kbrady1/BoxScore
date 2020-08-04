//
//  StatBlock.swift
//  BoxScore
//
//  Created by Kent Brady on 7/24/20.
//  Copyright © 2020 Kent Brady. All rights reserved.
//

import SwiftUI

struct StatBlock: View {
	@EnvironmentObject var team: Team
	@State var stat: StatCount
	var compressIfNeeded: Bool = false
	
	var shouldCompress: Bool {
		return UIScreen.main.bounds.width <= 320
	}
	
    var body: some View {
		VStack {
			Text(stat.stat == .shot ? "PTS" : stat.stat.abbreviation())
				.font(shouldCompress ? .caption : .headline)
				.frame(minWidth: 35, idealWidth: 50, maxWidth: 60)
			Text(stat.totalText)
				.font(.system(size: shouldCompress ? 30 : 40))
		}
		.padding()
		.background(TeamGradientBackground())
		.cornerRadius(4)
		.padding(shouldCompress ? 4.0 : 8.0)
	}
}

