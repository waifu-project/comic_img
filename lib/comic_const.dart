/// 这个ID之前的都是 [kLowChunkDepDefaultNum]
const kLowChunkDepID = 268850;

/// 若小于这个ID的话应该不需要解析
const kScrambleId = 220980;

/// 这个ID之前的默认的切割都是 [10]
const kLowChunkDepDefaultNum = 10;

final List<int> kChunkNumMap = [
  2,
  4,
  6,
  8,
  10,
  12,
  14,
  16,
  18,
  20,
];

const kNetworkImageUrlTemplate =
    "https://cdn-msp.18comic.vip/media/photos/id/pid";

const kNetworkImageHeader = {
  "user-agent":
      "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36",
  "referer": "https://18comic.org",
};
