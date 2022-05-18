//
//  ApiServiceTest.swift
//  GogolookExamTests
//
//  Created by ClydeHsieh on 2022/5/18.
//

import XCTest
import Combine
@testable import GogolookExam

class ApiServiceTest: XCTestCase {

    let animeRequest: PassthroughSubject<ItemRequestType, Error> = .init()
    let mangaRequest: PassthroughSubject<ItemRequestType, Error> = .init()
    
    var subscription: Set<AnyCancellable> = .init()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testAnimeApiFlow() {
        let (response, _, service, viewModel) = makeAnimeSUT()
        
        var predictResponse: AnimeTopResponse?
        
        viewModel.binding(fetchAnime: animeRequest.eraseToAnyPublisher())
            .sink { completion in
                //
            } receiveValue: { endResponse in
                predictResponse = endResponse
            }
            .store(in: &subscription)

        
        animeRequest.send(ItemReqeustTypeSpy())
        
        XCTAssertEqual(service.fetchAnimeDataCounter, 1)
        XCTAssertEqual(predictResponse?.data.count, response.data.count)
        
        addTeardownBlock { [weak service, weak viewModel] in
            XCTAssertNil(service, "service should have been deallocated. Potential memory leak", file: #filePath, line: #line)
            XCTAssertNil(viewModel, "viewModel should have been deallocated. Potential memory leak", file: #filePath, line: #line)
        }
    }
    
    func testMangaApiFlow() {
        let (_, response, service, viewModel) = makeAnimeSUT()
        var predictResponse: MangaTopResponse?
        
        viewModel.binding(fetchManga: mangaRequest.eraseToAnyPublisher())
            .sink { completion in
                //
            } receiveValue: { endResponse in
                predictResponse = endResponse
            }
            .store(in: &subscription)
        
        mangaRequest.send(ItemReqeustTypeSpy())
        mangaRequest.send(ItemReqeustTypeSpy())
        
        XCTAssertEqual(service.fetchAnimeDataCounter, 0)
        XCTAssertEqual(service.fetchMangaDataCounter, 2)
        XCTAssertEqual(predictResponse?.data.count, response.data.count)
        
        addTeardownBlock { [weak service, weak viewModel] in
            XCTAssertNil(service, "service should have been deallocated. Potential memory leak", file: #filePath, line: #line)
            XCTAssertNil(viewModel, "viewModel should have been deallocated. Potential memory leak", file: #filePath, line: #line)
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}

extension ApiServiceTest {
    func makeAnimeSUT() -> (animeResponse: AnimeTopResponse, mangaResponse: MangaTopResponse, service: ItemApiServiceTest, viewModel: ViewModelTest) {
        let animeResponse = makeMocAnimeResponse()
        let mangaResponse = makeMocMangaResponse()
        
        let service = ItemApiServiceTest(animeResponse: animeResponse, mangaResponse: mangaResponse)
        
        let viewModel = ViewModelTest(animeService: service, mangaService: service)
        
        return (animeResponse, mangaResponse, service, viewModel)
    }
    
    func makeMocAnimeResponse() -> AnimeTopResponse {
        func mockAired() -> Aired {
            .init(from: .now, to: .now.addingTimeInterval(-50))
        }
        let iamge: Image = .init(imageURL: "", smallImageURL: "", largeImageURL: "")
        
        let data1: AnimeData = .init(malID: 0, title: "title0", url: "url0", images: ["key": iamge], aired: mockAired() , rank: 0)
        let data2: AnimeData = .init(malID: 1, title: "title1", url: "url1", images: ["key": iamge], aired: mockAired() , rank: 0)
        
        let items: Items = .init(count: 10, total: 10, perPage: 10)
        let page: Pagination = .init(lastVisiblePage: 1, hasNextPage: false, currentPage: 1, items: items)
        let mockResponse: AnimeTopResponse = .init(data: [data1, data2], pagination: page)
        
        return mockResponse
    }
    
    func makeMocMangaResponse() -> MangaTopResponse {
        let iamge: Image = .init(imageURL: "", smallImageURL: "", largeImageURL: "")
        
        let data1: MangaData = .init(malID: 0, title: "title0", url: "url0", images: ["key": iamge], published: .init(from: .now, to:.now) , rank: 0)
        let data2: MangaData = .init(malID: 1, title: "title1", url: "url1", images: ["key": iamge], published: .init(from: .now, to:.now) , rank: 0)
        
        let items: Items = .init(count: 10, total: 10, perPage: 10)
        let page: Pagination = .init(lastVisiblePage: 1, hasNextPage: false, currentPage: 1, items: items)
        let mockResponse: MangaTopResponse = .init(data: [data1, data2], pagination: page)
        
        return mockResponse
    }
}

//MARK:
struct ItemReqeustTypeSpy: ItemRequestType {
    var type: String? = "type"
    var filter: String? = "filter"
    var page: Int  = 1
}

//MARK: - ItemApiServiceTest
class ItemApiServiceTest {
    var fetchAnimeDataCounter = 0
    var fetchMangaDataCounter = 0
    
    let animeMonckResponse: AnimeTopResponse
    let mangaMonckResponse: MangaTopResponse
    
    init(animeResponse: AnimeTopResponse, mangaResponse: MangaTopResponse){
        self.animeMonckResponse = animeResponse
        self.mangaMonckResponse = mangaResponse
    }
}

extension ItemApiServiceTest: AnimeApiServiceType {
    func fetchTop(param: ItemRequestType) -> AnyPublisher<AnimeTopResponse, Error> {
        return Deferred {
            Future { [unowned self] promise in
                self.fetchAnimeDataCounter += 1
                promise(.success(self.animeMonckResponse))
            }
        }.eraseToAnyPublisher()
    }
}

extension ItemApiServiceTest: MangaApiServiceType {
    func fetchTop(param: ItemRequestType) -> AnyPublisher<MangaTopResponse, Error> {
        return Deferred {
            Future { [unowned self] promise in
                self.fetchMangaDataCounter += 1
                promise(.success(self.mangaMonckResponse))
            }
        }.eraseToAnyPublisher()
    }
}

//MARK: ServiceErrorTest
enum ServiceErrorTest: Error {
    case animeApiFail
    case mangaApiFail
    case fetchLocalFail
}

//MARK: ViewModelTest
class ViewModelTest: ViewModelType {
    let animeService: AnimeApiServiceType
    let mangaService: MangaApiServiceType
    
    init(animeService: AnimeApiServiceType, mangaService: MangaApiServiceType) {
        self.animeService = animeService
        self.mangaService = mangaService
    }
    
    func binding(fetchAnime: AnyPublisher<ItemRequestType, Error>) -> AnyPublisher<AnimeTopResponse, Error> {
        fetchAnime
            .flatMapLatest({ [unowned self]request in
                self.animeService.fetchTop(param: request)
            })
            .eraseToAnyPublisher()
    }
    
    func binding(fetchManga: AnyPublisher<ItemRequestType, Error>) -> AnyPublisher<MangaTopResponse, Error> {
        fetchManga
            .flatMapLatest({ [unowned self]request in
                self.mangaService.fetchTop(param: request)
            })
            .eraseToAnyPublisher()
    }
    
    func binding(fetchFavorite: AnyPublisher<Void, Error>) -> AnyPublisher<[FavoriteItem], Error> {
        return Deferred {
            Future { promise in
                promise(.failure(ServiceErrorTest.fetchLocalFail))
            }
        }.eraseToAnyPublisher()
    }
    
    
}
