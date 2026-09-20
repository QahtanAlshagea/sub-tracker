import 'package:flutter/foundation.dart';

/// Represents the exhaustive Four View States for presentation screens and widgets.
///
/// Mandated by ARCHITECTURE.md §4 and codeguaid.md:
/// - [ViewStateLoading]: Asynchronous operation is underway.
/// - [ViewStateEmpty]: Operation returned no data; designed empty state with prompt.
/// - [ViewStateData]: Operation succeeded; renders populated content.
/// - [ViewStateError]: Operation failed; displays localized message and retry action.
sealed class ViewState<T> {
  const ViewState();

  bool get isLoading => this is ViewStateLoading<T>;
  bool get isEmpty => this is ViewStateEmpty<T>;
  bool get isData => this is ViewStateData<T>;
  bool get isError => this is ViewStateError<T>;

  T? get dataOrNull => switch (this) {
    ViewStateData<T>(data: final d) => d,
    _ => null,
  };
}

/// The loading view state.
class ViewStateLoading<T> extends ViewState<T> {
  const ViewStateLoading();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ViewStateLoading<T>;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// The empty view state.
class ViewStateEmpty<T> extends ViewState<T> {
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const ViewStateEmpty({
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ViewStateEmpty<T> &&
          title == other.title &&
          subtitle == other.subtitle &&
          actionLabel == other.actionLabel;

  @override
  int get hashCode => Object.hash(title, subtitle, actionLabel);
}

/// The data populated view state.
class ViewStateData<T> extends ViewState<T> {
  final T data;

  const ViewStateData(this.data);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ViewStateData<T> &&
          (data is List
              ? listEquals(data as List?, other.data as List?)
              : data == other.data);

  @override
  int get hashCode => data.hashCode;
}

/// The error view state with retry action.
class ViewStateError<T> extends ViewState<T> {
  final String message;
  final VoidCallback? onRetry;

  const ViewStateError({required this.message, this.onRetry});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ViewStateError<T> && message == other.message;

  @override
  int get hashCode => message.hashCode;
}
