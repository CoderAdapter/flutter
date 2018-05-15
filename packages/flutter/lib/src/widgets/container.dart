// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';

import 'basic.dart';
import 'framework.dart';
import 'image.dart';

/// A widget that paints a [Decoration] either before or after its child paints.
///
/// [Container] insets its child by the widths of the borders; this widget does
/// not.
///
/// Commonly used with [BoxDecoration].
///
/// ## Sample code
///
/// This sample shows a radial gradient that draws a moon on a night sky:
///
/// ```dart
/// new DecoratedBox(
///   decoration: new BoxDecoration(
///     gradient: new RadialGradient(
///       center: const Alignment(-0.5, -0.6),
///       radius: 0.15,
///       colors: <Color>[
///         const Color(0xFFEEEEEE),
///         const Color(0xFF111133),
///       ],
///       stops: <double>[0.9, 1.0],
///     ),
///   ),
/// )
/// ```
///
/// See also:
///
///  * [Ink], which paints a [Decoration] on a [Material], allowing
///    [InkResponse] and [InkWell] splashes to paint over them.
///  * [DecoratedBoxTransition], the version of this class that animates on the
///    [decoration] property.
///  * [Decoration], which you can extend to provide other effects with
///    [DecoratedBox].
///  * [CustomPaint], another way to draw custom effects from the widget layer.
class DecoratedBox extends SingleChildRenderObjectWidget {
  /// Creates a widget that paints a [Decoration].
  ///
  /// The [decoration] and [position] arguments must not be null. By default the
  /// decoration paints behind the child.
  const DecoratedBox({
    Key key,
    @required this.decoration,
    this.position: DecorationPosition.background,
    Widget child
  }) : assert(decoration != null),
       assert(position != null),
       super(key: key, child: child);

  /// What decoration to paint.
  ///
  /// Commonly a [BoxDecoration].
  final Decoration decoration;

  /// Whether to paint the box decoration behind or in front of the child.
  final DecorationPosition position;

