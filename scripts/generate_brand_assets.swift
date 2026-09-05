import AppKit
import Foundation

private let fm = FileManager.default
private let root = fm.currentDirectoryPath
private let appIconPath = root + "/ios/DubaiMove/Assets.xcassets/AppIcon.appiconset/AppIcon1024.png"
private let brandLogoPath = root + "/ios/DubaiMove/Assets.xcassets/BrandLogo.imageset/BrandLogo.png"
private let brandWelcomePath = root + "/ios/DubaiMove/Assets.xcassets/BrandWelcome.imageset/BrandWelcome.png"

private func ensureParent(_ path: String) {
    try? fm.createDirectory(atPath: (path as NSString).deletingLastPathComponent, withIntermediateDirectories: true)
}

private func pngData(_ image: NSImage) -> Data? {
    guard let tiff = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiff) else { return nil }
    return bitmap.representation(using: .png, properties: [:])
}

private func save(_ image: NSImage, to path: String) {
    ensureParent(path)
    guard let data = pngData(image) else { fatalError("Could not encode PNG") }
    try! data.write(to: URL(fileURLWithPath: path))
    print("Generated \(path)")
}

private func roundedRect(_ rect: NSRect, radius: CGFloat, color: NSColor) {
    color.setFill()
    NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius).fill()
}

private func gradientBackground(_ rect: NSRect, top: NSColor, bottom: NSColor) {
    let gradient = NSGradient(starting: bottom, ending: top)!
    gradient.draw(in: rect, angle: 90)
}

private func drawSkyline(in rect: NSRect, alpha: CGFloat) {
    NSColor(calibratedRed: 0.02, green: 0.12, blue: 0.09, alpha: alpha).setFill()
    let baseline = rect.minY
    let widths: [CGFloat] = [0.05,0.035,0.055,0.028,0.05,0.036,0.06,0.03,0.04,0.05,0.032,0.046,0.025,0.055]
    let heights: [CGFloat] = [0.20,0.32,0.24,0.45,0.28,0.58,0.36,0.76,0.30,0.52,0.27,0.42,0.34,0.25]
    var x = rect.minX
    for i in 0..<widths.count {
        let w = rect.width * widths[i]
        let h = rect.height * heights[i]
        NSBezierPath(rect: NSRect(x: x, y: baseline, width: w, height: h)).fill()
        x += w + rect.width * 0.012
    }
    // Burj Khalifa silhouette
    let bx = rect.midX + rect.width * 0.15
    let baseW = rect.width * 0.055
    let maxH = rect.height * 0.93
    let path = NSBezierPath()
    path.move(to: NSPoint(x: bx - baseW/2, y: baseline))
    path.line(to: NSPoint(x: bx - baseW*0.32, y: baseline + maxH*0.53))
    path.line(to: NSPoint(x: bx - baseW*0.18, y: baseline + maxH*0.70))
    path.line(to: NSPoint(x: bx - baseW*0.09, y: baseline + maxH*0.84))
    path.line(to: NSPoint(x: bx, y: baseline + maxH))
    path.line(to: NSPoint(x: bx + baseW*0.09, y: baseline + maxH*0.84))
    path.line(to: NSPoint(x: bx + baseW*0.18, y: baseline + maxH*0.70))
    path.line(to: NSPoint(x: bx + baseW*0.32, y: baseline + maxH*0.53))
    path.line(to: NSPoint(x: bx + baseW/2, y: baseline))
    path.close()
    path.fill()
}

private func drawPalm(at center: NSPoint, scale: CGFloat, color: NSColor) {
    color.setStroke()
    let trunk = NSBezierPath()
    trunk.lineWidth = 9 * scale
    trunk.move(to: NSPoint(x: center.x, y: center.y - 54*scale))
    trunk.curve(to: NSPoint(x: center.x + 6*scale, y: center.y + 34*scale), controlPoint1: NSPoint(x: center.x-4*scale, y: center.y-12*scale), controlPoint2: NSPoint(x:center.x+2*scale,y:center.y+8*scale))
    trunk.stroke()
    for angle in stride(from: -150.0, through: 150.0, by: 50.0) {
        let rad = angle * .pi / 180
        let end = NSPoint(x: center.x + cos(rad)*62*scale, y: center.y + sin(rad)*34*scale)
        let leaf = NSBezierPath()
        leaf.lineWidth = 7 * scale
        leaf.move(to: NSPoint(x: center.x+4*scale, y:center.y+32*scale))
        leaf.curve(to: end, controlPoint1: NSPoint(x:center.x+cos(rad)*28*scale,y:center.y+44*scale), controlPoint2:end)
        leaf.stroke()
    }
}

