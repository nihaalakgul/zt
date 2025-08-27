import Foundation

// MARK: - Gender

enum Gender: String, CaseIterable, Codable, Identifiable {
    case male   = "Erkek"
    case female = "Kadın"

    var id: String { rawValue }
}

// MARK: - KYCProfile

struct KYCProfile: Codable, Identifiable {
    // Firestore doc id olarak customerId kullanıyoruz
    var id: String { customerId }

    let customerId: String         // Identity.Customer.id ile eş
    let nationalId: String         // T.C. Kimlik No

    var firstName: String
    var lastName: String
    var birthDate: Date
    var phone: String
    var email: String
    var address: String

    var nationality: String        // Uyruk
    var residenceCountry: String   // Şu an yaşadığı ülke
    var gender: Gender
    var hasCriminalRecord: Bool
    
    var kvkkAccepted: Bool = false
    var kvkkAcceptedAt: Date? = nil
    var kvkkVersion: String? = nil

    // Hesaplanan alanlar
    var fullName: String { "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces) }

    var age: Int {
        Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year ?? 0
    }

    // Basit kontroller (UI/Controller isterse kullanır)
    var isEmailLike: Bool {
        email.contains("@") && email.contains(".")
    }

    var isPhoneLike: Bool {
        // çok basit: en az 10 rakam
        phone.filter(\.isNumber).count >= 10
    }
}


// MARK: - Lists (uyruk & ülke)

struct Lists {
    static let nationalities: [String] = [
                "Mexican","Congolese","Emirati","Antarctic","Cambodian","Thai","Syrian","Iraqi",
                "Libyan","Rwandan","Egyptian","Haitian","Mauritanian","Nigerian","Lebanese",
                "Mozambican","Indian","Marshallese","Dominican","Canadian","Polish","Qatari",
                "Australian","Brazilian","Jamaican","French","Korean","Maltese","South African",
                "Italian","Liechtensteiner","Ni-Vanuatu","Belgian","Azerbaijani","Swiss",
                "Tajik","Peruvian","Japanese","Somali","German","Spanish","Burmese","Guyanese",
                "Venezuelan","Russian","British","Filipino","Trinidadian","Cuban","Uruguayan",
                "Indonesian","Paraguayan","Solomon Islander","Papua New Guinean","North Korean",
                "Burundian","Czech","Ugandan","Kyrgyz","Moroccan","Bangladeshi","Colombian",
                "Burkinabé","Serbian","Salvadoran","Kuwaiti","Ghanaian","Iranian","Yemeni",
                "Bahamian","Andorran","Bissau-Guinean","Nigerien","Timorese","Bruneian","Chadian",
                "Kenyan","Georgian","Samoan","South Sudanese","Equatoguinean","Pakistani",
                "Djiboutian","Singaporean","Turks and Caicos Islander","Portuguese","Turkmen",
                "Norwegian","Micronesian","Mongolian","Chilean","French Guianese","Macedonian",
                "Cypriot","Afghan","New Zealander","Albanian","Belizean","Guatemalan",
                "Central African","Namibian","Nepalese","Gabonese","Cameroonian","Belarusian",
                "Vietnamese","Nicaraguan","Surinamese","Bosnian/Herzegovinian","Guinean",
                "Honduran","Costa Rican","Saint Vincentian","Malawian","Tuvaluan","Nauruan",
                "Tongan","I-Kiribati","Fijian","French Polynesian","Kosovar","Moldovan","Chinese",
                "Macanese","Hong Konger","Montenegrin","Laotian","Ukrainian","Slovak","Grenadian",
                "Bermudian","Togolese","Malagasy","Omani","Greenlander","Tunisian","Senegalese",
                "Turkish","Gambian","Congolese","Sri Lankan","Uzbek","Algerian","Sao Tomean",
                "Panamanian","Sierra Leonean","Cape Verdean","Angolan","Argentine","Danish",
                "Basotho","Jordanian","Bahraini","Saudi","Tanzanian","Caymanian","Seychellois",
                "Mauritian","Irish","Latvian","Austrian","French West Indian","Saint Lucian",
                "Kittitian/Nevisian","Montserratian","Dominican","Virgin Islander","Barbadian",
                "Antiguan/Barbudan","Anguillian","Icelander","Hungarian","Sint Maartener",
                "Curaçaoan","Saban","Sint Eustatian","Aruban","Bonairean","Romanian","Bulgarian",
                "Greek","Croatian","Lithuanian","Dutch","Finnish","Palauan","Kazakh","Taiwanese",
                "Slovene","Malaysian","Swedish","Estonian","Luxembourger","Maldivian","Swazi",
                "Bhutanese","Bolivian","New Caledonian","Comorian","Beninese","Ecuadorian",
                "Armenian","Ivorian","Botswanan","Ethiopian","Eritrean","Zambian","Malian",
                "Liberian","Zimbabwean","Sudanese"
    ]



