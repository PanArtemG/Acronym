import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    let acronymsContoller = AcronymsController()
    try router.register(collection: acronymsContoller)
}
