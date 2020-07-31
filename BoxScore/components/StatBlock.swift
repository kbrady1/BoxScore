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
	var extraPadding: Bool = true
	
    var body: some View {
		VStack {
			Text(stat.stat == .shot ? "PTS" : stat.stat.abbreviation())
				.font(.headline)
				.frame(minWidth: 50)
			Text(stat.totalText)
				.font(.system(size: 40))
		}
		.padding()
		.background(TeamGradientBackground())
		.cornerRadius(4)
		.padding(8.0)
	}
}

