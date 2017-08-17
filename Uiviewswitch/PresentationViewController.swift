//
//  presentationViewController.swift
//  Uiviewswitch
//
//  Created by Daniel Hjärtström on 2016-11-30.
//  Copyright © 2016 Daniel Hjärtström. All rights reserved.
//

import UIKit

enum TypeOfView {

    case initial
    case forward
    case backward

}

class PresentationViewController: UIViewController {

    let questionsArray = Singleton.sharedInstance.questions
    var displayedView: UIView?
    let animationManager: AnimationManager = AnimationManager()
    var canChangeView: Bool = true
    var index: Int = 0 {
    
        didSet {
        
            self.navigationItem.title = "Question \(index+1)"
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        let view = returnViewOfType(type: .initial)
        self.view.addSubview(view)
        displayedView = view
      
        let leftSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeToNavigate(gesture:)))
        leftSwipeRecognizer.direction = .left
        let rightSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeToNavigate(gesture:)))
        rightSwipeRecognizer.direction = .right
        
        self.view.addGestureRecognizer(leftSwipeRecognizer)
        self.view.addGestureRecognizer(rightSwipeRecognizer)
        
    }
    
    func didSwipeToNavigate(gesture: UISwipeGestureRecognizer) {
        
        if (gesture.direction == .left){
            
            navigateForward()
            
        }
        
        if (gesture.direction == .right){
            
            navigateBack()
            
        }
        
    }
    
    func returnViewOfType(type: TypeOfView) -> UIView {
        
        let frame: CGRect
        let question = questionsArray[index]
        
        switch type {
        
        case .initial:
            
            frame = CGRect(x: 25, y: 60, width: self.view.frame.width - 50, height: self.view.frame.height - 200)
        
        case .forward:
            
            frame = CGRect(x: self.view.frame.width, y: 60, width: self.view.frame.width - 50, height: self.view.frame.height - 200)
            
        case .backward://Fix constraints
            
            frame = CGRect(x: -self.view.frame.width, y: 60, width: self.view.frame.width - 50, height: self.view.frame.height - 200)
            
        }
        
        return PresentationView(frame: frame, question: question)
    }
    
    
    @IBAction func back(_ sender: UIBarButtonItem) {
        navigateBack()
    }
    
    @IBAction func forward(_ sender: UIBarButtonItem) {
        navigateForward()
    }
    
    func navigateBack() {
    
        if canChangeView {
            
            index -= 1
            
            if self.navigationItem.rightBarButtonItem?.isEnabled == false  {
                
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                
            }
            
            if index > -1 {
                
                navigationHandler(viewType: .backward, viewToRemoveEndPosition: self.view.frame.width + (self.displayedView?.frame.width)!, viewToAddEndPosition: self.displayedView!.frame.width / 2 + 25)
                
            }
                
            else {
                
                unwind()
                
            }
        }
    }
    
    func navigateForward() {
    
        if canChangeView {
            
            index += 1
            
            if index == questionsArray.count - 1 {
                
                self.navigationItem.rightBarButtonItem?.isEnabled = false
                
            }
            
            if index < questionsArray.count {
                
                navigationHandler(viewType: .forward, viewToRemoveEndPosition: -self.view.frame.width, viewToAddEndPosition: self.displayedView!.frame.width / 2 + 25)
                
            }
        }
    }
    
    func navigationHandler(viewType: TypeOfView, viewToRemoveEndPosition: CGFloat, viewToAddEndPosition: CGFloat) {
    
        self.canChangeView = false
        
        let view = returnViewOfType(type: viewType)
        self.view.addSubview(view)
        
        animationManager.animate(view: self.displayedView!, time: 0.5, animateTo: viewToRemoveEndPosition) {
         
            self.displayedView?.removeFromSuperview()
            self.displayedView = view
            
            self.animationManager.animateWithSpring(view: self.displayedView!, time: 1, animateTo: viewToAddEndPosition)
            
            self.canChangeView = true
        }
    }

    @IBAction func goBack(_ sender: UILongPressGestureRecognizer) {
        unwind()
    }
    
    func unwind() {
        self.performSegue(withIdentifier: "unwindToMenu", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
}
