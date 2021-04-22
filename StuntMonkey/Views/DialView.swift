//
//  DialView.swift
//  StuntMonkey
//
//  Created by Daniël du Preez on 4/19/21.
//

import SwiftUI

struct DialView: View {
    var maxAngle: Angle
    var minAngle: Angle
    var currentAngle: Angle
    
    var body: some View {
        ZStack {
            Circle().opacity(0.2)
            Pie(startAngle: Angle(degrees: 0), endAngle: -maxAngle, clockwise: true).opacity(0.5)
            Pie(startAngle: Angle(degrees: 0), endAngle: -currentAngle, clockwise: currentAngle > Angle(degrees: 0))
            Pie(startAngle: Angle(degrees: 0), endAngle: -minAngle, clockwise: false).opacity(0.5)
        }
    }
}

struct Pie: Shape {
    var startAngle: Angle
    var endAngle: Angle
    var clockwise: Bool = false
    
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let start = CGPoint(
            x: center.x + radius * cos(CGFloat(startAngle.radians)),
            y: center.y + radius * sin(CGFloat(startAngle.radians))
        )
        var p = Path()
        
        p.move(to: center)
        p.addLine(to: start)
        p.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: clockwise)
        p.addLine(to: center)
        
        return p
    }
}
