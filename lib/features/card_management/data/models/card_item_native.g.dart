// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_item_native.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCardItemCollection on Isar {
  IsarCollection<CardItem> get cardItems => this.collection();
}

const CardItemSchema = CollectionSchema(
  name: r'CardItem',
  id: -4890872854862898375,
  properties: {
    r'buyDate': PropertySchema(
      id: 0,
      name: r'buyDate',
      type: IsarType.dateTime,
    ),
    r'buyPrice': PropertySchema(
      id: 1,
      name: r'buyPrice',
      type: IsarType.double,
    ),
    r'cardName': PropertySchema(
      id: 2,
      name: r'cardName',
      type: IsarType.string,
    ),
    r'cardNumber': PropertySchema(
      id: 3,
      name: r'cardNumber',
      type: IsarType.string,
    ),
    r'category': PropertySchema(
      id: 4,
      name: r'category',
      type: IsarType.string,
      enumMap: _CardItemcategoryEnumValueMap,
    ),
    r'certNumber': PropertySchema(
      id: 5,
      name: r'certNumber',
      type: IsarType.string,
    ),
    r'gradeScore': PropertySchema(
      id: 6,
      name: r'gradeScore',
      type: IsarType.double,
    ),
    r'grading': PropertySchema(
      id: 7,
      name: r'grading',
      type: IsarType.string,
      enumMap: _CardItemgradingEnumValueMap,
    ),
    r'imageUrl': PropertySchema(
      id: 8,
      name: r'imageUrl',
      type: IsarType.string,
    ),
    r'isCollected': PropertySchema(
      id: 9,
      name: r'isCollected',
      type: IsarType.bool,
    ),
    r'isWishlist': PropertySchema(
      id: 10,
      name: r'isWishlist',
      type: IsarType.bool,
    ),
    r'marketPrice': PropertySchema(
      id: 11,
      name: r'marketPrice',
      type: IsarType.double,
    ),
    r'priceHistoryJson': PropertySchema(
      id: 12,
      name: r'priceHistoryJson',
      type: IsarType.string,
    ),
    r'targetPrice': PropertySchema(
      id: 13,
      name: r'targetPrice',
      type: IsarType.double,
    ),
    r'volume': PropertySchema(
      id: 14,
      name: r'volume',
      type: IsarType.double,
    ),
    r'wishlistPriority': PropertySchema(
      id: 15,
      name: r'wishlistPriority',
      type: IsarType.long,
    )
  },
  estimateSize: _cardItemEstimateSize,
  serialize: _cardItemSerialize,
  deserialize: _cardItemDeserialize,
  deserializeProp: _cardItemDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _cardItemGetId,
  getLinks: _cardItemGetLinks,
  attach: _cardItemAttach,
  version: '3.1.0+1',
);

int _cardItemEstimateSize(
  CardItem object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.cardName.length * 3;
  bytesCount += 3 + object.cardNumber.length * 3;
  bytesCount += 3 + object.category.name.length * 3;
  {
    final value = object.certNumber;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.grading.name.length * 3;
  bytesCount += 3 + object.imageUrl.length * 3;
  bytesCount += 3 + object.priceHistoryJson.length * 3;
  return bytesCount;
}

void _cardItemSerialize(
  CardItem object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.buyDate);
  writer.writeDouble(offsets[1], object.buyPrice);
  writer.writeString(offsets[2], object.cardName);
  writer.writeString(offsets[3], object.cardNumber);
  writer.writeString(offsets[4], object.category.name);
  writer.writeString(offsets[5], object.certNumber);
  writer.writeDouble(offsets[6], object.gradeScore);
  writer.writeString(offsets[7], object.grading.name);
  writer.writeString(offsets[8], object.imageUrl);
  writer.writeBool(offsets[9], object.isCollected);
  writer.writeBool(offsets[10], object.isWishlist);
  writer.writeDouble(offsets[11], object.marketPrice);
  writer.writeString(offsets[12], object.priceHistoryJson);
  writer.writeDouble(offsets[13], object.targetPrice);
  writer.writeDouble(offsets[14], object.volume);
  writer.writeLong(offsets[15], object.wishlistPriority);
}

