//
//  SquareView.swift
//  Snake
//
//  Created by Shyam Kumar on 11/14/21.
//

import UIKit

enum SquareType {
    case snake
    case empty
    case food
    case obstacle
}

struct SquareViewModel {
    var type: SquareType
    
    init(type: SquareType = .empty) {
        self.type = type
    }
}

class SquareView: UIView {
    
    lazy var food : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 10).isActive = true
        view.widthAnchor.constraint(equalToConstant: 10).isActive = true
        view.layer.cornerRadius = 5
        view.backgroundColor = .systemGreen
        view.alpha = 0
        return view
    }()
    
    var model = SquareViewModel() {
        didSet {
            updateView()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        backgroundColor = .clear
        addSubview(food)
    }
    
    func setupConstraints() {
        food.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        food.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    func updateView() {
        switch model.type {
        case .snake:
            food.alpha = 0
            backgroundColor = .black
        case .empty:
            food.alpha = 0
            backgroundColor = .clear
        case .food:
            food.alpha = 1
        case .obstacle:
            food.alpha = 0
            backgroundColor = .red
        }
    }
}
