import OpenCC

class UtilitiesPerfect: UtilitiesProtocol {
    var openccS2T: OpenCC
    var openccT2S: OpenCC

    init?() {
        guard let s2t = OpenCC(configFile: "s2t.json") else {
            return nil
        }
        guard let t2s = OpenCC(configFile: "t2s.json") else {
            return nil
        }
        self.openccS2T = s2t
        self.openccT2S = t2s
    }

    func ChineseConvertS2T(s: String) -> String {
        if let t = self.openccS2T.convert(s) {
            return t
        } else {
            return ""
        }
    }

    func ChineseConvertT2S(t: String) -> String {
        if let s = self.openccS2T.convert(t) {
            return s
        } else {
            return ""
        }
    }
}