CardItem _cardItemDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CardItem(
    buyDate: reader.readDateTime(offsets[0]),
    buyPrice: reader.readDouble(offsets[1]),
    cardName: reader.readString(offsets[2]),
    cardNumber: reader.readString(offsets[3]),
    category:
        _CardItemcategoryValueEnumMap[reader.readStringOrNull(offsets[4])] ??
            CardCategory.all,
    certNumber: reader.readStringOrNull(offsets[5]),
    gradeScore: reader.readDoubleOrNull(offsets[6]),
    grading:
        _CardItemgradingValueEnumMap[reader.readStringOrNull(offsets[7])] ??
            GradingCompany.raw,
    imageUrl: reader.readString(offsets[8]),
    isCollected: reader.readBoolOrNull(offsets[9]) ?? true,
    isWishlist: reader.readBoolOrNull(offsets[10]) ?? false,
    marketPrice: reader.readDouble(offsets[11]),
    priceHistoryJson: reader.readStringOrNull(offsets[12]) ?? '',
    targetPrice: reader.readDoubleOrNull(offsets[13]),
    volume: reader.readDoubleOrNull(offsets[14]) ?? 0.0,
    wishlistPriority: reader.readLongOrNull(offsets[15]) ?? 0,
  );
  object.id = id;
  return object;
}

P _cardItemDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (_CardItemcategoryValueEnumMap[reader.readStringOrNull(offset)] ??
          CardCategory.all) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readDoubleOrNull(offset)) as P;
    case 7:
      return (_CardItemgradingValueEnumMap[reader.readStringOrNull(offset)] ??
          GradingCompany.raw) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 10:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 11:
      return (reader.readDouble(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset) ?? '') as P;
    case 13:
      return (reader.readDoubleOrNull(offset)) as P;
    case 14:
      return (reader.readDoubleOrNull(offset) ?? 0.0) as P;
    case 15:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _CardItemcategoryEnumValueMap = {
  r'all': r'all',
  r'pokemon': r'pokemon',
  r'onePiece': r'onePiece',
  r'yugioh': r'yugioh',
  r'sportsOther': r'sportsOther',
};
const _CardItemcategoryValueEnumMap = {
  r'all': CardCategory.all,
  r'pokemon': CardCategory.pokemon,
  r'onePiece': CardCategory.onePiece,
  r'yugioh': CardCategory.yugioh,
  r'sportsOther': CardCategory.sportsOther,
};
const _CardItemgradingEnumValueMap = {
  r'raw': r'raw',
  r'psa': r'psa',
  r'bgs': r'bgs',
  r'cgc': r'cgc',
};
const _CardItemgradingValueEnumMap = {
  r'raw': GradingCompany.raw,
  r'psa': GradingCompany.psa,
  r'bgs': GradingCompany.bgs,
  r'cgc': GradingCompany.cgc,
};

