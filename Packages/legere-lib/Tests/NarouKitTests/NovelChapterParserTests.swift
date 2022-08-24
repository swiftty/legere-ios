import XCTest
import Domain
@testable import NarouKit

class NovelChapterParserTests: XCTestCase {
    func test_parse_id() throws {
        let result = try NovelChapter.parseSourceID("""
        <!--?xml version="1.0" encoding="UTF-8"?-->
        <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
        <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="ja" lang="ja">
            <head>
                <meta property="og:type" content="website"/>
                <meta property="og:title" content="title content"/>
                <meta property="og:url" content="https://ncode.syosetu.com/ncode/1/"/>
                <meta property="og:site_name" content="小説家になろう"/>
            </head>
        </html>
        """)

        XCTAssertEqual(result, .narou("ncode/1"))
    }

    func test_parse_title() throws {
        let result = try NovelChapter.parseTitle("""
        <body>
            <div>
                <div id="novel_contents">
                    <div>
                        <p class="novel_subtitle">あいうえお</p>
                        <p><br/></p>
                    </div>
                </div>
            </div>
        </body>
        """)

        XCTAssertEqual(result, "あいうえお")
    }

    func test_parse_honbun() throws {
        let result = try NovelChapter.parseHonbun("""
        <body>
            <div>
                <div id="novel_honbun" class="novel_view">
                    <p id="L1">あいうえお</p>
                    <p id="L2"><br/></p>
                    <p id="L3">
                        かきくけこ
                        <ruby>
                            <rb>漢字</rb>
                            <rt>かんじ</rt>
                        </ruby>
                        さしすせそ
                    </p>
                </div>
            </div>
        </body>
        """)

        XCTAssertEqual(result, [
            .body("あいうえお"),
            .br,
            .br,
            .br,
            .body("かきくけこ"),
            .ruby("かんじ", body: "漢字"),
            .body("さしすせそ"),
            .br
        ])
    }
}
