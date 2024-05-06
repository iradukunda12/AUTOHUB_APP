import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../builders/ControlledStreamBuilder.dart';
import '../components/CustomProject.dart';

typedef SliverWrapListBuilder<A> = Widget Function(
    BuildContext context, int index);

enum SliverWrapEdgePosition {
  reserveBottom,
  normalTop,
  reserveTop,
  normalBottom
}

class SliverPaginationProgressController extends ChangeNotifier {
  bool showing = false;

  void showLoading() {
    if (!showing) {
      showing = true;
    }
    notifyListeners();
  }

  void hideLoading() {
    if (showing) {
      showing = false;
    }
    notifyListeners();
  }
}

class SliverPaginationProgressStyle {
  final double height;

  SliverPaginationProgressStyle({this.height = 100});
}

class CustomSliverWrapListBuilder extends StatefulWidget {
  final int? itemCount;
  final bool reverse;
  final bool injector;
  final SliverWrapListBuilder wrapListBuilder;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final int? paginateSize;
  final TextDirection? textDirection;
  final CrossAxisAlignment crossAxisAlignment;
  final VerticalDirection verticalDirection;
  final TextBaseline? textBaseline;
  final SliverPaginationProgressStyle? sliverPaginationProgressStyle;
  final SliverPaginationProgressController? sliverPaginationProgressController;
  final ValueChanged<SliverWrapEdgePosition>? wrapEdgePosition;
  final ValueChanged<ScrollDirection>? wrapScrollDirection;
  final RetryStreamListener? retryStreamListener;

  const CustomSliverWrapListBuilder({
    super.key,
    required this.itemCount,
    this.mainAxisSize = MainAxisSize.max,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.textBaseline,
    this.verticalDirection = VerticalDirection.down,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.textDirection,
    this.reverse = false,
    this.retryStreamListener,
    this.wrapEdgePosition,
    this.sliverPaginationProgressStyle,
    this.sliverPaginationProgressController,
    this.paginateSize,
    this.wrapScrollDirection,
    required this.wrapListBuilder,
    this.injector = true,
  });

  @override
  State<CustomSliverWrapListBuilder> createState() =>
      _CustomSliverWrapListBuilderState();
}

class _CustomSliverWrapListBuilderState
    extends State<CustomSliverWrapListBuilder> {
  List<Widget> builders = [];
  ScrollController scrollController = ScrollController();
  bool showingLoading = false;
  int paginate = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    setState(() {
      if (widget.paginateSize != null) {
        paginate += widget.paginateSize ?? 0;
      } else {
        paginate = widget.itemCount ?? 0;
      }
    });
    // getBuilders(paginate);
    scrollController.addListener(() {
      sendScrollDirection();
      checkEndOfList();
    });
    widget.sliverPaginationProgressController?.addListener(() {
      if (mounted) {
        setState(() {
          showingLoading =
              widget.sliverPaginationProgressController?.showing ?? false;
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant CustomSliverWrapListBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.paginateSize == null &&
        widget.itemCount != oldWidget.itemCount) {
      setState(() {
        paginate = widget.itemCount ?? 0;
      });
    }
  }

  void checkCanPaginate() {
    int itemSize = widget.itemCount ?? 0;
    if (widget.paginateSize != null && itemSize <= paginate && itemSize > 0) {
      if (((paginate + (widget.paginateSize ?? 0)) - itemSize) <=
          (widget.paginateSize ?? 0)) {
        if (timer == null) {
          setState(() {
            showingLoading = true;
          });
          timer = Timer(const Duration(milliseconds: 500), () {
            setState(() {
              showingLoading = false;
              paginate += widget.paginateSize ?? 0;
            });
            timer?.cancel();
            timer = null;
          });
        }
      }
    } else if (widget.paginateSize != null &&
        itemSize > paginate &&
        itemSize > 0) {
      if (timer == null) {
        setState(() {
          showingLoading = true;
        });
        timer = Timer(const Duration(milliseconds: 800), () {
          setState(() {
            showingLoading = false;
            paginate += widget.paginateSize ?? 0;
          });
          timer?.cancel();
          timer = null;
        });
      }
    }
  }

  void sendScrollDirection() {
    if (widget.wrapScrollDirection == null) {
      return;
    }
    widget.wrapScrollDirection!(scrollController.position.userScrollDirection);
  }

  void checkEndOfList() {
    if (widget.wrapEdgePosition == null) {
      return;
    }
    if (scrollController.position.pixels == 0) {
      if (widget.reverse) {
        checkCanPaginate();
        widget.wrapEdgePosition!(SliverWrapEdgePosition.reserveBottom);
      } else {
        widget.wrapEdgePosition!(SliverWrapEdgePosition.normalTop);
      }
    } else if (scrollController.position.atEdge &&
        scrollController.position.pixels != 0) {
      if (widget.reverse) {
        widget.wrapEdgePosition!(SliverWrapEdgePosition.reserveTop);
      } else {
        checkCanPaginate();
        widget.wrapEdgePosition!(SliverWrapEdgePosition.normalBottom);
      }
    }
  }

  Widget scrollViewIndicator() {
    return SizedBox(
      height: widget.sliverPaginationProgressStyle?.height,
      child: Center(child: progressBarWidget()),
    );
  }

  int getItemCount(int paginate) {
    int itemCount = widget.itemCount ?? 0;

    if (paginate > itemCount) {
      return itemCount;
    } else {
      return paginate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () {
        widget.retryStreamListener?.startRetrying();
        return widget.retryStreamListener?.refreshStreamController.stream
                .any((element) => element == RefreshState.refreshComplete) ??
            Future.value();
      },
      child: Column(
        children: [
          (widget.itemCount ?? 0) > 0 &&
                  showingLoading &&
                  widget.reverse &&
                  paginate != 0
              ? scrollViewIndicator()
              : const SizedBox(),
          Expanded(
            child: CustomScrollView(slivers: [
              widget.injector
                  ? SliverOverlapInjector(
                      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                          context))
                  : const SliverPadding(padding: EdgeInsets.zero),
              SliverList(
                  delegate: SliverChildBuilderDelegate(
                      childCount: getItemCount(paginate), (context, index) {
                int itemCount = getItemCount(paginate);
                return widget.reverse
                    ? widget.wrapListBuilder(context, itemCount - (index + 1))
                    : widget.wrapListBuilder(context, index);
              })),
            ]),
          ),
          (widget.itemCount ?? 0) > 0 &&
                  showingLoading &&
                  !widget.reverse &&
                  paginate != 0
              ? scrollViewIndicator()
              : const SizedBox(),
        ],
      ),
    );
  }
}
