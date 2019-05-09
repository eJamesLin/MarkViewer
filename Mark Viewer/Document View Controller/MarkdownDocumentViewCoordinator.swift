//
//  MarkdownDocumentViewCoordinator.swift
//  Mark Viewer
//
//  Created by Nelson Dai on 2019/5/8.
//  Copyright © 2019 Nelson Tai. All rights reserved.
//

import UIKit
import SafariServices

protocol MarkdownDocumentViewCoordinatorDelegate: AnyObject {
    func coordinatorDidFinish(_ coordinator: MarkdownDocumentViewCoordinator)
}

final class MarkdownDocumentViewCoordinator: UIViewController {
    private var document: MarkdownDocument!
    private var nav: UINavigationController!
    private var browserTransition: MarkdownDocumentBrowserTransitioningDelegate?

    weak var delegate: MarkdownDocumentViewCoordinatorDelegate?
    var transitionController: UIDocumentBrowserTransitionController? {
        didSet {
            if let controller = transitionController {
                modalPresentationStyle = .custom
                browserTransition = MarkdownDocumentBrowserTransitioningDelegate(withTransitionController: controller)
                transitioningDelegate = browserTransition
            } else {
                modalPresentationStyle = .none
                browserTransition = nil
                transitioningDelegate = nil
            }
        }
    }

    init(document: MarkdownDocument) {
        self.document = document
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let vc = MarkdownDocumentViewController()
        vc.document = document
        vc.delegate = self

        nav = UINavigationController(rootViewController: vc)
        addChild(nav)
        view.addSubview(nav.view)
        nav.didMove(toParent: self)

        let doneItem = createDoneItem()
        vc.navigationItem.rightBarButtonItem = doneItem
    }

    private func createDoneItem() -> UIBarButtonItem {
        let item = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        return item
    }

    @objc private func done() {
        delegate?.coordinatorDidFinish(self)
    }
}

extension MarkdownDocumentViewCoordinator: MarkdownDocumentViewControllerDelegate {
    func documentViewController(_ viewController: MarkdownDocumentViewController, didClickOn url: URL) {
        let safari = SFSafariViewController(url: url)
        nav.present(safari, animated: true, completion: nil)
    }
}
