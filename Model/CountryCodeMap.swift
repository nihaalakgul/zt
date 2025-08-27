//
//  CountryCodeMap.swift
//  zt
//
//  Created by Nihal Akgül on 26.08.2025.
//

import Foundation

/// ABD Dışişleri kaynaklı eski iki harfli GEC/FIPS kodlarını ISO-3166-1 alpha-2'ye çevirir.
/// Örn: TU -> TR, GM -> DE, SP -> ES, YM -> YE, IZ -> IQ ...
public let GEC_TO_ISO2: [String:String] = [
    "A1":"BQ","A2":"GF","A3":"",
    "AA":"AW","AC":"AG","AF":"AF","AG":"DZ","AL":"AL","AM":"AM","AN":"AD","AO":"AO","AR":"AR","AS":"AU","AU":"AT","AV":"AI","AY":"AQ",
    "BA":"BH","BB":"BB","BD":"BM","BE":"BE","BF":"BS","BG":"BD","BH":"BZ","BK":"BA","BL":"BO","BM":"MM","BN":"BJ","BO":"BY","BP":"SB",
    "BR":"BR","BT":"BT","BU":"BG","BX":"BN","BY":"BI",
    "CA":"CA","CB":"KH","CD":"TD","CE":"LK","CF":"CG","CG":"CD","CH":"CN","CI":"CL","CJ":"KY","CM":"CM","CN":"KM","CO":"CO","CT":"CF",
    "CU":"CU","CV":"CV","CY":"CY",
    "DA":"DK","DJ":"DJ","DO":"DM","DR":"DO",
    "EC":"EC","EG":"EG","EI":"IE","EN":"EE","ER":"ER","ES":"SV","ET":"ET",
    "FI":"FI","FJ":"FJ","FP":"PF","FR":"FR",
    "GA":"GM","GB":"GA","GG":"GE","GH":"GH","GJ":"GD","GM":"DE","GR":"GR","GT":"GT","GV":"GN","GW":"GW","GY":"GY",
    "HK":"HK","HO":"HN","HR":"HR","HU":"HU",
    "IC":"IS","ID":"ID","IN":"IN","IR":"IR","IS":"", "IT":"IT","IZ":"IQ",
    "JA":"JP","JM":"JM","JO":"JO",
    "KE":"KE","KG":"KG","KN":"KP","KR":"KI","KS":"KR","KU":"KW","KV":"XK",
    "LA":"LA","LE":"LB","LG":"LV","LH":"LT","LI":"LR","LO":"SK","LS":"LI","LT":"LS","LU":"LU","LY":"LY",
    "MA":"MG","MD":"MD","MG":"MN","MH":"MS","MI":"MW","MK":"MK","ML":"ML","MO":"MA","MP":"MU","MR":"MR","MT":"MT","MU":"OM","MV":"MV",
    "MX":"MX","MY":"MY","MZ":"MZ",
    "NC":"NC","NG":"NE","NI":"NG","NL":"NL","NN":"SX","NO":"NO","NP":"NP","NR":"NR","NS":"SR","NZ":"NZ",
    "OD":"SS","PA":"PY","PE":"PE","PK":"PK","PL":"PL","PM":"PA","PO":"PT","PP":"PG","PS":"PW",
    "QA":"QA",
    "RI":"RS","RM":"MH","RO":"RO","RP":"PH","RS":"RU","RW":"RW",
    "SA":"SA","SC":"KN","SE":"SC","SG":"SN","SI":"SI","SL":"SL","SO":"SO","SP":"ES","SR":"CH","ST":"LC","SU":"SD","SW":"SE","SY":"SY",
    "TD":"TT","TH":"TH","TI":"TJ","TK":"TC","TN":"TO","TO":"TG","TP":"ST","TS":"TN","TT":"TL","TU":"TR","TZ":"TZ",
    "UG":"UG","UK":"GB","UP":"UA","UY":"UY","UZ":"UZ",
    "VC":"VC","VE":"VE","VI":"VG","VM":"VN",
    "WA":"NA","WS":"WS","WZ":"SZ",
    "YM":"YE",
    "ZA":"ZM","ZI":"ZW"
]

/// "HK, MC, CH" gibi virgüllü GEC listesini ["HK","MC","CH"]’e çevirir.
public func splitCategoryCodes(_ raw: String) -> [String] {
    raw.split(separator: ",")
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() }
        .filter { !$0.isEmpty }
}

/// GEC -> ISO-2 dönüşümünü uygular. Bilinmeyen/boş eşleşmeler filtrelenir.
public func mapGECtoISO2(_ gecCodes: [String]) -> [String] {
    gecCodes.compactMap { code in
        let up = code.uppercased()
        guard let iso = GEC_TO_ISO2[up], !iso.isEmpty else { return nil }
        return iso
    }
}