  @override
  RenderDecoratedBox createRenderObject(BuildContext context) {
    return new RenderDecoratedBox(
      decoration: decoration,
      position: position,
      configuration: createLocalImageConfiguration(context),
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderDecoratedBox renderObject) {
    renderObject
      ..decoration = decoration
      ..configuration = createLocalImageConfiguration(context)
      ..position = position;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    String label;
    if (position != null) {
      switch (position) {
        case DecorationPosition.background:
          label = 'bg';
          break;
        case DecorationPosition.foreground:
          label = 'fg';
          break;
      }
    } else {
      label = 'decoration';
    }
    properties.add(new EnumProperty<DecorationPosition>('position', position, level: position != null ? DiagnosticLevel.hidden : DiagnosticLevel.info));
    properties.add(new DiagnosticsProperty<Decoration>(
      label,
      decoration,
      ifNull: 'no decoration',
      showName: decoration != null,
    ));
  }
}

/// 一个结合了常用的绘图组件、定位组件和尺寸组件的便捷组件。
///
/// 容器先用[padding]（会被[decoration]中定义的边框撑开）包裹子组件，然后对填
/// 充施加附加约束（如果`width`和`height`都不是null，也会以它们作为约束）。最后
/// 容器被[margin]包裹。
///
/// 绘图时，容器先实现变形[transform]，然后绘制[decoration]来填充区域，然后绘
/// 制子组件，最后绘制前景样式[foregroundDecoration]，并填充区域。
///
/// 无子组件的容器会尽可能的大，除非传入的约束是无界约束，而在此时它们会尽可能的
/// 小。有子组件的容器会适应子组件的尺寸。构造方法接收的`width`、`height`和
/// [constraints]参数会覆盖上述的情况。
///
/// ## 布局行为
///
/// _查看[BoxConstraints]来了解盒式布局模型。_
///
/// 既然[Container]结合了其它组件，那么[Container]的布局行为会与这些组件的布局行
/// 为有关，这便有些复杂。
///
/// 长话短说： [Container]试图依次进行对齐[alignment]、根据子组件[child]设置
/// 自身尺寸、设置`width`、`height`、按约束来尽可能的缩小尺寸以便适应父组件。
///
/// 详细内容：
///
/// 如果没有子组件，没有`height`，没有`width`，没有[constraints]，并且父组件提
/// 供无界约束，那么[Container]会试图尽可能的缩小尺寸。
///
/// 如果没有子组件，且没有[alignment]，但是有`height`、`width`或
/// [constraints]中的任何一个，那么[Container]会在结合这些约束与父级约束的前提
/// 下尽可能的缩小尺寸。
///
/// 如果没有子组件，没有`height`，没有`width`，没有[constraints]，并且没有
/// [alignment]，但是父组件提供了有界约束，那么[Container]会展开至适应父级组
/// 件提供的约束。
///
/// 如果没有[alignment]，并且父组件提供了无界约束，那么[Container]试图围绕子
/// 组件来调整尺寸。
///
/// 如果有[alignment]，并且父组件提供了有界约束，那么[Container]会展开至适应
/// 父组件，并在其内部按照[alignment]定位子组件。
///
/// 除上述之外，如果有一个[child]，但是没有`height`、`width`、[constraints]或
/// [alignment]，那么[Container]会把父组件约束传递给子组件，并且调整尺寸以适应
/// 子组件。
///
/// [margin]和[padding]属性也会影响布局，详情查看它们的文档内容（它们的作用只
/// 是对上述的补充）。[decoration]可以隐式地增加[padding]（例如，
/// [BoxDecoration]中的边框会对[padding]有影响）；查阅[Decoration.padding]。
///
/// ## 示例代码
///
/// 此例展示了48x48的绿色方块（把[Container]放在[Center]组件内，以防止父组件擅自
/// 决定它的尺寸），相邻组件用边距隔离。
///
/// ```dart
/// new Center(
///   child: new Container(
///     margin: const EdgeInsets.all(10.0),
///     color: const Color(0xFF00FF00),
///     width: 48.0,
///     height: 48.0,
///   ),
/// )
/// ```
///
/// 此例展示了如何一次使用[Container]的多个功能。
///[constraints]的高度被设置为字体大小加上充足的垂直净空高度，以便适应父组件水
///平尺寸时发生文字换行。[padding]用来确保内容与文字间的填充。`color`使盒子呈绿
///色。[alignment]使[child]在盒内居中。[foregroundDecoration]将九宫格图片叠
///加在文本上。最后，[transform]对整个装置进行轻微的旋转以完成效果。
///
/// ```dart
/// new Container(
///   constraints: new BoxConstraints.expand(
///     height: Theme.of(context).textTheme.display1.fontSize * 1.1 + 200.0,
///   ),
///   padding: const EdgeInsets.all(8.0),
///   color: Colors.teal.shade700,
///   alignment: Alignment.center,
///   child: new Text('Hello World', style: Theme.of(context).textTheme.display1.copyWith(color: Colors.white)),
///   foregroundDecoration: new BoxDecoration(
///     image: new DecorationImage(
///       image: new NetworkImage('https://www.example.com/images/frame.png'),
///       centerSlice: new Rect.fromLTRB(270.0, 180.0, 1360.0, 730.0),
///     ),
///   ),
///   transform: new Matrix4.rotationZ(0.1),
/// )
/// ```
///
/// 请参阅：
///
///  * [AnimatedContainer]，能够属性变化时平滑实现平滑动画的变体。
///  * [Border]，有一个大量使用[Container]的样例。
///  * [Ink]，在[Material]上绘制[Decoration]，允许[InkResponse]和[InkWell]在其上
///  表现飞溅效果。
///  * [布局组件目录](https://flutter.io/widgets/layout/).
class Container extends StatelessWidget {
  /// 创建了一个结合常用的绘图组件、定位组件和尺寸组件的组件。
  ///
  /// `height`和`width`值包含了padding
  ///
  /// `color`参数是`decoration: new BoxDecoration(color: color)`的简写形式，这意
  /// 味着你不能同时提供`color`和`decoration`参数。如果你想同时用它们，你可以把
  /// 颜色作为`color`参数传入`BoxDecoration`。
  Container({
    Key key,
    this.alignment,
    this.padding,
    Color color,
    Decoration decoration,
    this.foregroundDecoration,
    double width,
    double height,
    BoxConstraints constraints,
    this.margin,
    this.transform,
    this.child,
  }) : assert(margin == null || margin.isNonNegative),
       assert(padding == null || padding.isNonNegative),
       assert(decoration == null || decoration.debugAssertIsValid()),
       assert(constraints == null || constraints.debugAssertIsValid()),
       assert(color == null || decoration == null,
         'Cannot provide both a color and a decoration\n'
         'The color argument is just a shorthand for "decoration: new BoxDecoration(color: color)".'
       ),
       decoration = decoration ?? (color != null ? new BoxDecoration(color: color) : null),
       constraints =
        (width != null || height != null)
          ? constraints?.tighten(width: width, height: height)
            ?? new BoxConstraints.tightFor(width: width, height: height)
          : constraints,
       super(key: key);

