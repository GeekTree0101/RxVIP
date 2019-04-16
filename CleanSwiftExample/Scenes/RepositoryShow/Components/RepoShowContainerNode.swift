import Foundation
import AsyncDisplayKit
import RxSwift
import RxCocoa
import RxCocoa_Texture

class RepoShowContainerNode: ASDisplayNode {
    
    struct Const {
        static let contentSpacing: CGFloat = 20.0
        
        static let pinButtonInsets: UIEdgeInsets =
            .init(top: .infinity, left: 80.0, bottom: 60.0, right: 80.0)
        
        static func containerInsets(_ safeAreaInsets: UIEdgeInsets) -> UIEdgeInsets {
            return .init(top: 80.0 + safeAreaInsets.top,
                         left: 40.0,
                         bottom: .infinity,
                         right: 40.0)
        }
        
        static func dismissInsets(_ safeAreaInsets: UIEdgeInsets) -> UIEdgeInsets {
            return .init(top: 30.0 + safeAreaInsets.top,
                         left: 30.0,
                         bottom: 0,
                         right: 0)
        }
    }
    
    let repoInfoContainerNode: ASScrollNode = {
        let node = ASScrollNode()
        
        node.automaticallyManagesSubnodes = true
        node.automaticallyManagesContentSize = true
        node.scrollableDirections = [.up, .down]
        return node
    }()
    
    let profileNode: ProfileNode = .init(scale: .large)
    let infoNode: InformationNode = .init(align: .center)
    
    let dismissButtonNode: ASButtonNode = {
        let node = ASButtonNode()
        node.setTitle("Dismiss",
                      with: UIFont.boldSystemFont(ofSize: 20.0),
                      with: UIColor.darkGray,
                      for: .normal)
        node.borderWidth = 2.0
        node.borderColor = UIColor.darkGray.cgColor
        node.cornerRadius = 8.0
        node.contentEdgeInsets =
            .init(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        return node
    }()
    
    let pinButtonNode = RepoShowPinneButtonNode.init()
    
    var disposeBag = DisposeBag()
    
    private let repoID: Int
    
    init(id: Int) {
        self.repoID = id
        super.init()
        self.automaticallyManagesSubnodes = true
        self.automaticallyRelayoutOnSafeAreaChanges = true
        self.backgroundColor = .white
        
        self.repoInfoContainerNode.layoutSpecBlock = { [weak self] (_, sizeRange) -> ASLayoutSpec in
            return self?.repoInfoContainerNodeLayoutSpec(sizeRange) ?? ASLayoutSpec()
        }
    }
    
    func bind(state: Observable<RepositoryShowModels.Show.ViewModel>) {
        
        state.map({ $0.profileURL })
            .distinctUntilChanged()
            .bind(to: profileNode.rx.url)
            .disposed(by: disposeBag)
        
        state.map({ $0.title })
            .distinctUntilChanged()
            .bind(to: self.infoNode.rx.title,
                  setNeedsLayout: infoNode)
            .disposed(by: disposeBag)
        
        state.map({ $0.desc })
            .distinctUntilChanged()
            .bind(to: self.infoNode.rx.subTitle,
                  setNeedsLayout: infoNode)
            .disposed(by: disposeBag)
        
        state.map({ $0.isPinned })
            .distinctUntilChanged()
            .bind(to: self.profileNode.rx.isPinned,
                  setNeedsLayout: self.profileNode)
            .disposed(by: disposeBag)
        
        state.map({ $0.isPinned })
            .distinctUntilChanged()
            .bind(to: self.pinButtonNode.rx.isSelected)
            .disposed(by: disposeBag)
    }
    
    func bind(action: RepositoryShowInteractorLogic) {
        
        self.pinButtonNode.rx.tap
            .withLatestFrom(Observable.just(self.repoID))
            .map({ .init(id: $0) })
            .bind(to: action.didTapPin)
            .disposed(by: disposeBag)
        
        self.dismissButtonNode.rx.tap
            .withLatestFrom(Observable.just(self.repoID))
            .map { .init(id: $0) }
            .bind(to: action.didTapDismissButton)
            .disposed(by: disposeBag)
    }
}

extension RepoShowContainerNode {
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let containerLayout = ASInsetLayoutSpec(insets: Const.containerInsets(self.safeAreaInsets),
                                                child: repoInfoContainerNode)
        
        let pinButtonLayout = ASInsetLayoutSpec(insets: Const.pinButtonInsets,
                                                child: pinButtonNode)
        
        let dismissInsetLayout = ASInsetLayoutSpec(insets: Const.dismissInsets(self.safeAreaInsets),
                                                   child: dismissButtonNode)
        
        let dismissButtonLayout = ASRelativeLayoutSpec(horizontalPosition: .start,
                                                       verticalPosition: .start,
                                                       sizingOption: [],
                                                       child: dismissInsetLayout)
        let pinButtonOverlayedContainerLayout =
            ASOverlayLayoutSpec(child: containerLayout,
                                overlay: pinButtonLayout)
        
        return ASOverlayLayoutSpec(child: pinButtonOverlayedContainerLayout,
                                   overlay: dismissButtonLayout)
    }
    
    private func repoInfoContainerNodeLayoutSpec(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        infoNode.style.flexShrink = 1.0
        infoNode.style.flexGrow = 1.0
        
        return ASStackLayoutSpec(direction: .vertical,
                                 spacing: Const.contentSpacing,
                                 justifyContent: .center,
                                 alignItems: .center,
                                 children: [profileNode, infoNode])
    }
}
