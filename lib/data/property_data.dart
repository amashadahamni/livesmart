import 'package:flutter/foundation.dart';

class PropertyData {
  static const List<String> locations = [
    'Colombo 1-15',
    'Rajagiriya',
    'Battaramulla',
    'Nawala',
    'Kotte',
    'Malabe',
    'Nugegoda',
    'Thalawathugoda',
    'Piliyandala',
    'Kottawa',
    'Homagama',
    'Athurugiriya',
    'Moratuwa',
    'Dehiwala',
    'Mount Lavinia',
    'Negombo',
    'Wattala',
    'Gampaha Town',
    'Kadawatha',
    'Kelaniya',
    'Galle',
    'Matara',
    'Weligama',
    'Kandy',
    'Kurunegala',
    'Nuwara Eliya',
    'Maharagama',
    'Panadura',
  ];

  static const List<String> categories = [
    'Land',
    'House',
    'Apartment',
    'Commercial',
  ];

  static final Set<String> favoriteIds = <String>{};
  static final ValueNotifier<int> favoritesChanged = ValueNotifier<int>(0);

  static bool isFavorite(Map<String, String> property) {
    return favoriteIds.contains(property['id']);
  }

  static void toggleFavorite(Map<String, String> property) {
    final id = property['id'];
    if (id == null) return;
    if (!favoriteIds.add(id)) favoriteIds.remove(id);
    favoritesChanged.value++;
  }

  static List<Map<String, String>> get favorites {
    return all.where(isFavorite).toList();
  }

  static List<Map<String, String>> get all {
    return [
      ...verifiedListings,
      ...workbookListings,
      for (var locationIndex = 0; locationIndex < locations.length; locationIndex++)
        for (var propertyIndex = 0; propertyIndex < 15; propertyIndex++)
          if (locationIndex != 0 || propertyIndex >= 9)
            _row(locationIndex, propertyIndex),
    ];
  }

  static final List<Map<String, String>> workbookListings = _workbookRows
      .map(_workbookListing)
      .toList(growable: false);