  /// 容器包含的子组件[child]
  ///
  ///
  /// 如果是null，[constraints]是无界约束或者也是null，容器会展开以填充父组件
  /// 的可用空间，除非父组件提供一个无界约束，此时容器则尽可能的缩小尺寸。
  ///
  /// {@macro flutter.widgets.child}
  final Widget child;

  /// 在容器内对齐[child]
  ///
  /// 如果不是null，容器会展开以填充父组件，并根据给定的值在其内部定位子组件。如果传入无界约束，那么会缩小尺寸以适应子组件。
  ///
  /// 如果[child]是null，则忽略此属性
  ///
  /// 请参阅：
  ///
  ///  * [Alignment]，便捷指定[AlignmentGeometry]约束的类。
  ///  * [AlignmentDirectional]，类似[Alignment]，用于指定文本方向。
  final AlignmentGeometry alignment;

  /// 在[decoration]中的空白空间。[child]如果存在，子组件会被置于其中。
  ///
  /// 此填充会被追加进[decoration]所继承的填充；查阅[Decoration.padding]。
  final EdgeInsetsGeometry padding;

  /// 在[child]后面绘制的样式。
  ///
  /// 在构造方法中仅指定纯色的便捷方式：设置`color`参数而不是`decoration`参数。
  final Decoration decoration;

  /// 在[child]前面绘制的样式
  final Decoration foregroundDecoration;

  /// 施加在子组件的附加约束
  ///
  /// 构造方法的`height`和`width`参数与`constraints`参数组合设置此属性。
  ///
  /// [padding]在此约束中。
  final BoxConstraints constraints;

  /// 环绕[decoration]和[child]的空白空间。
  final EdgeInsetsGeometry margin;

  /// The transformation matrix to apply before painting the container.
  /// 绘制容器前的形变数列。
  final Matrix4 transform;

  EdgeInsetsGeometry get _paddingIncludingDecoration {
    if (decoration == null || decoration.padding == null)
      return padding;
    final EdgeInsetsGeometry decorationPadding = decoration.padding;
    if (padding == null)
      return decorationPadding;
    return padding.add(decorationPadding);
  }

  @override
  Widget build(BuildContext context) {
    Widget current = child;

    if (child == null && (constraints == null || !constraints.isTight)) {
      current = new LimitedBox(
        maxWidth: 0.0,
        maxHeight: 0.0,
        child: new ConstrainedBox(constraints: const BoxConstraints.expand())
      );
    }

    if (alignment != null)
      current = new Align(alignment: alignment, child: current);

    final EdgeInsetsGeometry effectivePadding = _paddingIncludingDecoration;
    if (effectivePadding != null)
      current = new Padding(padding: effectivePadding, child: current);

    if (decoration != null)
      current = new DecoratedBox(decoration: decoration, child: current);

    if (foregroundDecoration != null) {
      current = new DecoratedBox(
        decoration: foregroundDecoration,
        position: DecorationPosition.foreground,
        child: current
      );
    }

    if (constraints != null)
      current = new ConstrainedBox(constraints: constraints, child: current);

    if (margin != null)
      current = new Padding(padding: margin, child: current);

    if (transform != null)
      current = new Transform(transform: transform, child: current);

    return current;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(new DiagnosticsProperty<AlignmentGeometry>('alignment', alignment, showName: false, defaultValue: null));
    properties.add(new DiagnosticsProperty<EdgeInsetsGeometry>('padding', padding, defaultValue: null));
    properties.add(new DiagnosticsProperty<Decoration>('bg', decoration, defaultValue: null));
    properties.add(new DiagnosticsProperty<Decoration>('fg', foregroundDecoration, defaultValue: null));
    properties.add(new DiagnosticsProperty<BoxConstraints>('constraints', constraints, defaultValue: null));
    properties.add(new DiagnosticsProperty<EdgeInsetsGeometry>('margin', margin, defaultValue: null));
    properties.add(new ObjectFlagProperty<Matrix4>.has('transform', transform));
  }
}
