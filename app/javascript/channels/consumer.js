import { createConsumer } from "@rails/actioncable"

function getCableUrl() {
  // 1. action_cable_meta_tag에서 URL 가져오기
  var meta = document.querySelector('meta[name="action-cable-url"]');
  if (meta && meta.getAttribute("content")) {
    return meta.getAttribute("content");
  }

  // 2. 현재 페이지 프로토콜에 맞게 wss:// 또는 ws:// 자동 결정
  var protocol = (window.location.protocol === "https:") ? "wss:" : "ws:";
  return protocol + "//" + window.location.host + "/cable";
}

export default createConsumer(getCableUrl)
