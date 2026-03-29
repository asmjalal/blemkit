class PropertyConverters {
  static String _stripPrefix(String? value) {
    if (value == null) return '';
    if (value.contains('.')) {
      return value.split('.').last;
    }
    return value;
  }

  static String dartFontWeight(String? weight) {
    if (weight == null) return 'FontWeight.normal';
    final val = _stripPrefix(weight);
    switch (val) {
      case 'bold': return 'FontWeight.bold';
      case 'w100': return 'FontWeight.w100';
      case 'w200': return 'FontWeight.w200';
      case 'w300': return 'FontWeight.w300';
      case 'w400': return 'FontWeight.w400';
      case 'w500': return 'FontWeight.w500';
      case 'w600': return 'FontWeight.w600';
      case 'w700': return 'FontWeight.w700';
      case 'w800': return 'FontWeight.w800';
      case 'w900': return 'FontWeight.w900';
      default: return 'FontWeight.normal';
    }
  }

  static String dartTextAlign(String? align) {
    if (align == null) return 'TextAlign.start';
    final val = _stripPrefix(align);
    switch (val) {
      case 'left': return 'TextAlign.left';
      case 'center': return 'TextAlign.center';
      case 'right': return 'TextAlign.right';
      case 'justify': return 'TextAlign.justify';
      case 'end': return 'TextAlign.end';
      case 'start': return 'TextAlign.start';
      default: return 'TextAlign.start';
    }
  }

  static String dartTextDecoration(String? decoration) {
    if (decoration == null) return 'TextDecoration.none';
    final val = _stripPrefix(decoration);
    switch (val) {
      case 'underline': return 'TextDecoration.underline';
      case 'lineThrough': return 'TextDecoration.lineThrough';
      case 'overline': return 'TextDecoration.overline';
      default: return 'TextDecoration.none';
    }
  }

  static String dartTextOverflow(String? overflow) {
    if (overflow == null) return 'TextOverflow.clip';
    final val = _stripPrefix(overflow);
    switch (val) {
      case 'ellipsis': return 'TextOverflow.ellipsis';
      case 'fade': return 'TextOverflow.fade';
      case 'visible': return 'TextOverflow.visible';
      case 'clip': return 'TextOverflow.clip';
      default: return 'TextOverflow.clip';
    }
  }

  static String dartCrossAxisAlignment(String? align) {
    if (align == null) return 'CrossAxisAlignment.center';
    final val = _stripPrefix(align);
    switch (val) {
      case 'start': return 'CrossAxisAlignment.start';
      case 'center': return 'CrossAxisAlignment.center';
      case 'end': return 'CrossAxisAlignment.end';
      case 'stretch': return 'CrossAxisAlignment.stretch';
      case 'baseline': return 'CrossAxisAlignment.baseline';
      default: return 'CrossAxisAlignment.center';
    }
  }

  static String dartAlignment(String? alignment) {
    if (alignment == null) return 'Alignment.center';
    final val = _stripPrefix(alignment);
    switch (val) {
      case 'topLeft': return 'Alignment.topLeft';
      case 'topCenter': return 'Alignment.topCenter';
      case 'topRight': return 'Alignment.topRight';
      case 'centerLeft': return 'Alignment.centerLeft';
      case 'center': return 'Alignment.center';
      case 'centerRight': return 'Alignment.centerRight';
      case 'bottomLeft': return 'Alignment.bottomLeft';
      case 'bottomCenter': return 'Alignment.bottomCenter';
      case 'bottomRight': return 'Alignment.bottomRight';
      default: return 'Alignment.center';
    }
  }

  static String dartMainAxisAlignment(String? alignment) {
    if (alignment == null) return 'MainAxisAlignment.start';
    final val = _stripPrefix(alignment);
    switch (val) {
      case 'start': return 'MainAxisAlignment.start';
      case 'end': return 'MainAxisAlignment.end';
      case 'center': return 'MainAxisAlignment.center';
      case 'spaceBetween': return 'MainAxisAlignment.spaceBetween';
      case 'spaceAround': return 'MainAxisAlignment.spaceAround';
      case 'spaceEvenly': return 'MainAxisAlignment.spaceEvenly';
      default: return 'MainAxisAlignment.start';
    }
  }
}
 