    static let countries: [String] = [
                "Mexico","Democratic Republic of the Congo","United Arab Emirates",
                "Antarctica","Cambodia","Thailand","Syria","Iraq","Libya","Rwanda",
                "Egypt","Haiti","Mauritania","Nigeria","Lebanon","Mozambique","India",
                "Marshall Islands","Dominican Republic","Canada","Poland","Qatar",
                "Australia","Brazil","Jamaica","France","South Korea","Malta",
                "South Africa","Italy","Liechtenstein","Vanuatu","Belgium","Azerbaijan",
                "Switzerland","Tajikistan","Peru","Japan","Somalia","Germany","Spain",
                "Burma (Myanmar)","Guyana","Venezuela","Russia","United Kingdom",
                "Philippines","Trinidad and Tobago","Cuba","Uruguay","Indonesia",
                "Paraguay","Solomon Islands","Papua New Guinea","North Korea","Burundi",
                "Czechia","Uganda","Kyrgyzstan","Morocco","Bangladesh","Colombia",
                "Burkina Faso","Serbia","El Salvador","Kuwait","Ghana","Iran","Yemen",
                "The Bahamas","Andorra","Guinea-Bissau","Niger","Timor-Leste","Brunei",
                "Chad","Kenya","Georgia","Samoa","South Sudan","Equatorial Guinea",
                "Pakistan","Djibouti","Singapore","Turks and Caicos Islands","Portugal",
                "Turkmenistan","Norway","Federated States of Micronesia","Mongolia",
                "Chile","French Guiana","North Macedonia","Cyprus","Afghanistan",
                "New Zealand","Albania","Belize","Guatemala","Central African Republic",
                "Namibia","Nepal","Gabon","Cameroon","Belarus","Vietnam","Nicaragua",
                "Suriname","Bosnia and Herzegovina","Guinea","Honduras","Costa Rica",
                "Saint Vincent and the Grenadines","Malawi","Tuvalu","Nauru","Tonga",
                "Kiribati","Fiji","French Polynesia","Kosovo","Moldova",
                "Mainland China, Hong Kong & Macau","Macau","Hong Kong","Montenegro",
                "Laos","Ukraine","Slovakia","Grenada","Bermuda","Togo","Madagascar",
                "Oman","Greenland","Tunisia","Senegal","Turkey","The Gambia",
                "Republic of the Congo","Sri Lanka","Uzbekistan","Algeria",
                "Sao Tome and Principe","Panama","Sierra Leone","Cabo Verde","Angola",
                "Argentina","Kingdom of Denmark","Lesotho","Jordan","Bahrain",
                "Saudi Arabia","Tanzania","Cayman Islands","Seychelles","Mauritius",
                "Ireland","Latvia","Austria","French West Indies","Saint Lucia",
                "Saint Kitts and Nevis","Montserrat","Dominica","British Virgin Islands",
                "Barbados","Antigua and Barbuda","Anguilla","Iceland","Hungary",
                "Sint Maarten","Curaçao","Saba","Sint Eustatius","Aruba","Bonaire",
                "Romania","Bulgaria","Greece","Croatia","Lithuania","Netherlands",
                "Finland","Palau","Kazakhstan","Taiwan","Slovenia","Malaysia","Sweden",
                "Estonia","Luxembourg","Maldives","Eswatini","Bhutan","Bolivia",
                "New Caledonia","Comoros","Benin","Ecuador","Armenia","Cote d Ivoire",
                "Botswana","Ethiopia","Eritrea","Zambia","Mali","Liberia","Zimbabwe",
                "Sudan"
            ]
        }


