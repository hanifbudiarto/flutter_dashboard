import 'package:flutter/material.dart';

class Dashboard {
  Dashboard(
      {@required this.width,
      @required this.height,
      @required this.title,
      @required this.position,
      @required this.models,
      @required this.minWidth,
      @required this.minHeight});

  /*
  * Create a dashboard according to this size
  * */
  int width;
  int height;

  final int minWidth;
  final int minHeight;

  // give this dashboard item a title
  final String title;

  // dashboard position in the grid
  int position;

  final List<WidgetModel> models;
}

class WidgetModel {
  WidgetModel(
      {@required this.id,
      @required this.name,
      @required this.icon,
      @required this.numOfParameters,
      @required this.acceptedParameters,
      @required this.resources,
      @required this.type});

  // widget model identifier
  final String id;
  final String name;
  final String icon;
  final int numOfParameters;
  final List<String> acceptedParameters;
  final List<Resource> resources;
  final String type;
}

class Resource {
  Resource({@required this.id, @required this.device, @required this.node});

  final int id;
  final String device;
  final String node;
}
