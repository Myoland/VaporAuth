//
//  File.swift
//  
//
//  Created by AFuture D. on 2022/7/19.
//

import Foundation
import JWTKit

struct JWTHelper {
    static let rsaModulus = """
gWu7yhI35FScdKARYboJoAm-T7yJfJ9JTvAok_RKOJYcL8oLIRSeLqQX83PPZiWdKTdXaiGWntpDu6vW7VAb-HWPF6tNYSLKDSmR3sEu2488ibWijZtNTCKOSb_1iAKAI5BJ80LTqyQtqaKzT0XUBtMsde8vX1nKI05UxujfTX3kqUtkZgLv1Yk1ZDpUoLOWUTtCm68zpjtBrPiN8bU2jqCGFyMyyXys31xFRzz4MyJ5tREHkQCzx0g7AvW0ge_sBTPQ2U6NSkcZvQyDbfDv27cMUHij1Sjx16SY9a2naTuOgamjtUzyClPLVpchX-McNyS0tjdxWY_yRL9MYuw4AQ
"""
    
    static let rsaPrivateExponent = """
L4z0tz7QWE0aGuOA32YqCSnrSYKdBTPFDILCdfHonzfP7WMPibz4jWxu_FzNk9s4Dh-uN2lV3NGW10pAsnqffD89LtYanRjaIdHnLW_PFo5fEL2yltK7qMB9hO1JegppKCfoc79W4-dr-4qy1Op0B3npOP-DaUYlNamfDmIbQW32UKeJzdGIn-_ryrBT7hQW6_uHLS2VFPPk0rNkPPKZYoNaqGnJ0eaFFF-dFwiThXIpPz--dxTAL8xYf275rjG8C9lh6awOfJSIdXMVuQITWf62E0mSQPR2-219bShMKriDYcYLbT3BJEgOkRBBHGuHo9R5TN298anxZqV1u5jtUQ
"""
    static let exponent = "AQAB"
    
    static var rsaKey: RSAKey? {
        try! Insecure.RSA.PrivateKey(modulus: rsaModulus, exponent: "AQAB", privateExponent: rsaPrivateExponent)
    }
    
    static var jwk: JWK {
        JWK.rsa(.rs256, identifier: "1234", modulus: rsaModulus, exponent: exponent)
    }
    
    static var jwkPrivate: JWK {
        JWK.rsa(
            .rs256,
            identifier: "1234",
            modulus: rsaModulus,
            exponent: exponent,
            privateExponent: rsaPrivateExponent
        )
    }
    
    static var jwk_json: String {
        """
        {"kid":"1234","n":"\(rsaModulus)","e":"AQAB","kty":"RSA","alg":"RS256"}
        """
    }
}