Id _cardItemGetId(CardItem object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _cardItemGetLinks(CardItem object) {
  return [];
}

void _cardItemAttach(IsarCollection<dynamic> col, Id id, CardItem object) {
  object.id = id;
}

extension CardItemQueryWhereSort on QueryBuilder<CardItem, CardItem, QWhere> {
  QueryBuilder<CardItem, CardItem, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CardItemQueryWhere on QueryBuilder<CardItem, CardItem, QWhereClause> {
  QueryBuilder<CardItem, CardItem, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension CardItemQueryFilter
    on QueryBuilder<CardItem, CardItem, QFilterCondition> {
  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> buyDateEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'buyDate',
        value: value,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> buyDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'buyDate',
        value: value,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> buyDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'buyDate',
        value: value,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> buyDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'buyDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> buyPriceEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'buyPrice',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> buyPriceGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'buyPrice',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> buyPriceLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'buyPrice',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> buyPriceBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'buyPrice',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> cardNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cardName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> cardNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cardName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> cardNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cardName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> cardNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cardName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> cardNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'cardName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> cardNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'cardName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> cardNameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cardName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> cardNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cardName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> cardNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cardName',
        value: '',
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> cardNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cardName',
        value: '',
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> cardNumberEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cardNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> cardNumberGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cardNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> cardNumberLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cardNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> cardNumberBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cardNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> cardNumberStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'cardNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> cardNumberEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'cardNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> cardNumberContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cardNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> cardNumberMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cardNumber',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> cardNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cardNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition>
      cardNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cardNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> categoryEqualTo(
    CardCategory value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> categoryGreaterThan(
    CardCategory value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> categoryLessThan(
    CardCategory value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> categoryBetween(
    CardCategory lower,
    CardCategory upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'category',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> categoryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> categoryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> categoryContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> categoryMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'category',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> categoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'category',
        value: '',
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> categoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'category',
        value: '',
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> certNumberIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'certNumber',
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition>
      certNumberIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'certNumber',
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> certNumberEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'certNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> certNumberGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'certNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> certNumberLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'certNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> certNumberBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'certNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> certNumberStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'certNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> certNumberEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'certNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> certNumberContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'certNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> certNumberMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'certNumber',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> certNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'certNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition>
      certNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'certNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> gradeScoreIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'gradeScore',
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition>
      gradeScoreIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'gradeScore',
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> gradeScoreEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gradeScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> gradeScoreGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'gradeScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> gradeScoreLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'gradeScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> gradeScoreBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'gradeScore',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> gradingEqualTo(
    GradingCompany value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'grading',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> gradingGreaterThan(
    GradingCompany value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'grading',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> gradingLessThan(
    GradingCompany value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'grading',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> gradingBetween(
    GradingCompany lower,
    GradingCompany upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'grading',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> gradingStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'grading',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> gradingEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'grading',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> gradingContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'grading',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> gradingMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'grading',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> gradingIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'grading',
        value: '',
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> gradingIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'grading',
        value: '',
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> imageUrlEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> imageUrlGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> imageUrlLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> imageUrlBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'imageUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> imageUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> imageUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> imageUrlContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> imageUrlMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'imageUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> imageUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imageUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> imageUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'imageUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> isCollectedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isCollected',
        value: value,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> isWishlistEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isWishlist',
        value: value,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> marketPriceEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'marketPrice',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition>
      marketPriceGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'marketPrice',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> marketPriceLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'marketPrice',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> marketPriceBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'marketPrice',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition>
      priceHistoryJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'priceHistoryJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition>
      priceHistoryJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'priceHistoryJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition>
      priceHistoryJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'priceHistoryJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition>
      priceHistoryJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'priceHistoryJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition>
      priceHistoryJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'priceHistoryJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition>
      priceHistoryJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'priceHistoryJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition>
      priceHistoryJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'priceHistoryJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition>
      priceHistoryJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'priceHistoryJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition>
      priceHistoryJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'priceHistoryJson',
        value: '',
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition>
      priceHistoryJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'priceHistoryJson',
        value: '',
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> targetPriceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'targetPrice',
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition>
      targetPriceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'targetPrice',
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> targetPriceEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetPrice',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition>
      targetPriceGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'targetPrice',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> targetPriceLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'targetPrice',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> targetPriceBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'targetPrice',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> volumeEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'volume',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> volumeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'volume',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> volumeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'volume',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition> volumeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'volume',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition>
      wishlistPriorityEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'wishlistPriority',
        value: value,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition>
      wishlistPriorityGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'wishlistPriority',
        value: value,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition>
      wishlistPriorityLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'wishlistPriority',
        value: value,
      ));
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterFilterCondition>
      wishlistPriorityBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'wishlistPriority',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension CardItemQueryObject
    on QueryBuilder<CardItem, CardItem, QFilterCondition> {}

extension CardItemQueryLinks
    on QueryBuilder<CardItem, CardItem, QFilterCondition> {}

extension CardItemQuerySortBy on QueryBuilder<CardItem, CardItem, QSortBy> {
  QueryBuilder<CardItem, CardItem, QAfterSortBy> sortByBuyDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'buyDate', Sort.asc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> sortByBuyDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'buyDate', Sort.desc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> sortByBuyPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'buyPrice', Sort.asc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> sortByBuyPriceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'buyPrice', Sort.desc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> sortByCardName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardName', Sort.asc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> sortByCardNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardName', Sort.desc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> sortByCardNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardNumber', Sort.asc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> sortByCardNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardNumber', Sort.desc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> sortByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> sortByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> sortByCertNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'certNumber', Sort.asc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> sortByCertNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'certNumber', Sort.desc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> sortByGradeScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gradeScore', Sort.asc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> sortByGradeScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gradeScore', Sort.desc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> sortByGrading() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'grading', Sort.asc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> sortByGradingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'grading', Sort.desc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> sortByImageUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageUrl', Sort.asc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> sortByImageUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageUrl', Sort.desc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> sortByIsCollected() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCollected', Sort.asc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> sortByIsCollectedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCollected', Sort.desc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> sortByIsWishlist() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isWishlist', Sort.asc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> sortByIsWishlistDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isWishlist', Sort.desc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> sortByMarketPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'marketPrice', Sort.asc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> sortByMarketPriceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'marketPrice', Sort.desc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> sortByPriceHistoryJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priceHistoryJson', Sort.asc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> sortByPriceHistoryJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priceHistoryJson', Sort.desc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> sortByTargetPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetPrice', Sort.asc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> sortByTargetPriceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetPrice', Sort.desc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> sortByVolume() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'volume', Sort.asc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> sortByVolumeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'volume', Sort.desc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> sortByWishlistPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wishlistPriority', Sort.asc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> sortByWishlistPriorityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wishlistPriority', Sort.desc);
    });
  }
}

extension CardItemQuerySortThenBy
    on QueryBuilder<CardItem, CardItem, QSortThenBy> {
  QueryBuilder<CardItem, CardItem, QAfterSortBy> thenByBuyDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'buyDate', Sort.asc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> thenByBuyDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'buyDate', Sort.desc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> thenByBuyPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'buyPrice', Sort.asc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> thenByBuyPriceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'buyPrice', Sort.desc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> thenByCardName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardName', Sort.asc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> thenByCardNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardName', Sort.desc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> thenByCardNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardNumber', Sort.asc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> thenByCardNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardNumber', Sort.desc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> thenByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> thenByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> thenByCertNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'certNumber', Sort.asc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> thenByCertNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'certNumber', Sort.desc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> thenByGradeScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gradeScore', Sort.asc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> thenByGradeScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gradeScore', Sort.desc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> thenByGrading() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'grading', Sort.asc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> thenByGradingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'grading', Sort.desc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> thenByImageUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageUrl', Sort.asc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> thenByImageUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageUrl', Sort.desc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> thenByIsCollected() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCollected', Sort.asc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> thenByIsCollectedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCollected', Sort.desc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> thenByIsWishlist() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isWishlist', Sort.asc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> thenByIsWishlistDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isWishlist', Sort.desc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> thenByMarketPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'marketPrice', Sort.asc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> thenByMarketPriceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'marketPrice', Sort.desc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> thenByPriceHistoryJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priceHistoryJson', Sort.asc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> thenByPriceHistoryJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priceHistoryJson', Sort.desc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> thenByTargetPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetPrice', Sort.asc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> thenByTargetPriceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetPrice', Sort.desc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> thenByVolume() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'volume', Sort.asc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> thenByVolumeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'volume', Sort.desc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> thenByWishlistPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wishlistPriority', Sort.asc);
    });
  }

  QueryBuilder<CardItem, CardItem, QAfterSortBy> thenByWishlistPriorityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wishlistPriority', Sort.desc);
    });
  }
}