  // id|category|city|area|price|location|contact|image|status|beds|baths|parking
  static const List<String> _workbookRows = [
    '5|Land|Colombo 1 (Fort)|88.2 Perches|LKR 40 Million Per Perch|Colombo 1|94765666534|Land_Colombo1_5.jpeg|Buy||||',
    '6|Land|Colombo 2 (Slave Island)|10.8 Perches|LKR 17 Million Per Perch|Kumaran Ratnam Road, Colombo 2|94760708098|Land_Colombo2_6.jpeg|Buy||||',
    '7|Land|Colombo 2 (Slave Island)|23 Perches|LKR 17 Million Per Perch|W A D Ramanayake Mawatha, Colombo 2|94788700800|Land_Colombo2_7.jpeg|Buy||||',
    '8|Land|Colombo 2 (Slave Island)|16.6 Perches|LKR 13 Million Per Perch|Vauxhall Street, Colombo 2|94741077102|Land_Colombo2_8.jpeg|Buy||||',
    '9|Land|Colombo 2 (Slave Island)|63.7 Perches|LKR 25 Million Per Perch|Sir James Pieris Mawatha, Colombo 2|94773213667|Land_Colombo2_9.jpeg|Buy||||',
    '10|Land|Colombo 2 (Slave Island)|23 Perches|LKR 18 Million Per Perch|Facing W A D Ramanayake Mawatha, Colombo 2|94772335599|Land_Colombo2_10.jpeg|Buy||||',
    '11|Land|Colombo 3 (Kolpity)|12 Perches|LKR 25 Million Per Perch|Alfred House Gardens, Colombo 3|94762366864|Land_Colombo3_11.jpg|Buy||||',
    '12|Land|Colombo 3 (Kolpity)|217 Perches|LKR 30 Million Per Perch|Galle Road Facing, Colombo 3|94703797685|Land_Colombo3_12.jpg|Buy||||',
    '13|Land|Colombo 3 (Kolpity)|22 Perches|Price on Request|Marine Drive, Colombo 3|94777881646|Land_Colombo3_13.jpeg|Buy||||',
    '14|Land|Colombo 3 (Kolpity)|18 Perches|LKR 25 Million Per Perch|Dharmapala Mawatha, Colombo 3|94777342797|Land_Colombo3_14.png|Buy||||',
    '15|Land|Colombo 3 (Kolpity)|40 Perches|LKR 35 Million Per Perch|Clifford Avenue, Colombo 3|94773213667|Land_Colombo3_15.jpeg|Buy||||',
    '16|Land|Colombo 4 (Bambalapitiya)|53 Perches|LKR 20 Million Per Perch|Colombo 3|94767985459|Land_Colombo4_16.png|Buy||||',
    '17|Land|Colombo 4 (Bambalapitiya)|10.75 Perches|LKR 15 Million Per Perch (Negotiable)|Shurberry Gardens, Colombo 4|94773844907|Land_Colombo4_17.jpeg|Buy||||',
    '18|Land|Colombo 4 (Bambalapitiya)|41.44 Perches|LKR 30 Million Per Perch|Galle Road, Colombo 4|94777636990|Land_Colombo4_18.jpeg|Buy||||',
    '19|Land|Colombo 5 (Havelock Town)|42 Perches|LKR 23 Million Per Perch|Anderson Road, Colombo 5|94777333368|Land_Colombo5_19.jpeg|Buy||||',
    '20|Land|Colombo 5 (Havelock Town)|21 Perches|LKR 12.5 Million Per Perch|Park Road, Colombo 5|94777632935|Land_Colombo5_20.jpeg|Buy||||',
    '21|Land|Colombo 5 (Havelock Town)|12.2 Perches|LKR 17.5 Million Per Perch|Joseph Fraser Road, Colombo 5|94778818464|Land_Colombo5_21.jpeg|Buy||||',
    '22|Land|Colombo 6 (Wellawatta)|10 Perches|LKR 6.5 Million Per Perch|Suranimala Mawatha, Pamanakada, Colombo 6|94779978813|Land_Colombo6_22.jpeg|Buy||||',
    '23|Land|Colombo 6 (Wellawatta)|16.8 Perches|LKR 151.2 Million|Colombo 6|94743946262|Land_Colombo6_23.jpeg|Buy||||',
    '24|Land|Colombo 6 (Wellawatta)|15.5 Perches|LKR 11 Million Per Perch (Negotiable)|Colombo 6|94773844907|Land_Colombo6_24.jpeg|Buy||||',
    '25|Land|Colombo 7 (Cinnamon Gardens)|8.93 Perches|LKR 18 Million Per Perch|Colombo 7|94773844907|Land_Colombo7_25.jpeg|Buy||||',
    '26|Land|Colombo 7 (Cinnamon Gardens)|31 Perches|LKR 30 Million Per Perch|Gregorys Road, Colombo 7|94777325106|Land_Colombo7_26.jpeg|Buy||||',
    '27|Land|Colombo 7 (Cinnamon Gardens)|24 Perches|Price on Request|Dharmapala Mawatha, Colombo 7|94765666534|Land_Colombo7_27.jpeg|Buy||||',
    '28|Land|Colombo 8 (Borella)|19.2 Perches|LKR 125 Million|Gothami Road, Colombo 8|94767956969|Land_Colombo8_28.jpeg|Buy||||',
    '29|Land|Colombo 8 (Borella)|20 Perches|LKR 11.7 Million Per Perch|Baseline Road, Colombo 8|94777109060|Land_Colombo8_29.jpeg|Buy||||',
    '30|Land|Colombo 8 (Borella)|25.8 Perches|LKR 4.3 Million Per Perch|Gothami Road, Colombo 8|94773337208|Land_Colombo8_30.jpeg|Buy||||',
    '31|Land|Colombo 9 (Dematagoda)|48.7 Perches|LKR 3 Million Per Perch|Veluwana Place, Colombo 09|94777703748|Land_Colombo9_31.jpeg|Buy||||',
    '32|Land|Colombo 10 (Maradana)|100 Perches|LKR 9 Million Per Perch|Sangaraja Mawatha, Colombo 10|94777251390|Land_Colombo10_32.jpeg|Buy||||',
    '33|Land|Colombo 12 (Aluthkade)|6 Perches|LKR 9.5 Million Per Perch|Muhandiram Lane, Colombo 12|94770075975|Land_Colombo12_33.jpeg|Buy||||',
    '34|Land|Colombo 13 (Kochchikade)|20 Perches|LKR 8 Million Per Perch|Alwis Place, Colombo 13|94777636990|Land_Colombo13_34.jpeg|Buy||||',
    '35|Land|Colombo 14 (Grandpass)|58 Perches|LKR 1 Million Per Perch|Colombo 14|94773541890|Land_Colombo14_35.jpeg|Buy||||',
    '36|Land|Colombo 15 (Mattakkuliya)|14 Perches|LKR 3.5 Million Per Perch|St. Marys Lane, Colombo 15|94771082211|Land_Colombo15_36.jpeg|Buy||||',
    '37|Land|Galle|4.9 Acres|Price on Request|Galle|94777720249|Land_Galle_37.jpeg|Buy||||',
    '38|Land|Kandy|26 Perches|LKR 1 Million Per Perch|Kandy View Garden, Kandy|94777703748|Land_Kandy_38.jpeg|Buy||||',
    '39|House|Colombo 5 (Havelock Town)|19 Perches|LKR 250 Million|Colombo 05|94773603029|House_Colombo5_39.jpeg|Buy|4|3|4',
    '40|House|Colombo 6 (Wellawatta)|7.55 Perches|LKR 300 Million (Negotiable)|Suvisuddharama Road, Colombo 6|94773738844|House_Colombo6_40.jpeg|Buy|6|4|2',
    '41|House|Colombo 7 (Cinnamon Gardens)|22.53 Perches|LKR 850 Million|Colombo 07|94765666534|House_Colombo7_41.jpeg|Buy|6|6|2',
    '42|House|Colombo 8 (Borella)|9.5 Perches|Price on Request|Off Castle Street, Colombo 8|94771401580|House_Colombo8_42.jpeg|Buy|3|3|2',
    '43|House|Colombo 9 (Dematagoda)|15.65 Perches|Price on Request|Punchi Borella, Colombo 9|94767951560|House_Colombo9_43.jpeg|Buy|5|4|1',
    '44|House|Colombo 10 (Maradana)|14 Perches|LKR 75 Million|Colombo 10|94777376576|House_Colombo10_44.jpeg|Buy|3|3|1',
    '45|House|Galle|14 Perches|LKR 25 Million|Gurulana, Galle|94773603029|House_Galle_45.jpeg|Buy|3|3|2',
    '46|House|Kandy|8.73 Perches|LKR 53 Million|Kandy|94742837293|House_Kandy_46.jpeg|Buy|3|3|2',
    '47|House|Maharagama|14.5 Perches|LKR 165 Million|Maharagama|94778741892|House_Mahargama_47.jpeg|Buy|4|4|2',
    '48|House|Nugegoda|31 Perches|LKR 270 Million|Nugegoda|94701937033|House_Nugegoda_48.jpeg|Buy|5|8|4',
    '49|House|Moratuwa|20 Perches|LKR 90 Million|Rawathawaththa, Moratuwa|94767947373|House_Moratuwa_49.jpeg|Buy|3|3|1',
    '50|House|Panadura|8 Perches|LKR 37.5 Million|Panadura|94773951560|House_Panadura_50.jpeg|Buy|4|2|1',
    '51|House|Nuwara Eliya|16.5 Perches|LKR 205 Million|Nuwara Eliya|94770031007|House_Nuwara-Eliya_51.jpeg|Buy|6|6|4',
    '52|House|Anuradhapura|20 Perches|LKR 65 Million|Lakeside, Anuradhapura|94770031007|House_Anuradhapura_52.jpeg|Buy|8|7|5',
    '53|House|Piliyandala|8 Perches|LKR 46.5 Million|Maharagama Road, Piliyandala|94777422944|House_Piliyandala_53.jpeg|Buy|4|4|2',
    '54|House|Rajagiriya|13.33 Perches|LKR 275 Million|Rajagiriya|94772200486|House_Rajagiriya_54.jpeg|Buy|5|6|3',
    '55|Apartment|Colombo 1 (Fort)|2100 sq.ft.|LKR 575 Million (Negotiable)|Sapphire Residence, Colombo 1|94773268427|Apartment_Colombo1_55.jpeg|Buy|3|4|1',
    '56|Apartment|Colombo 2 (Slave Island)|1268 sq.ft.|LKR 194 Million|Cinnamon Life Residence, Colombo 2|94769159929|Apartment_Colombo2_56.jpeg|Buy|2|2|1',
    '57|Apartment|Colombo 3 (Kolpity)|1630 sq.ft.|LKR 600,000 Per Month (Negotiable)|606 The Address, Colombo 3|94777115773|Apartment_Colombo3_57.jpeg|Rent|3|2|1',
    '58|Apartment|Colombo 4 (Bambalapitiya)|1330 sq.ft.|LKR 500,000 Per Month|Blue Ocean, Colombo 4|94773744156|Apartment_Colombo4_58.jpeg|Rent|2|2|1',
    '59|Apartment|Colombo 5 (Havelock Town)|1442 sq.ft.|LKR 400,000 Per Month|Havelock City, Colombo 5|94776034466|Apartment_Colombo5_59.jpeg|Rent|3|2|1',
    '60|Apartment|Colombo 6 (Wellawatta)|1680 sq.ft.|LKR 400,000 Per Month|Akara Apartments, Colombo 6|94773744156|Apartment_Colombo6_60.jpeg|Rent|3|2|1',
    '61|Apartment|Colombo 7 (Cinnamon Gardens)|1800 sq.ft.|LKR 839,000 Per Month|Victoria Park Mansion, Colombo 7|94766992864|Apartment_Colombo7_61.jpeg|Rent|3|2|1',
    '62|Apartment|Colombo 8 (Borella)|1800 sq.ft.|LKR 400,000 Per Month|Trillium Residencies, Colombo 8|94766992864|Apartment_Colombo8_62.jpeg|Rent|3|2|1',
    '63|Apartment|Colombo 9 (Dematagoda)|1000 sq.ft.|LKR 350,000 Per Month|Mulberry Residencies, Colombo 9|94743946269|Apartment_Colombo9_63.jpeg|Rent|2|2|1',
    '64|Apartment|Colombo 10 (Maradana)|800 sq.ft.|LKR 300,000 Per Month|Colombo 10|94740646958|Apartment_Colombo10_64.jpeg|Rent|2|2|1',
    '65|Commercial|Colombo 3 (Kolpity)|14000 sq.ft.|Price on Request|Colombo 3|94767685984|Commercial_Colombo3_65.jpeg|Rent|1|2|3',
    '66|Commercial|Colombo 4 (Bambalapitiya)|7000 sq.ft.|Price on Request|Colombo 4|94717876867|Commercial_Colombo4_66.png|Rent|5|10|4',
    '67|Commercial|Colombo 5 (Havelock Town)|3000 sq.ft.|LKR 65,000 Per Desk|Havelock Road, Colombo 5|94777845762|Commercial_Colombo5_67.jpeg|Rent|1|2|5',
    '68|Commercial|Colombo 6 (Wellawatta)|600 sq.ft.|LKR 400,000 Per Month|Colombo 6|94701040888|Commercial_Colombo6_68.jpeg|Rent|1|2|2',
    '69|Commercial|Colombo 7 (Cinnamon Gardens)|15000 sq.ft.|Price on Request|Independence Square, Colombo 7|94776083621|Commercial_Colombo7_69.png|Rent|1|2|5',
    '70|Commercial|Colombo 8 (Borella)|6500 sq.ft.|LKR 1,650,000 Per Month|Bauddhaloka Mawatha, Colombo 8|94767293199|Commercial_Colombo8_70.jpeg|Rent|5|7|8',
  ];

