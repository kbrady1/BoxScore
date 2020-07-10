//
//  VisualEffectButtonView.swift
//  StatTracker
//
//  Created by Kent Brady on 7/3/20.
//  Copyright © 2020 Brigham Young University. All rights reserved.
//

import SwiftUI

struct VisualEffectButtonView: View {
    @State var text: String
	@State var style: UIBlurEffect.Style = .systemMaterial
	@State var textColor: Color = .blue
	
    var body: some View {
        Text(text)
			.bold()
			.font(.system(size: 28))
			.frame(minWidth: 300, maxWidth: .infinity)
			.padding(.vertical, 6.0)
			.background(BlurView(style: style))
			.foregroundColor(textColor)
			.cornerRadius(8.0)
			.animation(.default)
    }
}

struct TransparentButtonView_Previews: PreviewProvider {
    static var previews: some View {
		VisualEffectButtonView(text: "Click Me")
    }
}
