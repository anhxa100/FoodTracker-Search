//
//  RatingControll.swift
//  foodtracker
//
//  Created by anhxa100 on 8/28/18.
//  Copyright © 2018 anhxa100. All rights reserved.
//

import UIKit

@IBDesignable
class RatingControl: UIStackView {
    
    
    @IBInspectable var starSize: CGSize = CGSize(width: 44.0, height: 44.0) {
        didSet {
            setupButtons()
        }
    }
    
    
    @IBInspectable var starCount: Int = 5 {
        didSet {
            setupButtons()
        }
    }
    
    
    private  var rattingButtons = [UIButton]()
    
    var rating = 0 {
        didSet {
            updateButtonSelectionStates()
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }
    
    
    required init(coder: NSCoder) {
        
        super.init(coder: coder)
        setupButtons()
    }
    
    
    private func setupButtons(){
        
        for button in rattingButtons {
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        rattingButtons.removeAll()
        
        // Load Button Image
        let bundle = Bundle(for: type(of: self))
        let filledStar = UIImage(named: "filledStar", in: bundle, compatibleWith: self.traitCollection)
        let emptyStar = UIImage(named:"emptyStar", in: bundle, compatibleWith: self.traitCollection)
        let highlightedStar = UIImage(named:"highlightedStar", in: bundle, compatibleWith: self.traitCollection)
        
        
        for index in 0..<starCount {
            let button = UIButton()
//            button.backgroundColor = UIColor.red
            button.setImage(emptyStar, for: .normal)
            button.setImage(filledStar, for: .selected)
            button.setImage(highlightedStar, for: .highlighted)
            button.setImage(highlightedStar, for: [.highlighted, .selected])
            
            //Add constraints
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
            button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
            
            
            //Add the button to the stack
            addArrangedSubview(button)
            rattingButtons.append(button)
            
            // Set the accessibility label
            button.accessibilityLabel = "Set \(index + 1) star rating"

            //Setup button action
            button.addTarget(self, action: #selector(RatingControl.rattingButtonTapped(button:)), for: .touchUpInside)
        }
        
        updateButtonSelectionStates()
        
    }
    
    @objc func rattingButtonTapped(button: UIButton) {
        
        guard let index = rattingButtons.index(of: button) else {
            fatalError("The button, \(button), is not in the ratingButtons array: \(rattingButtons) ")
        }
        let selectedRating = index + 1
        if selectedRating == rating {
            rating = 0
        }else{
            rating = selectedRating
        }
        
        
        //            print("Button pressed 🐀")
        
        
    }
    
    
    
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
    private func updateButtonSelectionStates() {
        for (index, button) in rattingButtons.enumerated() {
            button.isSelected = index < rating
            let hintString: String?
            if rating == index + 1 {
                hintString = "An de reset rating ve 0"
            }else{
                hintString = nil
            }
            
            let valueString: String
            switch (rating) {
            case 0:
                valueString = "No rating set."
            case 1:
                valueString = "1 star set."
            default:
                valueString =  "\(rating) stars set."
                
            }
            button.accessibilityHint = hintString
            button.accessibilityValue = valueString
            
        }
        
    }
}
