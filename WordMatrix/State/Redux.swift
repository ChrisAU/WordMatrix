import Foundation
import RxSwift
import RxSwiftExt

protocol Action {
    func asObservable() -> Observable<Action>
}

typealias Middleware<T: State> = (T, Action) -> Void

typealias Reducer<T: State> = (T, Action) -> T

protocol State { }

struct Store<T: State> {
    private let actionSubject = BehaviorSubject<Action?>(value: nil)
    private let stateObservable: Observable<T>
    private let bag = DisposeBag()
    
    init(state: T,
         reducer: @escaping Reducer<T>,
         middleware: [Middleware<T>]) {
        stateObservable = actionSubject
            .unwrap()
            .observeOn(MainScheduler.asyncInstance)
            .scan(state, accumulator: reducer)
            .share()
        Observable
            .zip(stateObservable, actionSubject.unwrap())
            .subscribeOn(SerialDispatchQueueScheduler(qos: .userInitiated))
            .subscribe(onNext: { (state, action) in middleware.forEach { $0(state, action) } })
            .disposed(by: bag)
    }
    
    func fire(_ action: Action) {
        action
            .asObservable()
            .subscribeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: actionSubject.onNext)
            .disposed(by: bag)
    }
    
    func observe() -> Observable<T> {
        return stateObservable
    }
    
    subscript<U>(_ keyPath: KeyPath<T, U>) -> Observable<U> {
        return observe().map(keyPath)
    }
    
    subscript<U: Equatable>(_ keyPath: KeyPath<T, U>) -> Observable<U> {
        return observe().map(keyPath).distinctUntilChanged()
    }
    
    subscript<U: Equatable>(_ keyPath: KeyPath<T, [U]>) -> Observable<[U]> {
        return observe().map(keyPath).distinctUntilChanged(==)
    }
}

extension Action {
    func asObservable() -> Observable<Action> { return Observable<Action>.just(self) }
}

extension Array: Action where Element == Action {
    func asObservable() -> Observable<Action> { return Observable<Action>.concat(map { $0.asObservable() }) }
}

extension Observable: Action where Element == Action {
    func asObservable() -> Observable<Action> { return map { $0 as Action } }
}

extension ObservableConvertibleType {
    func map<T>(_ keyPath: KeyPath<E, T>) -> Observable<T> {
        return asObservable().map { $0[keyPath: keyPath] }
    }
}
