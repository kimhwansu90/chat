import { createConsumer } from "@rails/actioncable"

// 현재 페이지 프로토콜에 맞게 wss:// 또는 ws:// 자동 결정
// meta tag 의존 없이 직접 URL 구성 (Railway 프록시 환경 호환)
export default createConsumer(function() {
  var protocol = (window.location.protocol === "https:") ? "wss:" : "ws:";
  return protocol + "//" + window.location.host + "/cable";
})
