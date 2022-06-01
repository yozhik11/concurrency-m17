//
//  ViewController.swift
//  M17_Concurrency
//
//  Created by Maxim NIkolaev on 08.12.2021.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    let service = Service()
    
    var images = [UIImage]()
    
//    private lazy var imageView: UIImageView = {
////        let view = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
//        let view = UIImageView()
////        view.contentMode = .scaleAspectFit
//        return view
//    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .fillEqually
        view.spacing = 20
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        superView()
        onLoad()
    }
    
    private func onLoad() {
        let dispatchGroup = DispatchGroup()
        
        // Сборка массива картинок через другой поток

        let queue = DispatchQueue.global(qos: .utility)
        
        for _ in 0 ... 4 {
            dispatchGroup.enter()
            queue.async() {
                self.service.getImageURL { urlString, error in
                    guard let urlString = urlString else {return}
                    
                    guard let image = self.service.loadImage(urlString: urlString) else {return}
                    self.images.append(image)
                    dispatchGroup.leave()
                }
            }
        }
        
        // Вызов массива обратно, добавление в стэкВью
        dispatchGroup.notify(queue: DispatchQueue.main) { [weak self] in
            guard let self = self else {return}
            self.activityIndicator.stopAnimating()
            self.stackView.removeArrangedSubview(self.activityIndicator)
            for i in 0 ... 4 {
                self.addImage (image: self.images[i])
            }
        }
    }
    
    private func addImage (image: UIImage) {
        let newImageView = UIImageView(image: image)
        newImageView.contentMode = .scaleAspectFit
        self.stackView.addArrangedSubview(newImageView)
    }
    
    private func superView (){
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottomMargin)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin)
            make.left.right.equalToSuperview()
        }
        stackView.addArrangedSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
}

