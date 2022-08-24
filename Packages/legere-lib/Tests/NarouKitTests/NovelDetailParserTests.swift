import XCTest
import Domain
@testable import NarouKit

class NovelDetailParserTests: XCTestCase {
    func test_parse_title() throws {
        let result = try NovelDetail.parseTitle("""
        <body>
            <div>
                <div id="novel_contents">
                    <div>
                        <p class="novel_title">あいうえお</p>
                        <p><br/></p>
                    </div>
                </div>
            </div>
        </body>
        """)

        XCTAssertEqual(result, "あいうえお")
    }

    func test_parse_story() throws {
        let result = try NovelDetail.parseStory("""
        <body>
            <div>
                <div id="novel_contents">
                    <div>
                        <div id="novel_ex">
                        あいうえお<br/>
                        <br/>
                        かきくけこ
                        </div>
                    </div>
                </div>
            </div>
        </body>
        """)

        XCTAssertEqual(result, "あいうえお\n\nかきくけこ")
    }

    func test_parse_auther() throws {
        let result = try NovelDetail.parseAuther("""
        <body>
            <div>
                <div id="novel_contents">
                    <div>
                        <div class="novel_writername">
                            作者：<a href="https://mypage.syosetu.com/1000000/">auther auther</a>
                        </div>
                    </div>
                </div>
            </div>
        </body>
        """)

        XCTAssertEqual(result, .init(id: .narou("1000000"), name: "auther auther"))
    }

    func test_parse_index() throws {
        let result = try NovelDetail.parseIndex("""
        <body>
            <div>
                <div class="index_box">
                    <dl class="novel_sublist2">
                        <dd class="subtitle">
                            <a href="/ncode/1/">chapter 1</a>
                        </dd>
                        <dt class="long_update">
                            2022/07/30 09:17
                            <span title="2022/08/04 07:06 改稿">
                                （<u>改</u>）
                            </span>
                        </dt>
                    </dl>
                    <dl class="novel_sublist2">
                        <dd class="subtitle">
                            <a href="/ncode/2/">chapter 2</a>
                        </dd>
                        <dt class="long_update">
                            2022/07/30 09:23
                            <span title="2022/07/30 14:13 改稿">
                                （<u>改</u>）
                            </span>
                        </dt>
                    </dl>
                </div>
            </div>
        </body>
        """)

        XCTAssertEqual(result, [
            .init(id: .narou("ncode/1"), title: "chapter 1"),
            .init(id: .narou("ncode/2"), title: "chapter 2")
        ])
    }
}
