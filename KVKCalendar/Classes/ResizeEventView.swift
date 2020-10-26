//
//  ResizeEventView.swift
//  KVKCalendar
//
//  Created by Sergei Kviatkovskii on 24.10.2020.
//

import UIKit

final class ResizeEventView: UIView {
    
    enum ResizeEventViewType: Int {
        case top, bottom
        
        var tag: Int {
            return rawValue
        }
    }
    
    weak var delegate: ResizeEventViewDelegate?
    
    private let event: Event
    private let mainHeightOffset: CGFloat = 30
    private let mainYOffset: CGFloat = 15
    
    private lazy var eventView: UIView = {
        let view = UIView()
        view.backgroundColor = event.color?.value ?? event.backgroundColor
        return view
    }()
    
    private lazy var topView = createPanView(type: .top)
    private lazy var bottomView = createPanView(type: .bottom)
    
    let originalFrameEventView: CGRect
    
    private func createPanView(type: ResizeEventViewType) -> UIView {
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: mainYOffset)))
        view.backgroundColor = .clear
        view.tag = type.tag
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(trackGesture))
        view.addGestureRecognizer(gesture)

        return view
    }
    
    private func createCircleView() -> UIView {
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 8, height: 8)))
        view.backgroundColor = .white
        view.layer.borderWidth = 2
        view.layer.borderColor = event.color?.value.cgColor ?? event.backgroundColor.cgColor
        view.setRoundCorners(radius: CGSize(width: 4, height: 4))
        return view
    }
    
    init(view: UIView, event: Event, frame: CGRect) {
        self.event = event
        self.originalFrameEventView = frame
        var newFrame = frame
        newFrame.origin.y -= mainYOffset
        newFrame.size.height += mainHeightOffset
        super.init(frame: newFrame)
        backgroundColor = .clear
        
        eventView.frame = CGRect(origin: CGPoint(x: 0, y: mainYOffset), size: CGSize(width: frame.width, height: frame.height))
        addSubview(eventView)
        
        view.frame = CGRect(origin: .zero, size: eventView.frame.size)
        eventView.addSubview(view)
        
        topView.frame.origin = CGPoint(x: frame.width * 0.8, y: mainYOffset * 0.5)
        addSubview(topView)
        
        bottomView.frame.origin = CGPoint(x: (frame.width * 0.2) - bottomView.frame.width, y: frame.height + (mainYOffset * 0.5))
        addSubview(bottomView)
        
        let topCircleView = createCircleView()
        topCircleView.frame.origin = CGPoint(x: (topView.frame.width * 0.5) - 4, y: topView.frame.height * 0.5 - 4)
        topView.addSubview(topCircleView)
        
        let bottomCircleView = createCircleView()
        bottomCircleView.frame.origin = CGPoint(x: (bottomView.frame.width * 0.5) - 4, y: bottomView.frame.height * 0.5 - 4)
        bottomView.addSubview(bottomCircleView)
    }
    
    func updateHeight() {
        bottomView.frame.origin.y = (frame.height - mainHeightOffset) + (mainYOffset * 0.5)
        eventView.frame.size.height = frame.height - mainHeightOffset
        eventView.subviews.forEach({ $0.frame.size.height = frame.height - mainHeightOffset })
    }
    
    @objc private func trackGesture(gesture: UIPanGestureRecognizer) {
        guard let tag = gesture.view?.tag, let type = ResizeEventViewType(rawValue: tag) else { return }
        
        switch gesture.state {
        case .changed:
            delegate?.didStart(gesture: gesture, type: type)
        case .cancelled, .failed, .ended:
            delegate?.didEnd(gesture: gesture, type: type)
        default:
            break
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

protocol ResizeEventViewDelegate: class {
    func didStart(gesture: UIPanGestureRecognizer, type: ResizeEventView.ResizeEventViewType)
    func didEnd(gesture: UIPanGestureRecognizer, type: ResizeEventView.ResizeEventViewType)
    func didStartMoveResizeEvent(_ event: Event, gesture: UIPanGestureRecognizer, view: UIView)
    func didEndMoveResizeEvent(_ event: Event, gesture: UIPanGestureRecognizer)
    func didChangeMoveResizeEvent(_ event: Event, gesture: UIPanGestureRecognizer)
}