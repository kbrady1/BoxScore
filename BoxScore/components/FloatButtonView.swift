//
//  FloatButtonView.swift
//  StatTracker
//
//  Created by Kent Brady on 7/3/20.
//  Copyright © 2020 Brigham Young University. All rights reserved.
//

import SwiftUI

struct FloatButtonView: View {
	@Binding var text: String
	@State var backgroundColor: Color
	@State var textColor: Color = .white
	
    var body: some View {
        Text(text)
			.bold()
			.font(.system(size: 28))
			.frame(minWidth: 300, maxWidth: .infinity)
			.padding(.vertical, 6.0)
			.background(backgroundColor)
			.foregroundColor(textColor)
			.cornerRadius(8.0)
			.shadow(radius: 4.0)
			.animation(.default)
    }
}

struct ButtonView_Previews: PreviewProvider {
    static var previews: some View {
		FloatButtonView(text: Binding.constant("Click Me"), backgroundColor: .blue)
    }
}