private func drawBrandMark(in rect: NSRect, background: Bool) {
    let emerald = NSColor(calibratedRed: 0.02, green: 0.30, blue: 0.20, alpha: 1)
    let deep = NSColor(calibratedRed: 0.005, green: 0.17, blue: 0.115, alpha: 1)
    let mint = NSColor(calibratedRed: 0.72, green: 0.96, blue: 0.79, alpha: 1)
    let gold = NSColor(calibratedRed: 0.92, green: 0.72, blue: 0.36, alpha: 1)

    if background {
        gradientBackground(rect, top: emerald, bottom: deep)
    }

    let inset = rect.width * 0.18
    let mark = rect.insetBy(dx: inset, dy: inset)
    let cx = mark.midX
    let top = mark.maxY
    let bottom = mark.minY

    // soft diamond/ribbon shell
    let shell = NSBezierPath()
    shell.move(to: NSPoint(x: cx, y: top))
    shell.curve(to: NSPoint(x: mark.maxX, y: mark.midY+20), controlPoint1:NSPoint(x:mark.maxX-55,y:top-25), controlPoint2:NSPoint(x:mark.maxX,y:mark.midY+85))
    shell.curve(to: NSPoint(x: cx+32, y: bottom+38), controlPoint1:NSPoint(x:mark.maxX-22,y:mark.minY+100), controlPoint2:NSPoint(x:cx+90,y:bottom+48))
    shell.curve(to: NSPoint(x: mark.minX, y: mark.midY+5), controlPoint1:NSPoint(x:cx-45,y:bottom+18), controlPoint2:NSPoint(x:mark.minX,y:mark.minY+125))
    shell.curve(to: NSPoint(x: cx, y: top), controlPoint1:NSPoint(x:mark.minX,y:top-90), controlPoint2:NSPoint(x:cx-70,y:top+8))
    shell.close()
    let shellGradient = NSGradient(colors: [emerald, mint])!
    shellGradient.draw(in: shell, angle: 40)

    // inner home silhouette
    deep.setFill()
    let home = NSBezierPath()
    home.move(to: NSPoint(x: cx, y: top-64))
    home.line(to: NSPoint(x: mark.maxX-68, y: mark.midY+45))
    home.line(to: NSPoint(x: mark.maxX-68, y: bottom+142))
    home.line(to: NSPoint(x: mark.minX+72, y: bottom+142))
    home.line(to: NSPoint(x: mark.minX+72, y: mark.midY+42))
    home.close()
    home.fill()

    // skyline inside mark
    mint.withAlphaComponent(0.93).setFill()
    let skylineX = mark.minX + 78
    let skyBottom = bottom + 142
    let blocks: [(CGFloat,CGFloat,CGFloat)] = [(0,38,120),(44,32,170),(82,50,245),(138,32,330)]
    for (offset,w,h) in blocks {
        NSBezierPath(rect:NSRect(x:skylineX+offset,y:skyBottom,width:w,height:h)).fill()
    }
    let burj = NSBezierPath()
    burj.move(to:NSPoint(x:skylineX+170,y:skyBottom))
    burj.line(to:NSPoint(x:skylineX+184,y:skyBottom+285))
    burj.line(to:NSPoint(x:skylineX+192,y:skyBottom+415))
    burj.line(to:NSPoint(x:skylineX+199,y:skyBottom+285))
    burj.line(to:NSPoint(x:skylineX+214,y:skyBottom))
    burj.close(); burj.fill()

    drawPalm(at: NSPoint(x: mark.minX+112, y: skyBottom+115), scale: 0.63, color: mint.withAlphaComponent(0.9))

    // window
    gold.setFill()
    let cell: CGFloat = 38
    for r in 0..<2 { for c in 0..<2 {
        roundedRect(NSRect(x:cx+46+CGFloat(c)*(cell+9), y:mark.midY+95+CGFloat(r)*(cell+9), width:cell, height:cell), radius:9, color:gold)
    }}

    // open door
    roundedRect(NSRect(x:cx+36,y:bottom+142,width:98,height:145), radius:22, color:emerald)
    let door = NSBezierPath()
    door.move(to:NSPoint(x:cx+91,y:bottom+142))
    door.line(to:NSPoint(x:cx+142,y:bottom+164))
    door.line(to:NSPoint(x:cx+142,y:bottom+276))
    door.line(to:NSPoint(x:cx+91,y:bottom+253))
    door.close(); gold.setFill(); door.fill()

    // gold road / movement ribbon
    let road = NSBezierPath()
    road.move(to:NSPoint(x:mark.minX+130,y:bottom+18))
    road.curve(to:NSPoint(x:cx+54,y:bottom+132), controlPoint1:NSPoint(x:cx+15,y:bottom+20), controlPoint2:NSPoint(x:cx+180,y:bottom+65))
    road.curve(to:NSPoint(x:cx+90,y:bottom+154), controlPoint1:NSPoint(x:cx-12,y:bottom+150), controlPoint2:NSPoint(x:cx+45,y:bottom+166))
    road.curve(to:NSPoint(x:cx+103,y:bottom+144), controlPoint1:NSPoint(x:cx+102,y:bottom+153), controlPoint2:NSPoint(x:cx+104,y:bottom+148))
    road.lineWidth = rect.width * 0.075
    road.lineCapStyle = .round
    gold.setStroke(); road.stroke()
}

