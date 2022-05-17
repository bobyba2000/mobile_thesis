import 'package:flutter/material.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:mobile_v2/common/responsive_mixin.dart';

class LoadMoreWidget<T> extends StatelessWidget with ResponsiveMixin {
  final ItemBuilder<T> itemBuilder;
  final PageFuture<T>? loadMoreFunction;
  final PagewiseLoadController<T>? pageLoadController;
  final VoidCallback? pullToRefresh;
  final LoadingBuilder? loadingBuilder;
  final RetryBuilder? retryBuilder;
  final NoItemsFoundBuilder? noItemsFoundBuilder;
  final bool shrinkWrap;
  final int? crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final EdgeInsets padding;
  final double? itemExtent;
  final double? mainAxisExtent;
  final bool isList;
  final ScrollPhysics? physics;

  const LoadMoreWidget._({
    Key? key,
    required this.itemBuilder,
    this.loadMoreFunction,
    this.loadingBuilder,
    this.retryBuilder,
    this.noItemsFoundBuilder,
    this.isList = false,
    this.pullToRefresh,
    this.itemExtent,
    this.pageLoadController,
    this.crossAxisCount,
    double? mainAxisExtent,
    bool? shrinkWrap,
    double? mainAxisSpacing,
    double? crossAxisSpacing,
    EdgeInsets? padding,
    this.physics,
  })  : mainAxisSpacing = mainAxisSpacing ?? 32,
        crossAxisSpacing = crossAxisSpacing ?? 32,
        padding = padding ?? EdgeInsets.zero,
        shrinkWrap = shrinkWrap ?? false,
        mainAxisExtent = mainAxisExtent ?? 170,
        super(key: key);

  factory LoadMoreWidget.buildList(
          {required ItemBuilder<T> itemBuilder,
          PageFuture<T>? loadMoreFunction,
          PagewiseLoadController<T>? pageLoadController,
          VoidCallback? pullToRefresh,
          int? crossAxisCount,
          double? mainAxisSpacing,
          double? crossAxisSpacing,
          double? childAspectRatio,
          EdgeInsets? padding,
          double? itemExtent,
          bool? shrinkWrap,
          LoadingBuilder? loadingBuilder,
          RetryBuilder? retryBuilder,
          NoItemsFoundBuilder? noItemsFoundBuilder,
          ScrollPhysics? physics}) =>
      LoadMoreWidget._(
        itemBuilder: itemBuilder,
        loadingBuilder: loadingBuilder,
        loadMoreFunction: loadMoreFunction,
        retryBuilder: retryBuilder,
        noItemsFoundBuilder: noItemsFoundBuilder,
        pullToRefresh: pullToRefresh,
        itemExtent: itemExtent,
        padding: padding,
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        shrinkWrap: shrinkWrap,
        pageLoadController: pageLoadController,
        isList: true,
        physics: physics,
      );

  factory LoadMoreWidget.buildGrid(
          {required ItemBuilder<T> itemBuilder,
          PageFuture<T>? loadMoreFunction,
          PagewiseLoadController<T>? pageLoadController,
          VoidCallback? pullToRefresh,
          int? crossAxisCount,
          double? mainAxisSpacing,
          double? crossAxisSpacing,
          double? childAspectRatio,
          double? mainAxisExtent,
          EdgeInsets? padding,
          bool? shrinkWrap,
          LoadingBuilder? loadingBuilder,
          RetryBuilder? retryBuilder,
          NoItemsFoundBuilder? noItemsFoundBuilder,
          ScrollPhysics? physics}) =>
      LoadMoreWidget._(
        itemBuilder: itemBuilder,
        loadingBuilder: loadingBuilder,
        loadMoreFunction: loadMoreFunction,
        retryBuilder: retryBuilder,
        noItemsFoundBuilder: noItemsFoundBuilder,
        pullToRefresh: pullToRefresh,
        padding: padding,
        crossAxisCount: crossAxisCount,
        mainAxisExtent: mainAxisExtent,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        shrinkWrap: shrinkWrap,
        pageLoadController: pageLoadController,
        isList: false,
        physics: physics,
      );

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        pullToRefresh?.call();
      },
      child: isList ? _buildListView() : _buildGridView(),
    );
  }

  Widget _buildListView() {
    if (pageLoadController != null) {
      return PagewiseListView(
        key: key,
        shrinkWrap: shrinkWrap,
        itemExtent: itemExtent,
        padding: padding,
        itemBuilder: itemBuilder,
        noItemsFoundBuilder: noItemsFoundBuilder ??
            (context) => const Center(
                  child: Text('There is no data found.'),
                ),
        loadingBuilder: loadingBuilder,
        retryBuilder: retryBuilder,
        pageLoadController: pageLoadController,
        physics: physics,
      );
    } else {
      return PagewiseListView(
        key: key,
        shrinkWrap: shrinkWrap,
        pageSize: 12,
        itemExtent: itemExtent,
        padding: padding,
        itemBuilder: itemBuilder,
        pageFuture: loadMoreFunction,
        noItemsFoundBuilder: noItemsFoundBuilder ??
            (context) => const Center(
                  child: Text('There is no data found.'),
                ),
        loadingBuilder: loadingBuilder,
        retryBuilder: retryBuilder,
        physics: physics,
      );
    }
  }

  Widget _buildGridView() {
    if (pageLoadController != null) {
      return PagewiseGridView.count(
        key: key,
        crossAxisCount: crossAxisCount ?? crossAxisCountGridView,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        padding: padding,
        shrinkWrap: shrinkWrap,
        itemBuilder: itemBuilder,
        physics: physics,
        noItemsFoundBuilder: noItemsFoundBuilder ??
            (context) => const Center(
                  child: Text('There is no data found.'),
                ),
        retryBuilder: retryBuilder,
        pageLoadController: pageLoadController,
      );
    } else {
      return PagewiseGridView.count(
        key: key,
        pageSize: 12,
        crossAxisCount: crossAxisCount ?? crossAxisCountGridView,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        padding: padding,
        shrinkWrap: shrinkWrap,
        physics: physics,
        itemBuilder: itemBuilder,
        pageFuture: loadMoreFunction,
        noItemsFoundBuilder: noItemsFoundBuilder ??
            (context) => const Center(
                  child: Text('There is no data found.'),
                ),
        retryBuilder: retryBuilder,
      );
    }
  }
}
