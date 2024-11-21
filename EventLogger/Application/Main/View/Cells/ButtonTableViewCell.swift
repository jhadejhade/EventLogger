//
//  ButtonTableViewCell.swift
//  EventLogger
//
//  Created by Jade Lapuz on 11/21/24.
//

import UIKit

protocol ButtonTableViewCellDelegate: AnyObject {
    func trackEvent(_ cell: ButtonTableViewCell, with buttonData: ButtonData, for event: ButtonEvent)
}

class ButtonTableViewCell: UITableViewCell {

    @IBOutlet weak var eventButton: UIButton!
    
    weak var delegate: ButtonTableViewCellDelegate?
    
    var buttonData: ButtonData?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        if let gestureRecognizers = eventButton.gestureRecognizers {
            for recognizer in gestureRecognizers {
                eventButton.removeGestureRecognizer(recognizer)
            }
        }
    }

    func setup(with buttonData: ButtonData) {
        self.buttonData = buttonData
        
        eventButton.setTitle(buttonData.title, for: .normal)
        eventButton.tag = buttonData.id
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(singleTapDetected))
        tapGesture.numberOfTapsRequired = 1
        eventButton.addGestureRecognizer(tapGesture)
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapDetected))
        doubleTapGesture.numberOfTapsRequired = 2
        eventButton.addGestureRecognizer(doubleTapGesture)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressDetected))
        eventButton.addGestureRecognizer(longPressGesture)
        
        tapGesture.require(toFail: doubleTapGesture)
    }
    
    @objc func singleTapDetected() {
        guard let buttonData else {
            return
        }
        
        delegate?.trackEvent(self, with: buttonData, for: .tap)
    }
    
    @objc func doubleTapDetected() {
        guard let buttonData else {
            return
        }
        
        delegate?.trackEvent(self, with: buttonData, for: .doubleTap)
    }
    
    @objc func longPressDetected(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            guard let buttonData else {
                return
            }
            
            delegate?.trackEvent(self, with: buttonData, for: .longPress)
        }
    }
}
