import Flutter
import UIKit
import XCTest

@testable import appactor_flutter

class RunnerTests: XCTestCase {

  func testExecuteWithValidArgs() {
    let plugin = AppActorFlutterPlugin()
    let call = FlutterMethodCall(
      methodName: "execute",
      arguments: ["method": "get_sdk_version", "json": "{}"]
    )

    let resultExpectation = expectation(description: "result block must be called.")
    plugin.handle(call) { result in
      XCTAssertFalse(result is FlutterMethodNotImplemented)
      resultExpectation.fulfill()
    }
    waitForExpectations(timeout: 5)
  }

  func testUnknownMethodReturnsNotImplemented() {
    let plugin = AppActorFlutterPlugin()
    let call = FlutterMethodCall(methodName: "getPlatformVersion", arguments: [])

    let resultExpectation = expectation(description: "result block must be called.")
    plugin.handle(call) { result in
      XCTAssertTrue(result is FlutterMethodNotImplemented)
      resultExpectation.fulfill()
    }
    waitForExpectations(timeout: 1)
  }

  func testExecuteMissingMethodArg() {
    let plugin = AppActorFlutterPlugin()
    let call = FlutterMethodCall(methodName: "execute", arguments: ["json": "{}"])

    let resultExpectation = expectation(description: "result block must be called.")
    plugin.handle(call) { result in
      XCTAssertTrue(result is FlutterMethodNotImplemented)
      resultExpectation.fulfill()
    }
    waitForExpectations(timeout: 1)
  }
}
