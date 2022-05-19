//
//  GogolookExamTests.swift
//  GogolookExamTests
//
//  Created by ClydeHsieh on 2022/5/15.
//

import XCTest
@testable import GogolookExam

class GogolookExamTests: XCTestCase {
    typealias DataTuple = (NetworkManagerSpy<AnimeTopResponse>,FavoriteItemCacheService, ViewModel, ItemListViewController)
    
    func testItemListViewControllerMemoryLeak() {
        
        let (_, _, _, vc): DataTuple = makeSUT()
        addTeardownBlock { [weak vc] in
            XCTAssertNil(vc, "viewcontroller should have been deallocated. Potential memory leak", file: #filePath, line: #line)
        }
    }
    
    func test_viewDidLoad_didSetUpTableView() {
        let (_, _, _, vc): DataTuple = makeSUT()

        vc.loadViewIfNeeded()

        XCTAssertNotNil(vc.tableView.delegate)
        XCTAssertNotNil(vc.tableView.dataSource)
    }
    
    func test_viewDidLoad_didSetUpSegmentView() {
        let (_, _, _, vc): DataTuple = makeSUT()

        vc.loadViewIfNeeded()

        XCTAssertNotNil(vc.segmentView)
    }
    
    func test_didShowOptionSelectView() {
        let (_, _, _, vc): DataTuple = makeSUT()

        vc.loadViewIfNeeded()
        vc.didTapFilter()
        
        XCTAssertNotNil(vc.optionsSelectViewHolder)
    }
    
    func test_tableViewDatasourceCount() {
        let (_, _, _, vc): DataTuple = makeSUT()
        let mockResponse = self.makeMocAnimeResponse()
        vc.loadViewIfNeeded()
        vc.datasource = mockResponse.data
        XCTAssertEqual(vc.tableView.numberOfRows(inSection: 0), mockResponse.data.count)
        
        addTeardownBlock { [weak vc] in
            XCTAssertNil(vc, "viewcontroller should have been deallocated. Potential memory leak", file: #filePath, line: #line)
        }
    }
    
    func test_tableViewDatasourceLoadMoreCount() {
        let (networkManager, _, viewModel, vc): DataTuple = makeSUT()
        let queue = DispatchQueue(label: "FileLoaderTests")
        networkManager.mockResponse = self.makeMocAnimeResponse()
        
        let count = networkManager.mockResponse?.data.count ?? 0
        
        XCTAssertEqual(vc.tableView.numberOfRows(inSection: 0), 0)
        
        vc.loadViewIfNeeded()
        
        queue.asyncAfter(deadline: .now() + 0.5, execute: {
            viewModel.requestNextPageEvent.send(())
        })
        
        queue.asyncAfter(deadline: .now() + 1, execute: {
            XCTAssertEqual(vc.tableView.numberOfRows(inSection: 0), count * 2)
        })
    }
}

extension GogolookExamTests {
    func makeSUT<T: Decodable>() -> (networkManager: NetworkManagerSpy<T>,
                                     itemCacheService: FavoriteItemCacheService,
                                     viewModel: ViewModel,
                                     viewController: ItemListViewController) {
        
        let networkManager: NetworkManagerSpy<T> = .init()
        let coreDataStoreSpy = CoreDataStoreSpy()
        let itemCacheService = FavoriteItemCacheService(coreDataStore: coreDataStoreSpy)
        let viewMode = ViewModel(networkManager: networkManager, itemCacheService: itemCacheService)
        let viewController = ItemListViewController(viewModel: viewMode)
        
        return (networkManager, itemCacheService, viewMode, viewController)
    }
    
    func makeMocAnimeResponse() -> AnimeTopResponse {
        func mockAired() -> Aired {
            .init(from: .now, to: .now.addingTimeInterval(-50))
        }
        let iamge: Image = .init(imageURL: "", smallImageURL: "", largeImageURL: "")
        
        let data1: AnimeData = .init(malID: 0, title: "title0", url: "url0", images: ["key": iamge], aired: mockAired() , rank: 0)
        let data2: AnimeData = .init(malID: 1, title: "title1", url: "url1", images: ["key": iamge], aired: mockAired() , rank: 0)
        
        let items: Items = .init(count: 10, total: 10, perPage: 10)
        let page: Pagination = .init(lastVisiblePage: 1, hasNextPage: true, currentPage: 1, items: items)
        let mockResponse: AnimeTopResponse = .init(data: [data1, data2], pagination: page)
        
        return mockResponse
    }
}