extension CardItemQueryWhereDistinct
    on QueryBuilder<CardItem, CardItem, QDistinct> {
  QueryBuilder<CardItem, CardItem, QDistinct> distinctByBuyDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'buyDate');
    });
  }

  QueryBuilder<CardItem, CardItem, QDistinct> distinctByBuyPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'buyPrice');
    });
  }

  QueryBuilder<CardItem, CardItem, QDistinct> distinctByCardName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cardName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CardItem, CardItem, QDistinct> distinctByCardNumber(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cardNumber', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CardItem, CardItem, QDistinct> distinctByCategory(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'category', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CardItem, CardItem, QDistinct> distinctByCertNumber(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'certNumber', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CardItem, CardItem, QDistinct> distinctByGradeScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'gradeScore');
    });
  }

  QueryBuilder<CardItem, CardItem, QDistinct> distinctByGrading(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'grading', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CardItem, CardItem, QDistinct> distinctByImageUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'imageUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CardItem, CardItem, QDistinct> distinctByIsCollected() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isCollected');
    });
  }

  QueryBuilder<CardItem, CardItem, QDistinct> distinctByIsWishlist() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isWishlist');
    });
  }

  QueryBuilder<CardItem, CardItem, QDistinct> distinctByMarketPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'marketPrice');
    });
  }

  QueryBuilder<CardItem, CardItem, QDistinct> distinctByPriceHistoryJson(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'priceHistoryJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CardItem, CardItem, QDistinct> distinctByTargetPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'targetPrice');
    });
  }

  QueryBuilder<CardItem, CardItem, QDistinct> distinctByVolume() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'volume');
    });
  }

  QueryBuilder<CardItem, CardItem, QDistinct> distinctByWishlistPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'wishlistPriority');
    });
  }
}