private func makeIcon() -> NSImage {
    let size = NSSize(width:1024,height:1024)
    let image = NSImage(size:size)
    image.lockFocus()
    let rect = NSRect(origin:.zero,size:size)
    gradientBackground(rect, top:NSColor(calibratedRed:0.02,green:0.36,blue:0.24,alpha:1), bottom:NSColor(calibratedRed:0.005,green:0.17,blue:0.11,alpha:1))
    drawSkyline(in:NSRect(x:0,y:70,width:1024,height:480),alpha:0.38)
    drawBrandMark(in:rect.insetBy(dx:55,dy:55),background:false)
    image.unlockFocus()
    return image
}

private func makeLogo() -> NSImage {
    let size=NSSize(width:900,height:900)
    let image=NSImage(size:size)
    image.lockFocus()
    NSColor.clear.setFill(); NSRect(origin:.zero,size:size).fill()
    drawBrandMark(in:NSRect(origin:.zero,size:size),background:false)
    image.unlockFocus(); return image
}

private func makeWelcome() -> NSImage {
    let size=NSSize(width:1179,height:2556)
    let image=NSImage(size:size)
    image.lockFocus()
    let rect=NSRect(origin:.zero,size:size)
    gradientBackground(rect, top:NSColor(calibratedRed:0.02,green:0.33,blue:0.22,alpha:1), bottom:NSColor(calibratedRed:0.002,green:0.11,blue:0.075,alpha:1))
    // soft horizon glow
    let glowRect=NSRect(x:0,y:820,width:1179,height:1200)
    let glow=NSGradient(colors:[NSColor(calibratedRed:0.84,green:0.66,blue:0.30,alpha:0.0),NSColor(calibratedRed:0.84,green:0.66,blue:0.30,alpha:0.24),NSColor(calibratedRed:0.84,green:0.66,blue:0.30,alpha:0.0)])!
    glow.draw(in:glowRect,angle:90)
    drawSkyline(in:NSRect(x:45,y:810,width:1089,height:990),alpha:0.78)
    drawPalm(at:NSPoint(x:115,y:920),scale:1.2,color:NSColor(calibratedRed:0.05,green:0.20,blue:0.13,alpha:0.95))
    drawPalm(at:NSPoint(x:1070,y:910),scale:1.15,color:NSColor(calibratedRed:0.05,green:0.20,blue:0.13,alpha:0.95))
    // water / floor reflection bands
    for i in 0..<12 {
        let a=max(0.015,0.11-CGFloat(i)*0.008)
        NSColor.white.withAlphaComponent(a).setFill()
        NSBezierPath(roundedRect:NSRect(x:100+CGFloat(i)*18,y:710-CGFloat(i)*36,width:979-CGFloat(i)*36,height:5),xRadius:3,yRadius:3).fill()
    }
    image.unlockFocus(); return image
}

save(makeIcon(), to: appIconPath)
save(makeLogo(), to: brandLogoPath)
save(makeWelcome(), to: brandWelcomePath)
