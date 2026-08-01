import 'dart:async';

import '../../data/datasources/card_local_datasource.dart';
import '../../data/models/card_item.dart';
import 'card_repository.dart';

/// 原生平台仓库实现（封装 Isar 持久化）。
class CardRepositoryImpl implements CardRepository {
  final CardLocalDatasource _ds = CardLocalDatasource();
  final StreamController<List<CardItem>> _ctrl =
      StreamController<List<CardItem>>.broadcast();

  @override
  Future<List<CardItem>> getAllCards() => _ds.getAllCards();

  @override
  Future<void> saveCard(CardItem card) async {
    await _ds.saveCard(card);
    _emit();
  }

  @override
  Future<void> updateCard(CardItem card) async {
    await _ds.saveCard(card);
    _emit();
  }

  @override
  Future<void> deleteCard(int id) async {
    await _ds.deleteCard(id);
    _emit();
  }

  @override
  Future<void> replaceAllCards(List<CardItem> cards) async {
    await _ds.replaceAllCards(cards);
    _emit();
  }

  @override
  Stream<List<CardItem>> watchAll() => _ctrl.stream;

  void _emit() {
    _ds.getAllCards().then(_ctrl.add);
  }
}
