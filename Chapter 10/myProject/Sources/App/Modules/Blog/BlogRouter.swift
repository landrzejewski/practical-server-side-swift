import Vapor

struct BlogRouter: RouteCollection {
    
    let frontendController = BlogFrontendController()
    let postAdminController = BlogPostAdminController()
    let categoryAdminController = BlogCategoryAdminController()
    
    func boot(routes: RoutesBuilder) throws {

        routes.get("blog", use: frontendController.blogView)
        routes.get(.anything, use: frontendController.postView)

        let protected = routes.grouped([
            UserModelSessionAuthenticator(),
            UserModel.redirectMiddleware(path: "/")
        ])
        let blog = protected.grouped("admin", "blog")
        
        postAdminController.setupRoutes(on: blog, as: "posts")
        categoryAdminController.setupRoutes(on: blog, as: "categories")
        
        let publicApi = routes.grouped("api", "blog")
        let privateApi = publicApi.grouped([
            UserTokenModel.authenticator(),
            UserModel.guardMiddleware(),
        ])
        
        let publicCategories = publicApi.grouped("categories")
        let privateCategories = privateApi.grouped("categories")
        let categoryApiController = BlogCategoryApiController()
        categoryApiController.setupListRoute(routes: publicCategories)
        categoryApiController.setupGetRoute(routes: publicCategories)
        
        categoryApiController.setupCreateRoute(routes: privateCategories)
        categoryApiController.setupUpdateRoute(routes: privateCategories)
        categoryApiController.setupPatchRoute(routes: privateCategories)
        categoryApiController.setupDeleteRoute(routes: privateCategories)
        
        let publicPosts = publicApi.grouped("posts")
        let privatePosts = privateApi.grouped("posts")
        let postsApiController = BlogPostApiController()
        postsApiController.setupListRoute(routes: publicPosts)
        postsApiController.setupGetRoute(routes: publicPosts)
        
        postsApiController.setupCreateRoute(routes: privatePosts)
        postsApiController.setupUpdateRoute(routes: privatePosts)
        postsApiController.setupPatchRoute(routes: privatePosts)
        postsApiController.setupDeleteRoute(routes: privatePosts)
    }
}
