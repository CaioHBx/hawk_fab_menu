library hawk_fab_menu;

import 'package:flutter/material.dart';
import 'dart:ui' as ui;

/// Used to toggle the menu from other than the dedicated button.
class HawkFabMenuController {
  late Function toggleMenu;
  late Function closeMenu;
  HawkFabMenuController();
}

/// Wrapper that builds a FAB menu on top of [body] in a [Stack]
class HawkFabMenu extends StatefulWidget {
  final Widget body;
  final List<HawkFabMenuItem> items;
  final double blur;
  final AnimatedIconData? icon;
  final IconData? openIcon;
  final IconData? closeIcon;
  final Color? fabColor;
  final Color? iconColor;
  final Color? backgroundColor;
  final BorderSide buttonBorder;
  final String? heroTag;
  final HawkFabMenuController? hawkFabMenuController;
  HawkFabMenu({
    Key? key,
    required this.body,
    required this.items,
    this.blur = 5.0,
    this.icon,
    this.fabColor,
    this.iconColor,
    this.backgroundColor,
    this.buttonBorder = BorderSide.none,
    this.openIcon,
    this.closeIcon,
    this.heroTag,
    this.hawkFabMenuController,
  }) : super(key: key) {
    assert(items.isNotEmpty);
  }

  @override
  _HawkFabMenuState createState() => _HawkFabMenuState();
}

class _HawkFabMenuState extends State<HawkFabMenu> with TickerProviderStateMixin {
  /// To check if the menu is open
  bool _isOpen = false;

  /// The [Duration] for every animation
  final Duration _duration = const Duration(milliseconds: 500);

  /// Animation controller that animates the menu item
  late AnimationController _iconAnimationCtrl;

  /// Animation that animates the menu item
  late Animation<double> _iconAnimationTween;

  @override
  void initState() {
    super.initState();
    _iconAnimationCtrl = AnimationController(
      vsync: this,
      duration: _duration,
    );
    _iconAnimationTween = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(_iconAnimationCtrl);

    if (widget.hawkFabMenuController != null) {
      widget.hawkFabMenuController!.toggleMenu = _toggleMenu;
      widget.hawkFabMenuController!.closeMenu = _closeMenu;
    }
  }

  @override
  void dispose() {
    _iconAnimationCtrl.dispose();
    super.dispose();
  }

  /// Closes the menu if open and vice versa
  void _toggleMenu() {
    setState(() {
      _isOpen = !_isOpen;
    });
    if (_isOpen) {
      _iconAnimationCtrl.forward();
    } else {
      _iconAnimationCtrl.reverse();
    }
  }

  /// Closes the menu
  void _closeMenu() {
    setState(() {
      _isOpen = false;
    });
    _iconAnimationCtrl.reverse();
  }

  /// If the menu is open and the device's back button is pressed then menu gets closed instead of going back.
  Future<bool> _preventPopIfOpen() async {
    if (_isOpen) {
      _toggleMenu();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Stack(
        children: <Widget>[
          widget.body,
          _isOpen ? _buildBlurWidget() : Container(),
          _isOpen ? _buildMenuItemList() : Container(),
          _buildMenuButton(context),
        ],
      ),
      onWillPop: _preventPopIfOpen,
    );
  }

  /// Returns animated list of menu items
  Widget _buildMenuItemList() {
    return Positioned(
      bottom: 80,
      right: 15,
      child: ScaleTransition(
        scale: AnimationController(
          vsync: this,
          value: 0.7,
          duration: _duration,
        )..forward(),
        child: SizeTransition(
          axis: Axis.horizontal,
          sizeFactor: AnimationController(
            vsync: this,
            value: 0.5,
            duration: _duration,
          )..forward(),
          child: FadeTransition(
            opacity: AnimationController(
              vsync: this,
              value: 0.0,
              duration: _duration,
            )..forward(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: widget.items
                  .map<Widget>(
                    (item) => _MenuItemWidget(
                      item: item,
                      toggleMenu: _toggleMenu,
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the blur effect when the menu is opened
  Widget _buildBlurWidget() {
    return InkWell(
      onTap: _toggleMenu,
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(
          sigmaX: widget.blur,
          sigmaY: widget.blur,
        ),
        child: Container(
          color: widget.backgroundColor ?? Colors.black12,
        ),
      ),
    );
  }

  /// Builds the main floating action button of the menu to the bottom right
  /// On clicking of which the menu toggles
  Widget _buildMenuButton(BuildContext context) {
    late Widget iconWidget;
    if (widget.openIcon != null && widget.closeIcon != null) {
      iconWidget = Icon(
        _isOpen ? widget.closeIcon : widget.openIcon,
        color: widget.iconColor,
      );
    } else {
      iconWidget = AnimatedIcon(
        icon: widget.icon ?? AnimatedIcons.menu_close,
        progress: _iconAnimationTween,
        color: widget.iconColor,
      );
    }
    return Positioned(
      bottom: 10,
      right: 10,
      child: Container(
        height: 50,
        width: 50,
        margin: const EdgeInsets.only(right: 4),
        child: FloatingActionButton(
          tooltip: 'Menu',
          elevation: 0,
          child: iconWidget,
          heroTag: widget.heroTag ?? '_HawkFabMenu_$hashCode',
          backgroundColor: widget.fabColor ?? Theme.of(context).primaryColor,
          onPressed: _toggleMenu,
        ),
      ),
    );
  }
}

/// Builds widget for a single menu item
class _MenuItemWidget extends StatelessWidget {
  /// Contains details for a single menu item
  final HawkFabMenuItem item;

  /// A callback that toggles the menu
  final Function toggleMenu;

  const _MenuItemWidget({
    required this.item,
    required this.toggleMenu,
  });

  /// Closes the menu and calls the function for a particular menu item
  void onTap() {
    toggleMenu();
    item.ontap();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.enabled ? onTap : null,
      child: Column(
        children: [
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: item.enabled ? (item.labelBackgroundColor ?? Colors.white) : Theme.of(context).disabledColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  item.label,
                  style: TextStyle(color: item.labelColor ?? Colors.black87),
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              SizedBox(
                height: 50,
                width: 50,
                child: FloatingActionButton(
                  elevation: 0,
                  onPressed: item.enabled ? onTap : null,
                  heroTag: item.heroTag ?? '_MenuItemWidget_$hashCode',
                  child: item.icon,
                  backgroundColor: item.enabled ? (item.color ?? Theme.of(context).primaryColor) : Theme.of(context).disabledColor,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
        ],
      ),
    );
  }
}

/// Model for single menu item
class HawkFabMenuItem {
  /// Text label for for the menu item
  String label;

  /// Corresponding icon for the menu item
  Icon icon;

  /// Action that is to be performed on tapping the menu item
  Function ontap;

  /// Background color for icon
  Color? color;

  // Border for the floatActionButton
  BorderSide buttonBorder;

  /// Text color for label
  Color? labelColor;

  /// Background color for label
  Color? labelBackgroundColor;

  /// The tag to apply to the button's [Hero] widget.
  String? heroTag;

  bool enabled;

  HawkFabMenuItem({
    required this.label,
    required this.ontap,
    required this.icon,
    this.color,
    this.buttonBorder = BorderSide.none,
    this.labelBackgroundColor,
    this.labelColor,
    this.heroTag,
    this.enabled = true,
  });
}
