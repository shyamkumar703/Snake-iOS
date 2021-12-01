//
//  ViewController.swift
//  Snake
//
//  Created by Shyam Kumar on 11/14/21.
//

import UIKit

class ViewController: UIViewController, GameDelegate {
    
    override var prefersStatusBarHidden: Bool {
        true
    }
    
    var currentMove: Move? = nil
    
    lazy var boardView: BoardView = {
        let view = BoardView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()
    
    lazy var scoreLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        label.text = "\(score)"
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 16)
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupView()
        setupConstraints()
    }
    
    func setupView() {
        view.backgroundColor = .white
        view.addSubview(boardView)
        view.addSubview(scoreLabel)
        
        // Gestures
        let right = UISwipeGestureRecognizer(target: self, action: #selector(swipeDetected))
        right.direction = .right
        view.addGestureRecognizer(right)
        
        let left = UISwipeGestureRecognizer(target: self, action: #selector(swipeDetected))
        left.direction = .left
        view.addGestureRecognizer(left)
        
        let up = UISwipeGestureRecognizer(target: self, action: #selector(swipeDetected))
        up.direction = .up
        view.addGestureRecognizer(up)
        
        let down = UISwipeGestureRecognizer(target: self, action: #selector(swipeDetected))
        down.direction = .down
        view.addGestureRecognizer(down)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(restart))
        view.addGestureRecognizer(tap)
    }
    
    func setupConstraints() {
        boardView.constrainToSafeArea(superview: view, margin: 8)
        scoreLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 16).isActive = true
        scoreLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -24).isActive = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let safeAreaWidth = UIScreen.main.bounds.width - 16
        let safeAreaHeight = UIScreen.main.bounds.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom
        
        boardView.model.wHPair = (safeAreaWidth, safeAreaHeight)
    }
    
    @objc func swipeDetected(gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case .right:
            currentMove = .right
        case .left:
            currentMove = .left
        case .up:
            currentMove = .up
        case .down:
            currentMove = .down
        default:
            break
        }
    }
    
    func updateScore() {
        scoreLabel.text = "\(score)"
    }
    
    @objc func restart() {
        boardView.restart()
    }
}