extension CardItemQueryProperty
    on QueryBuilder<CardItem, CardItem, QQueryProperty> {
  QueryBuilder<CardItem, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CardItem, DateTime, QQueryOperations> buyDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'buyDate');
    });
  }

  QueryBuilder<CardItem, double, QQueryOperations> buyPriceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'buyPrice');
    });
  }

  QueryBuilder<CardItem, String, QQueryOperations> cardNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cardName');
    });
  }

  QueryBuilder<CardItem, String, QQueryOperations> cardNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cardNumber');
    });
  }

  QueryBuilder<CardItem, CardCategory, QQueryOperations> categoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'category');
    });
  }

  QueryBuilder<CardItem, String?, QQueryOperations> certNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'certNumber');
    });
  }

  QueryBuilder<CardItem, double?, QQueryOperations> gradeScoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'gradeScore');
    });
  }

  QueryBuilder<CardItem, GradingCompany, QQueryOperations> gradingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'grading');
    });
  }

  QueryBuilder<CardItem, String, QQueryOperations> imageUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'imageUrl');
    });
  }

  QueryBuilder<CardItem, bool, QQueryOperations> isCollectedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isCollected');
    });
  }

  QueryBuilder<CardItem, bool, QQueryOperations> isWishlistProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isWishlist');
    });
  }

  QueryBuilder<CardItem, double, QQueryOperations> marketPriceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'marketPrice');
    });
  }

  QueryBuilder<CardItem, String, QQueryOperations> priceHistoryJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'priceHistoryJson');
    });
  }

  QueryBuilder<CardItem, double?, QQueryOperations> targetPriceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'targetPrice');
    });
  }

  QueryBuilder<CardItem, double, QQueryOperations> volumeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'volume');
    });
  }

  QueryBuilder<CardItem, int, QQueryOperations> wishlistPriorityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'wishlistPriority');
    });
  }
}
