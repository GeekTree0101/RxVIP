import RxSwift
import RxCocoa

protocol RepositoryShowRouterLogic: class {
    
    var dismiss: PublishRelay<RepositoryShowModels.Dismiss.ViewModel> { get }
}

protocol RepositoryShowDataPassing: class {
    
    var dataStore: RepositoryShowDataStore? { get }
}

class RepositoryShowRouter: RepositoryShowRouterLogic & RepositoryShowDataPassing {
    
    var dismiss: PublishRelay<RepositoryShowModels.Dismiss.ViewModel> = .init()
    
    var dataStore: RepositoryShowDataStore?
    
    func bind(to viewController: RepositoryShowController) -> Disposable {
        
        let disposeable = dismiss
            .subscribe(onNext: { [weak viewController] _ in
                viewController?.dismiss(animated: true, completion: nil)
            })
        
        return Disposables.create([disposeable])
    }
}