  static Map<String, String> _workbookListing(String row) {
    final fields = row.split('|');
    final category = fields[1];
    final city = fields[2];
    final status = fields[8];
    return {
      'id': 'EXCEL22-${fields[0]}',
      'category': category,
      'transactionType': status,
      'city': city,
      'area': fields[3],
      'price': fields[4],
      'bedrooms': fields[9],
      'bathrooms': fields[10],
      'specialFeatures': fields[11].isEmpty ? 'Not shown' : '${fields[11]} parking spaces',
      'contactNumber': '+${fields[6]}',
      'exactLocation': fields[5],
      'streetName': fields[5],
      'sourceUrl': 'Uploaded workbook: LiveSmartFinalExcel22.xlsx',
      'title': '$category for $status in ${fields[5]}',
      'image': 'lib/data/LiveSmartImages/${fields[7]}',
      'beds': fields[9].isEmpty ? '0' : fields[9],
      'baths': fields[10].isEmpty ? '0' : fields[10],
      'tag': category,
      'label': 'For $status',
      'location': city,
    };
  }

  static const List<Map<String, String>> verifiedListings = [
    {
      'id': 'EXCEL-COLOMBO1-LAND-1',
      'category': 'Land',
      'transactionType': 'Buy',
      'city': 'Colombo 1',
      'area': '29.2 Perches',
      'price': 'LKR 24.9 Million Per Perch',
      'bedrooms': '',
      'bathrooms': '',
      'specialFeatures': 'Not shown',
      'contactNumber': '+94775361361',
      'exactLocation': 'Prime Chatham Street, Colombo 1',
      'streetName': 'Prime Chatham Street',
      'sourceUrl': 'Uploaded workbook: LiveSmartFinalExcel1.xlsx',
      'title': 'Land for Sale in Prime Chatham Street',
      'image': 'lib/data/LiveSmartImages/Land_Colombo1_1.png',
      'beds': '0',
      'baths': '0',
      'tag': 'Land',
      'label': 'For Buy',
      'location': 'Colombo 1',
    },
    {
      'id': 'EXCEL-COLOMBO1-LAND-2',
      'category': 'Land',
      'transactionType': 'Buy',
      'city': 'Colombo 1',
      'area': '16.6 Perches',
      'price': 'LKR 24.9 Million Per Perch',
      'bedrooms': '',
      'bathrooms': '',
      'specialFeatures': 'Not shown',
      'contactNumber': '+94778818464',
      'exactLocation': 'No. 12, Mudalige Mawatha, Colombo Fort, Colombo 1',
      'streetName': 'Colombo Fort',
      'sourceUrl': 'Uploaded workbook: LiveSmartFinalExcel1.xlsx',
      'title': 'Land for Sale in Colombo Fort',
      'image': 'lib/data/LiveSmartImages/Land_Colombo1_2.jpeg',
      'beds': '0',
      'baths': '0',
      'tag': 'Land',
      'label': 'For Buy',
      'location': 'Colombo 1',
    },
    {
      'id': 'EXCEL-COLOMBO1-LAND-3',
      'category': 'Land',
      'transactionType': 'Buy',
      'city': 'Colombo 1',
      'area': '30 Perches',
      'price': 'LKR 25 Million Per Perch',
      'bedrooms': '',
      'bathrooms': '',
      'specialFeatures': 'Not shown',
      'contactNumber': '+94778086728',
      'exactLocation': 'Chatham Street, Colombo 1',
      'streetName': 'Chatham Street',
      'sourceUrl': 'Uploaded workbook: LiveSmartFinalExcel1.xlsx',
      'title': 'Land for Sale on Chatham Street',
      'image': 'lib/data/LiveSmartImages/Land_Colombo1_3.avif',
      'beds': '0',
      'baths': '0',
      'tag': 'Land',
      'label': 'For Buy',
      'location': 'Colombo 1',
    },
    {
      'id': 'EXCEL-COLOMBO1-LAND-4',
      'category': 'Land',
      'transactionType': 'Buy',
      'city': 'Colombo 1',
      'area': '16.6 Perches',
      'price': 'Price on Request',
      'bedrooms': '',
      'bathrooms': '',
      'specialFeatures': 'Not shown',
      'contactNumber': '+94777435904',
      'exactLocation': 'Near Chatham Street, Colombo 1',
      'streetName': 'Near Chatham Street',
      'sourceUrl': 'Uploaded workbook: LiveSmartFinalExcel1.xlsx',
      'title': 'Land for Sale near Chatham Street',
      'image': 'lib/data/LiveSmartImages/Land_Colombo1_4.jpeg',
      'beds': '0',
      'baths': '0',
      'tag': 'Land',
      'label': 'For Buy',
      'location': 'Colombo 1',
    },
    {
      'id': 'LPW-5854706',
      'category': 'House',
      'transactionType': 'Buy',
      'city': 'Colombo 1',
      'area': '2200 sqft',
      'price': 'Not shown',
      'bedrooms': '3',
      'bathrooms': 'Not shown',
      'specialFeatures': 'Not shown',
      'exactLocation': 'Colombo 1',
      'sourceUrl': 'https://www.lankapropertyweb.com/sale/property_details-5854706.html',
      'title': 'Ref(P-SHIV-255) Duplex Penthouse for Sale - 2000 Plaza',
      'image': 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?auto=format&fit=crop&w=800&q=80',
      'beds': '3',
      'baths': '0',
      'tag': 'House',
      'label': 'For Buy',
      'location': 'Colombo 1',
    },
    {
      'id': 'LPW-5720987',
      'category': 'House',
      'transactionType': 'Buy',
      'city': 'Colombo 1',
      'area': '2000 sqft',
      'price': 'Rs. 23.63M [Build Cost Only]',
      'bedrooms': '3',
      'bathrooms': 'Not shown',
      'specialFeatures': 'With or Without Land',
      'exactLocation': 'With or Without Land, Colombo',
      'sourceUrl': 'https://www.lankapropertyweb.com/sale/property_details-5720987.html',
      'title': 'Luxury 3 Bedroom House Construction in Colombo 1',
      'image': 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?auto=format&fit=crop&w=800&q=80',
      'beds': '3',
      'baths': '0',
      'tag': 'House',
      'label': 'For Buy',
      'location': 'Colombo 1',
    },
    {
      'id': 'LPW-5720991',
      'category': 'House',
      'transactionType': 'Buy',
      'city': 'Colombo 1',
      'area': '1816 sqft',
      'price': 'Rs. 19.8M [Build Cost Only]',
      'bedrooms': '4',
      'bathrooms': 'Not shown',
      'specialFeatures': 'With or Without Land',
      'exactLocation': 'With or Without Land, Colombo',
      'sourceUrl': 'https://www.lankapropertyweb.com/sale/property_details-5720991.html',
      'title': '4 Bedroom House Construction in Colombo',
      'image': 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?auto=format&fit=crop&w=800&q=80',
      'beds': '4',
      'baths': '0',
      'tag': 'House',
      'label': 'For Buy',
      'location': 'Colombo 1',
    },
    {
      'id': 'LPW-5720986',
      'category': 'House',
      'transactionType': 'Buy',
      'city': 'Colombo 1',
      'area': '2932 sqft',
      'price': 'Rs. 34.65M [Build Cost Only]',
      'bedrooms': '5',
      'bathrooms': 'Not shown',
      'specialFeatures': 'With or Without Land',
      'exactLocation': 'With or Without Land, Colombo',
      'sourceUrl': 'https://www.lankapropertyweb.com/sale/property_details-5720986.html',
      'title': 'Ultra Modern 5 Bedroom House Construction in Colombo',
      'image': 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?auto=format&fit=crop&w=800&q=80',
      'beds': '5',
      'baths': '0',
      'tag': 'House',
      'label': 'For Buy',
      'location': 'Colombo 1',
    },
    {
      'id': 'LPW-5704662',
      'category': 'House',
      'transactionType': 'Buy',
      'city': 'Colombo 1',
      'area': '3500 sqft',
      'price': 'Rs. 94M',
      'bedrooms': '4',
      'bathrooms': 'Not shown',
      'specialFeatures': 'Not shown',
      'exactLocation': 'Colombo 1',
      'sourceUrl': 'https://www.lankapropertyweb.com/sale/property_details-5704662.html',
      'title': 'Colombo Tree House Nugegoda - 04 Bedrooms',
      'image': 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?auto=format&fit=crop&w=800&q=80',
      'beds': '4',
      'baths': '0',
      'tag': 'House',
      'label': 'For Buy',
      'location': 'Colombo 1',
    },
  ];

  static Map<String, String> _row(int locationIndex, int propertyIndex) {
    final category = categories[(locationIndex + propertyIndex) % categories.length];
    final transaction = propertyIndex.isEven ? 'Buy' : 'Rent';
    final location = locations[locationIndex];
    final bedrooms = category == 'House' || category == 'Apartment'
        ? '${2 + ((locationIndex + propertyIndex) % 4)}'
        : '';
    final bathrooms = category == 'House' || category == 'Apartment'
        ? '${1 + ((locationIndex + propertyIndex) % 3)}'
        : '';

    return {
      'id': 'LPW-${locationIndex + 1}-${propertyIndex + 1}',
      'category': category,
      'transactionType': transaction,
      'city': location,
      'area': 'Data pending',
      'price': 'Data pending',
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'specialFeatures': 'Data pending',
      'exactLocation': location,
      'sourceUrl': 'Approved source URL pending',
      'title': '$category in $location',
      'image': 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?auto=format&fit=crop&w=800&q=80',
      'beds': bedrooms.isEmpty ? '0' : bedrooms,
      'baths': bathrooms.isEmpty ? '0' : bathrooms,
      'tag': category,
      'label': 'For $transaction',
      'location': location,
    };
  }
}
