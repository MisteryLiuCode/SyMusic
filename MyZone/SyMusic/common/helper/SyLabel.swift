//
//  SyLabel.swift
//  SyMusic
//
//  Created by sxm on 2020/5/14.
//  Copyright © 2020 wwsq. All rights reserved.
//

import Foundation
import UIKit
import MarqueeLabel
import LTMorphingLabel

//UILabel高度
func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
    let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
    label.numberOfLines = 0
    label.lineBreakMode = .byWordWrapping
    label.font = font
    label.text = text
    label.sizeToFit()
    return label.frame.height
}
    
func labWithAttributeCollection(text: String, textColor: UIColor, font: UIFont, textAlignment: NSTextAlignment) -> UILabel {
    let lab = UILabel()
    lab.text = text
    lab.textColor = textColor
    lab.font = font
    lab.textAlignment = textAlignment
    lab.lineBreakMode = .byTruncatingTail
    return lab
}

extension UILabel {
    func addShadow(blurRadius: CGFloat = 0, widthOffset: Double = 0, heightOffset: Double = 0, opacity: Float = 0.4) {
        self.layer.shadowRadius = blurRadius
        self.layer.shadowOffset = CGSize(
            width: widthOffset,
            height: heightOffset
        )
        self.layer.shadowOpacity = opacity
    }
}

//歌词文本
class SyLrcLabel: UILabel {
    
    var radio: CGFloat = 0.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if self.text?.trimmingCharactersCount ?? 0 > 0 {
            UIColor.white.set()
            UIRectFillUsingBlendMode(CGRect(x: rect.origin.x, y: rect.origin.y, width: rect.size.width * radio, height: rect.size.height), CGBlendMode.sourceIn)
        }else{
            UIColor.clear.set()
        }
    }
}

//动效歌词文本
class SyLrcDEffectLabel: LTMorphingLabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.morphingDuration = 0.5
        self.morphingEffect = LTMorphingEffect(rawValue: 3)!
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var radio: CGFloat = 0.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if self.text?.trimmingCharactersCount ?? 0 > 0 {
            UIColor.white.set()
            UIRectFillUsingBlendMode(CGRect(x: rect.origin.x, y: rect.origin.y, width: rect.size.width * radio, height: rect.size.height), CGBlendMode.sourceIn)
        }else{
            UIColor.clear.set()
        }
    }
}

class SyLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(text: String, textColor: UIColor, font: UIFont, textAlignment: NSTextAlignment) {
        self.init(frame: CGRect.zero)
        self.text = text
        self.textColor = textColor
        self.font = font
        self.textAlignment = textAlignment
        self.lineBreakMode = .byTruncatingTail
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SyMarqueeLabel: MarqueeLabel {
    
    override init(frame: CGRect, duration: CGFloat, fadeLength fade: CGFloat) {
        super.init(frame: frame, duration: duration, fadeLength: fade)
    }
    
    convenience init(text: String,
                     textColor: UIColor,
                     font: UIFont,
                     textAlignment: NSTextAlignment) {
        self.init(frame: CGRect.zero, duration: 25.0, fadeLength: 10)
        self.text = text
        self.textColor = textColor
        self.font = font
        self.textAlignment = textAlignment
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
