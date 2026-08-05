// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CardsTable extends Cards with TableInfo<$CardsTable, CardRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _catalogIdMeta =
      const VerificationMeta('catalogId');
  @override
  late final GeneratedColumn<String> catalogId = GeneratedColumn<String>(
      'catalog_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cardNumberMeta =
      const VerificationMeta('cardNumber');
  @override
  late final GeneratedColumn<String> cardNumber = GeneratedColumn<String>(
      'card_number', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _setNameMeta =
      const VerificationMeta('setName');
  @override
  late final GeneratedColumn<String> setName = GeneratedColumn<String>(
      'set_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _imageUrlMeta =
      const VerificationMeta('imageUrl');
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
      'image_url', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _gradingMeta =
      const VerificationMeta('grading');
  @override
  late final GeneratedColumn<String> grading = GeneratedColumn<String>(
      'grading', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('raw'));
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('all'));
  static const VerificationMeta _gradeScoreMeta =
      const VerificationMeta('gradeScore');
  @override
  late final GeneratedColumn<double> gradeScore = GeneratedColumn<double>(
      'grade_score', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _certNumberMeta =
      const VerificationMeta('certNumber');
  @override
  late final GeneratedColumn<String> certNumber = GeneratedColumn<String>(
      'cert_number', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _buyPriceMeta =
      const VerificationMeta('buyPrice');
  @override
  late final GeneratedColumn<double> buyPrice = GeneratedColumn<double>(
      'buy_price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _marketPriceMeta =
      const VerificationMeta('marketPrice');
  @override
  late final GeneratedColumn<double> marketPrice = GeneratedColumn<double>(
      'market_price', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _buyDateMeta =
      const VerificationMeta('buyDate');
  @override
  late final GeneratedColumn<DateTime> buyDate = GeneratedColumn<DateTime>(
      'buy_date', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: Constant(DateTime.fromMillisecondsSinceEpoch(0)));
  static const VerificationMeta _isCollectedMeta =
      const VerificationMeta('isCollected');
  @override
  late final GeneratedColumn<bool> isCollected = GeneratedColumn<bool>(
      'is_collected', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_collected" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _volumeMeta = const VerificationMeta('volume');
  @override
  late final GeneratedColumn<double> volume = GeneratedColumn<double>(
      'volume', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _isWishlistMeta =
      const VerificationMeta('isWishlist');
  @override
  late final GeneratedColumn<bool> isWishlist = GeneratedColumn<bool>(
      'is_wishlist', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_wishlist" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _targetPriceMeta =
      const VerificationMeta('targetPrice');
  @override
  late final GeneratedColumn<double> targetPrice = GeneratedColumn<double>(
      'target_price', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _wishlistPriorityMeta =
      const VerificationMeta('wishlistPriority');
  @override
  late final GeneratedColumn<int> wishlistPriority = GeneratedColumn<int>(
      'wishlist_priority', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _priceHistoryJsonMeta =
      const VerificationMeta('priceHistoryJson');
  @override
  late final GeneratedColumn<String> priceHistoryJson = GeneratedColumn<String>(
      'price_history_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _centeringDataMeta =
      const VerificationMeta('centeringData');
  @override
  late final GeneratedColumn<String> centeringData = GeneratedColumn<String>(
      'centering_data', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _imagePathsMeta =
      const VerificationMeta('imagePaths');
  @override
  late final GeneratedColumn<String> imagePaths = GeneratedColumn<String>(
      'image_paths', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        catalogId,
        name,
        cardNumber,
        setName,
        imageUrl,
        grading,
        category,
        gradeScore,
        certNumber,
        buyPrice,
        marketPrice,
        buyDate,
        isCollected,
        volume,
        isWishlist,
        targetPrice,
        wishlistPriority,
        priceHistoryJson,
        centeringData,
        imagePaths,
        createdAt,
        isSynced
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cards';
  @override
  VerificationContext validateIntegrity(Insertable<CardRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('catalog_id')) {
      context.handle(_catalogIdMeta,
          catalogId.isAcceptableOrUnknown(data['catalog_id']!, _catalogIdMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('card_number')) {
      context.handle(
          _cardNumberMeta,
          cardNumber.isAcceptableOrUnknown(
              data['card_number']!, _cardNumberMeta));
    }
    if (data.containsKey('set_name')) {
      context.handle(_setNameMeta,
          setName.isAcceptableOrUnknown(data['set_name']!, _setNameMeta));
    }
    if (data.containsKey('image_url')) {
      context.handle(_imageUrlMeta,
          imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta));
    }
    if (data.containsKey('grading')) {
      context.handle(_gradingMeta,
          grading.isAcceptableOrUnknown(data['grading']!, _gradingMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('grade_score')) {
      context.handle(
          _gradeScoreMeta,
          gradeScore.isAcceptableOrUnknown(
              data['grade_score']!, _gradeScoreMeta));
    }
    if (data.containsKey('cert_number')) {
      context.handle(
          _certNumberMeta,
          certNumber.isAcceptableOrUnknown(
              data['cert_number']!, _certNumberMeta));
    }
    if (data.containsKey('buy_price')) {
      context.handle(_buyPriceMeta,
          buyPrice.isAcceptableOrUnknown(data['buy_price']!, _buyPriceMeta));
    } else if (isInserting) {
      context.missing(_buyPriceMeta);
    }
    if (data.containsKey('market_price')) {
      context.handle(
          _marketPriceMeta,
          marketPrice.isAcceptableOrUnknown(
              data['market_price']!, _marketPriceMeta));
    }
    if (data.containsKey('buy_date')) {
      context.handle(_buyDateMeta,
          buyDate.isAcceptableOrUnknown(data['buy_date']!, _buyDateMeta));
    }
    if (data.containsKey('is_collected')) {
      context.handle(
          _isCollectedMeta,
          isCollected.isAcceptableOrUnknown(
              data['is_collected']!, _isCollectedMeta));
    }
    if (data.containsKey('volume')) {
      context.handle(_volumeMeta,
          volume.isAcceptableOrUnknown(data['volume']!, _volumeMeta));
    }
    if (data.containsKey('is_wishlist')) {
      context.handle(
          _isWishlistMeta,
          isWishlist.isAcceptableOrUnknown(
              data['is_wishlist']!, _isWishlistMeta));
    }
    if (data.containsKey('target_price')) {
      context.handle(
          _targetPriceMeta,
          targetPrice.isAcceptableOrUnknown(
              data['target_price']!, _targetPriceMeta));
    }
    if (data.containsKey('wishlist_priority')) {
      context.handle(
          _wishlistPriorityMeta,
          wishlistPriority.isAcceptableOrUnknown(
              data['wishlist_priority']!, _wishlistPriorityMeta));
    }
    if (data.containsKey('price_history_json')) {
      context.handle(
          _priceHistoryJsonMeta,
          priceHistoryJson.isAcceptableOrUnknown(
              data['price_history_json']!, _priceHistoryJsonMeta));
    }
    if (data.containsKey('centering_data')) {
      context.handle(
          _centeringDataMeta,
          centeringData.isAcceptableOrUnknown(
              data['centering_data']!, _centeringDataMeta));
    }
    if (data.containsKey('image_paths')) {
      context.handle(
          _imagePathsMeta,
          imagePaths.isAcceptableOrUnknown(
              data['image_paths']!, _imagePathsMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CardRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      catalogId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}catalog_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      cardNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}card_number'])!,
      setName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}set_name'])!,
      imageUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_url'])!,
      grading: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}grading'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      gradeScore: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}grade_score']),
      certNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cert_number']),
      buyPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}buy_price'])!,
      marketPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}market_price'])!,
      buyDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}buy_date'])!,
      isCollected: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_collected'])!,
      volume: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}volume'])!,
      isWishlist: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_wishlist'])!,
      targetPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}target_price']),
      wishlistPriority: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}wishlist_priority'])!,
      priceHistoryJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}price_history_json'])!,
      centeringData: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}centering_data']),
      imagePaths: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_paths'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
    );
  }

  @override
  $CardsTable createAlias(String alias) {
    return $CardsTable(attachedDatabase, alias);
  }
}

class CardRow extends DataClass implements Insertable<CardRow> {
  final String id;
  final String catalogId;
  final String name;
  final String cardNumber;

  /// 卡牌所属系列/卡组名（透传到公共主图鉴 ID，H-4 新增；默认空串兼容历史数据）。
  final String setName;
  final String imageUrl;
  final String grading;
  final String category;
  final double? gradeScore;
  final String? certNumber;
  final double buyPrice;
  final double marketPrice;
  final DateTime buyDate;
  final bool isCollected;
  final double volume;
  final bool isWishlist;
  final double? targetPrice;
  final int wishlistPriority;
  final String priceHistoryJson;

  /// 居中度测量结果明细（对应 CardItem.centeringResult，JSON 序列化）。
  final String? centeringData;

  /// 本地高清图路径列表（JSON 序列化）。
  final String imagePaths;
  final DateTime createdAt;

  /// 是否已同步至云端（本地写入后为 false，Supabase 增量同步成功后置 true）。
  final bool isSynced;
  const CardRow(
      {required this.id,
      required this.catalogId,
      required this.name,
      required this.cardNumber,
      required this.setName,
      required this.imageUrl,
      required this.grading,
      required this.category,
      this.gradeScore,
      this.certNumber,
      required this.buyPrice,
      required this.marketPrice,
      required this.buyDate,
      required this.isCollected,
      required this.volume,
      required this.isWishlist,
      this.targetPrice,
      required this.wishlistPriority,
      required this.priceHistoryJson,
      this.centeringData,
      required this.imagePaths,
      required this.createdAt,
      required this.isSynced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['catalog_id'] = Variable<String>(catalogId);
    map['name'] = Variable<String>(name);
    map['card_number'] = Variable<String>(cardNumber);
    map['set_name'] = Variable<String>(setName);
    map['image_url'] = Variable<String>(imageUrl);
    map['grading'] = Variable<String>(grading);
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || gradeScore != null) {
      map['grade_score'] = Variable<double>(gradeScore);
    }
    if (!nullToAbsent || certNumber != null) {
      map['cert_number'] = Variable<String>(certNumber);
    }
    map['buy_price'] = Variable<double>(buyPrice);
    map['market_price'] = Variable<double>(marketPrice);
    map['buy_date'] = Variable<DateTime>(buyDate);
    map['is_collected'] = Variable<bool>(isCollected);
    map['volume'] = Variable<double>(volume);
    map['is_wishlist'] = Variable<bool>(isWishlist);
    if (!nullToAbsent || targetPrice != null) {
      map['target_price'] = Variable<double>(targetPrice);
    }
    map['wishlist_priority'] = Variable<int>(wishlistPriority);
    map['price_history_json'] = Variable<String>(priceHistoryJson);
    if (!nullToAbsent || centeringData != null) {
      map['centering_data'] = Variable<String>(centeringData);
    }
    map['image_paths'] = Variable<String>(imagePaths);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  CardsCompanion toCompanion(bool nullToAbsent) {
    return CardsCompanion(
      id: Value(id),
      catalogId: Value(catalogId),
      name: Value(name),
      cardNumber: Value(cardNumber),
      setName: Value(setName),
      imageUrl: Value(imageUrl),
      grading: Value(grading),
      category: Value(category),
      gradeScore: gradeScore == null && nullToAbsent
          ? const Value.absent()
          : Value(gradeScore),
      certNumber: certNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(certNumber),
      buyPrice: Value(buyPrice),
      marketPrice: Value(marketPrice),
      buyDate: Value(buyDate),
      isCollected: Value(isCollected),
      volume: Value(volume),
      isWishlist: Value(isWishlist),
      targetPrice: targetPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(targetPrice),
      wishlistPriority: Value(wishlistPriority),
      priceHistoryJson: Value(priceHistoryJson),
      centeringData: centeringData == null && nullToAbsent
          ? const Value.absent()
          : Value(centeringData),
      imagePaths: Value(imagePaths),
      createdAt: Value(createdAt),
      isSynced: Value(isSynced),
    );
  }

  factory CardRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardRow(
      id: serializer.fromJson<String>(json['id']),
      catalogId: serializer.fromJson<String>(json['catalogId']),
      name: serializer.fromJson<String>(json['name']),
      cardNumber: serializer.fromJson<String>(json['cardNumber']),
      setName: serializer.fromJson<String>(json['setName']),
      imageUrl: serializer.fromJson<String>(json['imageUrl']),
      grading: serializer.fromJson<String>(json['grading']),
      category: serializer.fromJson<String>(json['category']),
      gradeScore: serializer.fromJson<double?>(json['gradeScore']),
      certNumber: serializer.fromJson<String?>(json['certNumber']),
      buyPrice: serializer.fromJson<double>(json['buyPrice']),
      marketPrice: serializer.fromJson<double>(json['marketPrice']),
      buyDate: serializer.fromJson<DateTime>(json['buyDate']),
      isCollected: serializer.fromJson<bool>(json['isCollected']),
      volume: serializer.fromJson<double>(json['volume']),
      isWishlist: serializer.fromJson<bool>(json['isWishlist']),
      targetPrice: serializer.fromJson<double?>(json['targetPrice']),
      wishlistPriority: serializer.fromJson<int>(json['wishlistPriority']),
      priceHistoryJson: serializer.fromJson<String>(json['priceHistoryJson']),
      centeringData: serializer.fromJson<String?>(json['centeringData']),
      imagePaths: serializer.fromJson<String>(json['imagePaths']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'catalogId': serializer.toJson<String>(catalogId),
      'name': serializer.toJson<String>(name),
      'cardNumber': serializer.toJson<String>(cardNumber),
      'setName': serializer.toJson<String>(setName),
      'imageUrl': serializer.toJson<String>(imageUrl),
      'grading': serializer.toJson<String>(grading),
      'category': serializer.toJson<String>(category),
      'gradeScore': serializer.toJson<double?>(gradeScore),
      'certNumber': serializer.toJson<String?>(certNumber),
      'buyPrice': serializer.toJson<double>(buyPrice),
      'marketPrice': serializer.toJson<double>(marketPrice),
      'buyDate': serializer.toJson<DateTime>(buyDate),
      'isCollected': serializer.toJson<bool>(isCollected),
      'volume': serializer.toJson<double>(volume),
      'isWishlist': serializer.toJson<bool>(isWishlist),
      'targetPrice': serializer.toJson<double?>(targetPrice),
      'wishlistPriority': serializer.toJson<int>(wishlistPriority),
      'priceHistoryJson': serializer.toJson<String>(priceHistoryJson),
      'centeringData': serializer.toJson<String?>(centeringData),
      'imagePaths': serializer.toJson<String>(imagePaths),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  CardRow copyWith(
          {String? id,
          String? catalogId,
          String? name,
          String? cardNumber,
          String? setName,
          String? imageUrl,
          String? grading,
          String? category,
          Value<double?> gradeScore = const Value.absent(),
          Value<String?> certNumber = const Value.absent(),
          double? buyPrice,
          double? marketPrice,
          DateTime? buyDate,
          bool? isCollected,
          double? volume,
          bool? isWishlist,
          Value<double?> targetPrice = const Value.absent(),
          int? wishlistPriority,
          String? priceHistoryJson,
          Value<String?> centeringData = const Value.absent(),
          String? imagePaths,
          DateTime? createdAt,
          bool? isSynced}) =>
      CardRow(
        id: id ?? this.id,
        catalogId: catalogId ?? this.catalogId,
        name: name ?? this.name,
        cardNumber: cardNumber ?? this.cardNumber,
        setName: setName ?? this.setName,
        imageUrl: imageUrl ?? this.imageUrl,
        grading: grading ?? this.grading,
        category: category ?? this.category,
        gradeScore: gradeScore.present ? gradeScore.value : this.gradeScore,
        certNumber: certNumber.present ? certNumber.value : this.certNumber,
        buyPrice: buyPrice ?? this.buyPrice,
        marketPrice: marketPrice ?? this.marketPrice,
        buyDate: buyDate ?? this.buyDate,
        isCollected: isCollected ?? this.isCollected,
        volume: volume ?? this.volume,
        isWishlist: isWishlist ?? this.isWishlist,
        targetPrice: targetPrice.present ? targetPrice.value : this.targetPrice,
        wishlistPriority: wishlistPriority ?? this.wishlistPriority,
        priceHistoryJson: priceHistoryJson ?? this.priceHistoryJson,
        centeringData:
            centeringData.present ? centeringData.value : this.centeringData,
        imagePaths: imagePaths ?? this.imagePaths,
        createdAt: createdAt ?? this.createdAt,
        isSynced: isSynced ?? this.isSynced,
      );
  CardRow copyWithCompanion(CardsCompanion data) {
    return CardRow(
      id: data.id.present ? data.id.value : this.id,
      catalogId: data.catalogId.present ? data.catalogId.value : this.catalogId,
      name: data.name.present ? data.name.value : this.name,
      cardNumber:
          data.cardNumber.present ? data.cardNumber.value : this.cardNumber,
      setName: data.setName.present ? data.setName.value : this.setName,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      grading: data.grading.present ? data.grading.value : this.grading,
      category: data.category.present ? data.category.value : this.category,
      gradeScore:
          data.gradeScore.present ? data.gradeScore.value : this.gradeScore,
      certNumber:
          data.certNumber.present ? data.certNumber.value : this.certNumber,
      buyPrice: data.buyPrice.present ? data.buyPrice.value : this.buyPrice,
      marketPrice:
          data.marketPrice.present ? data.marketPrice.value : this.marketPrice,
      buyDate: data.buyDate.present ? data.buyDate.value : this.buyDate,
      isCollected:
          data.isCollected.present ? data.isCollected.value : this.isCollected,
      volume: data.volume.present ? data.volume.value : this.volume,
      isWishlist:
          data.isWishlist.present ? data.isWishlist.value : this.isWishlist,
      targetPrice:
          data.targetPrice.present ? data.targetPrice.value : this.targetPrice,
      wishlistPriority: data.wishlistPriority.present
          ? data.wishlistPriority.value
          : this.wishlistPriority,
      priceHistoryJson: data.priceHistoryJson.present
          ? data.priceHistoryJson.value
          : this.priceHistoryJson,
      centeringData: data.centeringData.present
          ? data.centeringData.value
          : this.centeringData,
      imagePaths:
          data.imagePaths.present ? data.imagePaths.value : this.imagePaths,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardRow(')
          ..write('id: $id, ')
          ..write('catalogId: $catalogId, ')
          ..write('name: $name, ')
          ..write('cardNumber: $cardNumber, ')
          ..write('setName: $setName, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('grading: $grading, ')
          ..write('category: $category, ')
          ..write('gradeScore: $gradeScore, ')
          ..write('certNumber: $certNumber, ')
          ..write('buyPrice: $buyPrice, ')
          ..write('marketPrice: $marketPrice, ')
          ..write('buyDate: $buyDate, ')
          ..write('isCollected: $isCollected, ')
          ..write('volume: $volume, ')
          ..write('isWishlist: $isWishlist, ')
          ..write('targetPrice: $targetPrice, ')
          ..write('wishlistPriority: $wishlistPriority, ')
          ..write('priceHistoryJson: $priceHistoryJson, ')
          ..write('centeringData: $centeringData, ')
          ..write('imagePaths: $imagePaths, ')
          ..write('createdAt: $createdAt, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        catalogId,
        name,
        cardNumber,
        setName,
        imageUrl,
        grading,
        category,
        gradeScore,
        certNumber,
        buyPrice,
        marketPrice,
        buyDate,
        isCollected,
        volume,
        isWishlist,
        targetPrice,
        wishlistPriority,
        priceHistoryJson,
        centeringData,
        imagePaths,
        createdAt,
        isSynced
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardRow &&
          other.id == this.id &&
          other.catalogId == this.catalogId &&
          other.name == this.name &&
          other.cardNumber == this.cardNumber &&
          other.setName == this.setName &&
          other.imageUrl == this.imageUrl &&
          other.grading == this.grading &&
          other.category == this.category &&
          other.gradeScore == this.gradeScore &&
          other.certNumber == this.certNumber &&
          other.buyPrice == this.buyPrice &&
          other.marketPrice == this.marketPrice &&
          other.buyDate == this.buyDate &&
          other.isCollected == this.isCollected &&
          other.volume == this.volume &&
          other.isWishlist == this.isWishlist &&
          other.targetPrice == this.targetPrice &&
          other.wishlistPriority == this.wishlistPriority &&
          other.priceHistoryJson == this.priceHistoryJson &&
          other.centeringData == this.centeringData &&
          other.imagePaths == this.imagePaths &&
          other.createdAt == this.createdAt &&
          other.isSynced == this.isSynced);
}

class CardsCompanion extends UpdateCompanion<CardRow> {
  final Value<String> id;
  final Value<String> catalogId;
  final Value<String> name;
  final Value<String> cardNumber;
  final Value<String> setName;
  final Value<String> imageUrl;
  final Value<String> grading;
  final Value<String> category;
  final Value<double?> gradeScore;
  final Value<String?> certNumber;
  final Value<double> buyPrice;
  final Value<double> marketPrice;
  final Value<DateTime> buyDate;
  final Value<bool> isCollected;
  final Value<double> volume;
  final Value<bool> isWishlist;
  final Value<double?> targetPrice;
  final Value<int> wishlistPriority;
  final Value<String> priceHistoryJson;
  final Value<String?> centeringData;
  final Value<String> imagePaths;
  final Value<DateTime> createdAt;
  final Value<bool> isSynced;
  final Value<int> rowid;
  const CardsCompanion({
    this.id = const Value.absent(),
    this.catalogId = const Value.absent(),
    this.name = const Value.absent(),
    this.cardNumber = const Value.absent(),
    this.setName = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.grading = const Value.absent(),
    this.category = const Value.absent(),
    this.gradeScore = const Value.absent(),
    this.certNumber = const Value.absent(),
    this.buyPrice = const Value.absent(),
    this.marketPrice = const Value.absent(),
    this.buyDate = const Value.absent(),
    this.isCollected = const Value.absent(),
    this.volume = const Value.absent(),
    this.isWishlist = const Value.absent(),
    this.targetPrice = const Value.absent(),
    this.wishlistPriority = const Value.absent(),
    this.priceHistoryJson = const Value.absent(),
    this.centeringData = const Value.absent(),
    this.imagePaths = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CardsCompanion.insert({
    required String id,
    this.catalogId = const Value.absent(),
    required String name,
    this.cardNumber = const Value.absent(),
    this.setName = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.grading = const Value.absent(),
    this.category = const Value.absent(),
    this.gradeScore = const Value.absent(),
    this.certNumber = const Value.absent(),
    required double buyPrice,
    this.marketPrice = const Value.absent(),
    this.buyDate = const Value.absent(),
    this.isCollected = const Value.absent(),
    this.volume = const Value.absent(),
    this.isWishlist = const Value.absent(),
    this.targetPrice = const Value.absent(),
    this.wishlistPriority = const Value.absent(),
    this.priceHistoryJson = const Value.absent(),
    this.centeringData = const Value.absent(),
    this.imagePaths = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        buyPrice = Value(buyPrice);
  static Insertable<CardRow> custom({
    Expression<String>? id,
    Expression<String>? catalogId,
    Expression<String>? name,
    Expression<String>? cardNumber,
    Expression<String>? setName,
    Expression<String>? imageUrl,
    Expression<String>? grading,
    Expression<String>? category,
    Expression<double>? gradeScore,
    Expression<String>? certNumber,
    Expression<double>? buyPrice,
    Expression<double>? marketPrice,
    Expression<DateTime>? buyDate,
    Expression<bool>? isCollected,
    Expression<double>? volume,
    Expression<bool>? isWishlist,
    Expression<double>? targetPrice,
    Expression<int>? wishlistPriority,
    Expression<String>? priceHistoryJson,
    Expression<String>? centeringData,
    Expression<String>? imagePaths,
    Expression<DateTime>? createdAt,
    Expression<bool>? isSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (catalogId != null) 'catalog_id': catalogId,
      if (name != null) 'name': name,
      if (cardNumber != null) 'card_number': cardNumber,
      if (setName != null) 'set_name': setName,
      if (imageUrl != null) 'image_url': imageUrl,
      if (grading != null) 'grading': grading,
      if (category != null) 'category': category,
      if (gradeScore != null) 'grade_score': gradeScore,
      if (certNumber != null) 'cert_number': certNumber,
      if (buyPrice != null) 'buy_price': buyPrice,
      if (marketPrice != null) 'market_price': marketPrice,
      if (buyDate != null) 'buy_date': buyDate,
      if (isCollected != null) 'is_collected': isCollected,
      if (volume != null) 'volume': volume,
      if (isWishlist != null) 'is_wishlist': isWishlist,
      if (targetPrice != null) 'target_price': targetPrice,
      if (wishlistPriority != null) 'wishlist_priority': wishlistPriority,
      if (priceHistoryJson != null) 'price_history_json': priceHistoryJson,
      if (centeringData != null) 'centering_data': centeringData,
      if (imagePaths != null) 'image_paths': imagePaths,
      if (createdAt != null) 'created_at': createdAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CardsCompanion copyWith(
      {Value<String>? id,
      Value<String>? catalogId,
      Value<String>? name,
      Value<String>? cardNumber,
      Value<String>? setName,
      Value<String>? imageUrl,
      Value<String>? grading,
      Value<String>? category,
      Value<double?>? gradeScore,
      Value<String?>? certNumber,
      Value<double>? buyPrice,
      Value<double>? marketPrice,
      Value<DateTime>? buyDate,
      Value<bool>? isCollected,
      Value<double>? volume,
      Value<bool>? isWishlist,
      Value<double?>? targetPrice,
      Value<int>? wishlistPriority,
      Value<String>? priceHistoryJson,
      Value<String?>? centeringData,
      Value<String>? imagePaths,
      Value<DateTime>? createdAt,
      Value<bool>? isSynced,
      Value<int>? rowid}) {
    return CardsCompanion(
      id: id ?? this.id,
      catalogId: catalogId ?? this.catalogId,
      name: name ?? this.name,
      cardNumber: cardNumber ?? this.cardNumber,
      setName: setName ?? this.setName,
      imageUrl: imageUrl ?? this.imageUrl,
      grading: grading ?? this.grading,
      category: category ?? this.category,
      gradeScore: gradeScore ?? this.gradeScore,
      certNumber: certNumber ?? this.certNumber,
      buyPrice: buyPrice ?? this.buyPrice,
      marketPrice: marketPrice ?? this.marketPrice,
      buyDate: buyDate ?? this.buyDate,
      isCollected: isCollected ?? this.isCollected,
      volume: volume ?? this.volume,
      isWishlist: isWishlist ?? this.isWishlist,
      targetPrice: targetPrice ?? this.targetPrice,
      wishlistPriority: wishlistPriority ?? this.wishlistPriority,
      priceHistoryJson: priceHistoryJson ?? this.priceHistoryJson,
      centeringData: centeringData ?? this.centeringData,
      imagePaths: imagePaths ?? this.imagePaths,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (catalogId.present) {
      map['catalog_id'] = Variable<String>(catalogId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (cardNumber.present) {
      map['card_number'] = Variable<String>(cardNumber.value);
    }
    if (setName.present) {
      map['set_name'] = Variable<String>(setName.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (grading.present) {
      map['grading'] = Variable<String>(grading.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (gradeScore.present) {
      map['grade_score'] = Variable<double>(gradeScore.value);
    }
    if (certNumber.present) {
      map['cert_number'] = Variable<String>(certNumber.value);
    }
    if (buyPrice.present) {
      map['buy_price'] = Variable<double>(buyPrice.value);
    }
    if (marketPrice.present) {
      map['market_price'] = Variable<double>(marketPrice.value);
    }
    if (buyDate.present) {
      map['buy_date'] = Variable<DateTime>(buyDate.value);
    }
    if (isCollected.present) {
      map['is_collected'] = Variable<bool>(isCollected.value);
    }
    if (volume.present) {
      map['volume'] = Variable<double>(volume.value);
    }
    if (isWishlist.present) {
      map['is_wishlist'] = Variable<bool>(isWishlist.value);
    }
    if (targetPrice.present) {
      map['target_price'] = Variable<double>(targetPrice.value);
    }
    if (wishlistPriority.present) {
      map['wishlist_priority'] = Variable<int>(wishlistPriority.value);
    }
    if (priceHistoryJson.present) {
      map['price_history_json'] = Variable<String>(priceHistoryJson.value);
    }
    if (centeringData.present) {
      map['centering_data'] = Variable<String>(centeringData.value);
    }
    if (imagePaths.present) {
      map['image_paths'] = Variable<String>(imagePaths.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardsCompanion(')
          ..write('id: $id, ')
          ..write('catalogId: $catalogId, ')
          ..write('name: $name, ')
          ..write('cardNumber: $cardNumber, ')
          ..write('setName: $setName, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('grading: $grading, ')
          ..write('category: $category, ')
          ..write('gradeScore: $gradeScore, ')
          ..write('certNumber: $certNumber, ')
          ..write('buyPrice: $buyPrice, ')
          ..write('marketPrice: $marketPrice, ')
          ..write('buyDate: $buyDate, ')
          ..write('isCollected: $isCollected, ')
          ..write('volume: $volume, ')
          ..write('isWishlist: $isWishlist, ')
          ..write('targetPrice: $targetPrice, ')
          ..write('wishlistPriority: $wishlistPriority, ')
          ..write('priceHistoryJson: $priceHistoryJson, ')
          ..write('centeringData: $centeringData, ')
          ..write('imagePaths: $imagePaths, ')
          ..write('createdAt: $createdAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CatalogsTable extends Catalogs
    with TableInfo<$CatalogsTable, CatalogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatalogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _setNameMeta =
      const VerificationMeta('setName');
  @override
  late final GeneratedColumn<String> setName = GeneratedColumn<String>(
      'set_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _cardNumberMeta =
      const VerificationMeta('cardNumber');
  @override
  late final GeneratedColumn<String> cardNumber = GeneratedColumn<String>(
      'card_number', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _imageUrlMeta =
      const VerificationMeta('imageUrl');
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
      'image_url', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, category, setName, cardNumber, imageUrl];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catalogs';
  @override
  VerificationContext validateIntegrity(Insertable<CatalogRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('set_name')) {
      context.handle(_setNameMeta,
          setName.isAcceptableOrUnknown(data['set_name']!, _setNameMeta));
    }
    if (data.containsKey('card_number')) {
      context.handle(
          _cardNumberMeta,
          cardNumber.isAcceptableOrUnknown(
              data['card_number']!, _cardNumberMeta));
    }
    if (data.containsKey('image_url')) {
      context.handle(_imageUrlMeta,
          imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CatalogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      setName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}set_name'])!,
      cardNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}card_number'])!,
      imageUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_url'])!,
    );
  }

  @override
  $CatalogsTable createAlias(String alias) {
    return $CatalogsTable(attachedDatabase, alias);
  }
}

class CatalogRow extends DataClass implements Insertable<CatalogRow> {
  final String id;
  final String name;
  final String category;
  final String setName;
  final String cardNumber;
  final String imageUrl;
  const CatalogRow(
      {required this.id,
      required this.name,
      required this.category,
      required this.setName,
      required this.cardNumber,
      required this.imageUrl});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['category'] = Variable<String>(category);
    map['set_name'] = Variable<String>(setName);
    map['card_number'] = Variable<String>(cardNumber);
    map['image_url'] = Variable<String>(imageUrl);
    return map;
  }

  CatalogsCompanion toCompanion(bool nullToAbsent) {
    return CatalogsCompanion(
      id: Value(id),
      name: Value(name),
      category: Value(category),
      setName: Value(setName),
      cardNumber: Value(cardNumber),
      imageUrl: Value(imageUrl),
    );
  }

  factory CatalogRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String>(json['category']),
      setName: serializer.fromJson<String>(json['setName']),
      cardNumber: serializer.fromJson<String>(json['cardNumber']),
      imageUrl: serializer.fromJson<String>(json['imageUrl']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String>(category),
      'setName': serializer.toJson<String>(setName),
      'cardNumber': serializer.toJson<String>(cardNumber),
      'imageUrl': serializer.toJson<String>(imageUrl),
    };
  }

  CatalogRow copyWith(
          {String? id,
          String? name,
          String? category,
          String? setName,
          String? cardNumber,
          String? imageUrl}) =>
      CatalogRow(
        id: id ?? this.id,
        name: name ?? this.name,
        category: category ?? this.category,
        setName: setName ?? this.setName,
        cardNumber: cardNumber ?? this.cardNumber,
        imageUrl: imageUrl ?? this.imageUrl,
      );
  CatalogRow copyWithCompanion(CatalogsCompanion data) {
    return CatalogRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      setName: data.setName.present ? data.setName.value : this.setName,
      cardNumber:
          data.cardNumber.present ? data.cardNumber.value : this.cardNumber,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('setName: $setName, ')
          ..write('cardNumber: $cardNumber, ')
          ..write('imageUrl: $imageUrl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, category, setName, cardNumber, imageUrl);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.category == this.category &&
          other.setName == this.setName &&
          other.cardNumber == this.cardNumber &&
          other.imageUrl == this.imageUrl);
}

class CatalogsCompanion extends UpdateCompanion<CatalogRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> category;
  final Value<String> setName;
  final Value<String> cardNumber;
  final Value<String> imageUrl;
  final Value<int> rowid;
  const CatalogsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.setName = const Value.absent(),
    this.cardNumber = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CatalogsCompanion.insert({
    required String id,
    required String name,
    this.category = const Value.absent(),
    this.setName = const Value.absent(),
    this.cardNumber = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<CatalogRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? category,
    Expression<String>? setName,
    Expression<String>? cardNumber,
    Expression<String>? imageUrl,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (setName != null) 'set_name': setName,
      if (cardNumber != null) 'card_number': cardNumber,
      if (imageUrl != null) 'image_url': imageUrl,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CatalogsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? category,
      Value<String>? setName,
      Value<String>? cardNumber,
      Value<String>? imageUrl,
      Value<int>? rowid}) {
    return CatalogsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      setName: setName ?? this.setName,
      cardNumber: cardNumber ?? this.cardNumber,
      imageUrl: imageUrl ?? this.imageUrl,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (setName.present) {
      map['set_name'] = Variable<String>(setName.value);
    }
    if (cardNumber.present) {
      map['card_number'] = Variable<String>(cardNumber.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CatalogsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('setName: $setName, ')
          ..write('cardNumber: $cardNumber, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CardsTable cards = $CardsTable(this);
  late final $CatalogsTable catalogs = $CatalogsTable(this);
  late final Index idxCardsCategory = Index('idx_cards_category',
      'CREATE INDEX idx_cards_category ON cards (category)');
  late final Index idxCardsIsWishlist = Index('idx_cards_is_wishlist',
      'CREATE INDEX idx_cards_is_wishlist ON cards (is_wishlist)');
  late final Index idxCardsIsSynced = Index('idx_cards_is_synced',
      'CREATE INDEX idx_cards_is_synced ON cards (is_synced)');
  late final Index idxCardsSetName = Index('idx_cards_set_name',
      'CREATE INDEX idx_cards_set_name ON cards (set_name)');
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        cards,
        catalogs,
        idxCardsCategory,
        idxCardsIsWishlist,
        idxCardsIsSynced,
        idxCardsSetName
      ];
}

typedef $$CardsTableCreateCompanionBuilder = CardsCompanion Function({
  required String id,
  Value<String> catalogId,
  required String name,
  Value<String> cardNumber,
  Value<String> setName,
  Value<String> imageUrl,
  Value<String> grading,
  Value<String> category,
  Value<double?> gradeScore,
  Value<String?> certNumber,
  required double buyPrice,
  Value<double> marketPrice,
  Value<DateTime> buyDate,
  Value<bool> isCollected,
  Value<double> volume,
  Value<bool> isWishlist,
  Value<double?> targetPrice,
  Value<int> wishlistPriority,
  Value<String> priceHistoryJson,
  Value<String?> centeringData,
  Value<String> imagePaths,
  Value<DateTime> createdAt,
  Value<bool> isSynced,
  Value<int> rowid,
});
typedef $$CardsTableUpdateCompanionBuilder = CardsCompanion Function({
  Value<String> id,
  Value<String> catalogId,
  Value<String> name,
  Value<String> cardNumber,
  Value<String> setName,
  Value<String> imageUrl,
  Value<String> grading,
  Value<String> category,
  Value<double?> gradeScore,
  Value<String?> certNumber,
  Value<double> buyPrice,
  Value<double> marketPrice,
  Value<DateTime> buyDate,
  Value<bool> isCollected,
  Value<double> volume,
  Value<bool> isWishlist,
  Value<double?> targetPrice,
  Value<int> wishlistPriority,
  Value<String> priceHistoryJson,
  Value<String?> centeringData,
  Value<String> imagePaths,
  Value<DateTime> createdAt,
  Value<bool> isSynced,
  Value<int> rowid,
});

class $$CardsTableFilterComposer extends Composer<_$AppDatabase, $CardsTable> {
  $$CardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get catalogId => $composableBuilder(
      column: $table.catalogId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cardNumber => $composableBuilder(
      column: $table.cardNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get setName => $composableBuilder(
      column: $table.setName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get grading => $composableBuilder(
      column: $table.grading, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get gradeScore => $composableBuilder(
      column: $table.gradeScore, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get certNumber => $composableBuilder(
      column: $table.certNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get buyPrice => $composableBuilder(
      column: $table.buyPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get marketPrice => $composableBuilder(
      column: $table.marketPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get buyDate => $composableBuilder(
      column: $table.buyDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCollected => $composableBuilder(
      column: $table.isCollected, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get volume => $composableBuilder(
      column: $table.volume, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isWishlist => $composableBuilder(
      column: $table.isWishlist, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get targetPrice => $composableBuilder(
      column: $table.targetPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get wishlistPriority => $composableBuilder(
      column: $table.wishlistPriority,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get priceHistoryJson => $composableBuilder(
      column: $table.priceHistoryJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get centeringData => $composableBuilder(
      column: $table.centeringData, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imagePaths => $composableBuilder(
      column: $table.imagePaths, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));
}

class $$CardsTableOrderingComposer
    extends Composer<_$AppDatabase, $CardsTable> {
  $$CardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get catalogId => $composableBuilder(
      column: $table.catalogId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cardNumber => $composableBuilder(
      column: $table.cardNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get setName => $composableBuilder(
      column: $table.setName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get grading => $composableBuilder(
      column: $table.grading, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get gradeScore => $composableBuilder(
      column: $table.gradeScore, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get certNumber => $composableBuilder(
      column: $table.certNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get buyPrice => $composableBuilder(
      column: $table.buyPrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get marketPrice => $composableBuilder(
      column: $table.marketPrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get buyDate => $composableBuilder(
      column: $table.buyDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCollected => $composableBuilder(
      column: $table.isCollected, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get volume => $composableBuilder(
      column: $table.volume, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isWishlist => $composableBuilder(
      column: $table.isWishlist, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get targetPrice => $composableBuilder(
      column: $table.targetPrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get wishlistPriority => $composableBuilder(
      column: $table.wishlistPriority,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get priceHistoryJson => $composableBuilder(
      column: $table.priceHistoryJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get centeringData => $composableBuilder(
      column: $table.centeringData,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imagePaths => $composableBuilder(
      column: $table.imagePaths, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));
}

class $$CardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CardsTable> {
  $$CardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get catalogId =>
      $composableBuilder(column: $table.catalogId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get cardNumber => $composableBuilder(
      column: $table.cardNumber, builder: (column) => column);

  GeneratedColumn<String> get setName =>
      $composableBuilder(column: $table.setName, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get grading =>
      $composableBuilder(column: $table.grading, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get gradeScore => $composableBuilder(
      column: $table.gradeScore, builder: (column) => column);

  GeneratedColumn<String> get certNumber => $composableBuilder(
      column: $table.certNumber, builder: (column) => column);

  GeneratedColumn<double> get buyPrice =>
      $composableBuilder(column: $table.buyPrice, builder: (column) => column);

  GeneratedColumn<double> get marketPrice => $composableBuilder(
      column: $table.marketPrice, builder: (column) => column);

  GeneratedColumn<DateTime> get buyDate =>
      $composableBuilder(column: $table.buyDate, builder: (column) => column);

  GeneratedColumn<bool> get isCollected => $composableBuilder(
      column: $table.isCollected, builder: (column) => column);

  GeneratedColumn<double> get volume =>
      $composableBuilder(column: $table.volume, builder: (column) => column);

  GeneratedColumn<bool> get isWishlist => $composableBuilder(
      column: $table.isWishlist, builder: (column) => column);

  GeneratedColumn<double> get targetPrice => $composableBuilder(
      column: $table.targetPrice, builder: (column) => column);

  GeneratedColumn<int> get wishlistPriority => $composableBuilder(
      column: $table.wishlistPriority, builder: (column) => column);

  GeneratedColumn<String> get priceHistoryJson => $composableBuilder(
      column: $table.priceHistoryJson, builder: (column) => column);

  GeneratedColumn<String> get centeringData => $composableBuilder(
      column: $table.centeringData, builder: (column) => column);

  GeneratedColumn<String> get imagePaths => $composableBuilder(
      column: $table.imagePaths, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);
}

class $$CardsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CardsTable,
    CardRow,
    $$CardsTableFilterComposer,
    $$CardsTableOrderingComposer,
    $$CardsTableAnnotationComposer,
    $$CardsTableCreateCompanionBuilder,
    $$CardsTableUpdateCompanionBuilder,
    (CardRow, BaseReferences<_$AppDatabase, $CardsTable, CardRow>),
    CardRow,
    PrefetchHooks Function()> {
  $$CardsTableTableManager(_$AppDatabase db, $CardsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> catalogId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> cardNumber = const Value.absent(),
            Value<String> setName = const Value.absent(),
            Value<String> imageUrl = const Value.absent(),
            Value<String> grading = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<double?> gradeScore = const Value.absent(),
            Value<String?> certNumber = const Value.absent(),
            Value<double> buyPrice = const Value.absent(),
            Value<double> marketPrice = const Value.absent(),
            Value<DateTime> buyDate = const Value.absent(),
            Value<bool> isCollected = const Value.absent(),
            Value<double> volume = const Value.absent(),
            Value<bool> isWishlist = const Value.absent(),
            Value<double?> targetPrice = const Value.absent(),
            Value<int> wishlistPriority = const Value.absent(),
            Value<String> priceHistoryJson = const Value.absent(),
            Value<String?> centeringData = const Value.absent(),
            Value<String> imagePaths = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CardsCompanion(
            id: id,
            catalogId: catalogId,
            name: name,
            cardNumber: cardNumber,
            setName: setName,
            imageUrl: imageUrl,
            grading: grading,
            category: category,
            gradeScore: gradeScore,
            certNumber: certNumber,
            buyPrice: buyPrice,
            marketPrice: marketPrice,
            buyDate: buyDate,
            isCollected: isCollected,
            volume: volume,
            isWishlist: isWishlist,
            targetPrice: targetPrice,
            wishlistPriority: wishlistPriority,
            priceHistoryJson: priceHistoryJson,
            centeringData: centeringData,
            imagePaths: imagePaths,
            createdAt: createdAt,
            isSynced: isSynced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String> catalogId = const Value.absent(),
            required String name,
            Value<String> cardNumber = const Value.absent(),
            Value<String> setName = const Value.absent(),
            Value<String> imageUrl = const Value.absent(),
            Value<String> grading = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<double?> gradeScore = const Value.absent(),
            Value<String?> certNumber = const Value.absent(),
            required double buyPrice,
            Value<double> marketPrice = const Value.absent(),
            Value<DateTime> buyDate = const Value.absent(),
            Value<bool> isCollected = const Value.absent(),
            Value<double> volume = const Value.absent(),
            Value<bool> isWishlist = const Value.absent(),
            Value<double?> targetPrice = const Value.absent(),
            Value<int> wishlistPriority = const Value.absent(),
            Value<String> priceHistoryJson = const Value.absent(),
            Value<String?> centeringData = const Value.absent(),
            Value<String> imagePaths = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CardsCompanion.insert(
            id: id,
            catalogId: catalogId,
            name: name,
            cardNumber: cardNumber,
            setName: setName,
            imageUrl: imageUrl,
            grading: grading,
            category: category,
            gradeScore: gradeScore,
            certNumber: certNumber,
            buyPrice: buyPrice,
            marketPrice: marketPrice,
            buyDate: buyDate,
            isCollected: isCollected,
            volume: volume,
            isWishlist: isWishlist,
            targetPrice: targetPrice,
            wishlistPriority: wishlistPriority,
            priceHistoryJson: priceHistoryJson,
            centeringData: centeringData,
            imagePaths: imagePaths,
            createdAt: createdAt,
            isSynced: isSynced,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CardsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CardsTable,
    CardRow,
    $$CardsTableFilterComposer,
    $$CardsTableOrderingComposer,
    $$CardsTableAnnotationComposer,
    $$CardsTableCreateCompanionBuilder,
    $$CardsTableUpdateCompanionBuilder,
    (CardRow, BaseReferences<_$AppDatabase, $CardsTable, CardRow>),
    CardRow,
    PrefetchHooks Function()>;
typedef $$CatalogsTableCreateCompanionBuilder = CatalogsCompanion Function({
  required String id,
  required String name,
  Value<String> category,
  Value<String> setName,
  Value<String> cardNumber,
  Value<String> imageUrl,
  Value<int> rowid,
});
typedef $$CatalogsTableUpdateCompanionBuilder = CatalogsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> category,
  Value<String> setName,
  Value<String> cardNumber,
  Value<String> imageUrl,
  Value<int> rowid,
});

class $$CatalogsTableFilterComposer
    extends Composer<_$AppDatabase, $CatalogsTable> {
  $$CatalogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get setName => $composableBuilder(
      column: $table.setName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cardNumber => $composableBuilder(
      column: $table.cardNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnFilters(column));
}

class $$CatalogsTableOrderingComposer
    extends Composer<_$AppDatabase, $CatalogsTable> {
  $$CatalogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get setName => $composableBuilder(
      column: $table.setName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cardNumber => $composableBuilder(
      column: $table.cardNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnOrderings(column));
}

class $$CatalogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CatalogsTable> {
  $$CatalogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get setName =>
      $composableBuilder(column: $table.setName, builder: (column) => column);

  GeneratedColumn<String> get cardNumber => $composableBuilder(
      column: $table.cardNumber, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);
}

class $$CatalogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CatalogsTable,
    CatalogRow,
    $$CatalogsTableFilterComposer,
    $$CatalogsTableOrderingComposer,
    $$CatalogsTableAnnotationComposer,
    $$CatalogsTableCreateCompanionBuilder,
    $$CatalogsTableUpdateCompanionBuilder,
    (CatalogRow, BaseReferences<_$AppDatabase, $CatalogsTable, CatalogRow>),
    CatalogRow,
    PrefetchHooks Function()> {
  $$CatalogsTableTableManager(_$AppDatabase db, $CatalogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CatalogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CatalogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CatalogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> setName = const Value.absent(),
            Value<String> cardNumber = const Value.absent(),
            Value<String> imageUrl = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CatalogsCompanion(
            id: id,
            name: name,
            category: category,
            setName: setName,
            cardNumber: cardNumber,
            imageUrl: imageUrl,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String> category = const Value.absent(),
            Value<String> setName = const Value.absent(),
            Value<String> cardNumber = const Value.absent(),
            Value<String> imageUrl = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CatalogsCompanion.insert(
            id: id,
            name: name,
            category: category,
            setName: setName,
            cardNumber: cardNumber,
            imageUrl: imageUrl,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CatalogsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CatalogsTable,
    CatalogRow,
    $$CatalogsTableFilterComposer,
    $$CatalogsTableOrderingComposer,
    $$CatalogsTableAnnotationComposer,
    $$CatalogsTableCreateCompanionBuilder,
    $$CatalogsTableUpdateCompanionBuilder,
    (CatalogRow, BaseReferences<_$AppDatabase, $CatalogsTable, CatalogRow>),
    CatalogRow,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CardsTableTableManager get cards =>
      $$CardsTableTableManager(_db, _db.cards);
  $$CatalogsTableTableManager get catalogs =>
      $$CatalogsTableTableManager(_db, _db.catalogs);
}
