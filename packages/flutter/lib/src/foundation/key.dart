// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' show hashValues;

import 'package:meta/meta.dart';

/// [Key]是[Widget]、[Element]和[SemanticsNode]的标识符
///
/// 新组件的key与当前组件的key相同时，才会用来更新关联的现有元素
///
/// 同一父级的元素的key必须唯一
///
/// [Key]的子类应该继承[LocalKey]或[GlobalKey]
///
/// 另请参阅[Widget.key]中的讨论
@immutable
abstract class Key {
  /// 用给定的[String]构建一个[ValueKey<String>]
  ///
  /// 这是创建key的最简单的方法
  const factory Key(String value) = ValueKey<String>;

  /// 默认构造方法，用于子类
  ///
  /// Useful so that subclasses can call us, because the [new Key] factory
  /// constructor shadows the implicit constructor.
  @protected
  const Key.empty();
}

/// 不是[GlobalKey]的key
///
/// 同一父级的元素的key必须唯一。相对的，在整个应用中[GlobalKey]必须唯一。
///
///
/// 另请参阅[Widget.key]中的讨论
abstract class LocalKey extends Key {
  /// Default constructor, used by subclasses.
  const LocalKey() : super.empty();
}

/// 使用特定类型的值来标识自身的key。
///
/// 一个[ValueKey<T>]与另一个[ValueKey<T>]只有在它们的值[operator==]时才会相等。
///
/// 继承此类可以创建即使值相同也不相等的key。如果子类是私有的，这会避免key值类型
/// 与其他来源的key值类型冲突，例如在相同作用域用key来回滚另一个组件，这是非常有
/// 用的。
///
/// 另请参阅[Widget.key]中的讨论
class ValueKey<T> extends LocalKey {
  /// 创建一个用给定值重载[operator==]的key
  const ValueKey(this.value);

  /// 重载[operator==]的值
  final T value;

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType)
      return false;
    final ValueKey<T> typedOther = other;
    return value == typedOther.value;
  }

  @override
  int get hashCode => hashValues(runtimeType, value);

  @override
  String toString() {
    final String valueString = T == String ? '<\'$value\'>' : '<$value>';
    // The crazy on the next line is a workaround for
    // https://github.com/dart-lang/sdk/issues/28548
    if (runtimeType == new _TypeLiteral<ValueKey<T>>().type)
      return '[$valueString]';
    return '[$T $valueString]';
  }
}

class _TypeLiteral<T> { Type get type => T; }
