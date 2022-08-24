import XCTest
import Domain
@testable import NarouKit

class RankingParserTests: XCTestCase {
    func test_parse_ranking() throws {
        let result = try [RankingItem].load(fromHTML: """
        <body>
            <div>
                <div class="ranking_inbox">
                    <div class="ranking_list">
                        <div class="rank_h">
                            <span class="ranking_number">1位</span>
                            <a class="tl" id="best1" target="_blank" href="https://ncode.syosetu.com/ncode/">あああああ</a>
                        </div>
                        <table class="rank_table">
                            <tr>
                                <td class="h_info" colspan="2">
                                    <a target="_blank" href="https://ncode.syosetu.com/novelview/infotop/ncode/info/">小説情報</a>
                                    ／作者：<a href="https://mypage.syosetu.com/11111/">auther name</a>
                                </td>
                            </tr>
                            <td class="ex">
                            あらすじ
                            あらすじ
                            </td>
                        </table>
                    </div>

                    <div class="ranking_list">
                        <div class="rank_h">
                            <span class="ranking_number">2位</span>
                            <a class="tl" id="best2" target="_blank" href="https://ncode.syosetu.com/ncode2/">いいいいい</a>
                        </div>
                        <table class="rank_table">
                            <tr>
                                <td class="h_info" colspan="2">
                                    <a target="_blank" href="https://ncode.syosetu.com/novelview/infotop/ncode/info/">小説情報</a>
                                    ／作者：<a href="https://mypage.syosetu.com/22222/">auther name2</a>
                                </td>
                            </tr>
                            <td class="ex">
                            あらすじ
                            あらすじ
                            222222
                            </td>
                        </table>
                    </div>
                </div>
            </div>
        </body>
        """)

        XCTAssertEqual(result, [
            .init(
                id: .narou("ncode"),
                title: "あああああ",
                story: "あらすじ あらすじ",
                auther: .init(id: .narou("11111"), name: "auther name")
            ),
            .init(
                id: .narou("ncode2"),
                title: "いいいいい",
                story: "あらすじ あらすじ 222222",
                auther: .init(id: .narou("22222"), name: "auther name2")
            )
        ])
    }
}
