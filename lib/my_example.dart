import 'package:flutter/material.dart';
import 'package:flutter_dashboard/dashboard.dart';
import 'package:flutter_dashboard/mock.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MyExample extends StatefulWidget {
  @override
  _MyExampleState createState() => _MyExampleState();
}

class _MyExampleState extends State<MyExample> {
  _MyExampleState() : _crossAxisCount = 10;

  final int _crossAxisCount;
  int _selectedIndex = -1;
  AppBar editedAppBar;
  final AppBar normalAppBar = AppBar(title: Text("My Example"));

  AppBar appBar;

  changeSelected(int index) {
    setState(() {
      _selectedIndex = index;
      appBar = _selectedIndex >= 0 ? editedAppBar : normalAppBar;
    });
  }

  @override
  void initState() {
    super.initState();

    editedAppBar = AppBar(
      actions: <Widget>[
        IconButton(
          icon: Icon(FontAwesomeIcons.expand),
          onPressed: () {
            var selectedDashboard = dashboards[_selectedIndex];
            if (selectedDashboard.width + 1 <= _crossAxisCount) {
              setState(() {
                // if below max axis count
                dashboards[_selectedIndex].width++;
                dashboards[_selectedIndex].height++;
              });
            }
          },
        ),
        IconButton(
          icon: Icon(FontAwesomeIcons.compress),
          onPressed: () {
            var selectedDashboard = dashboards[_selectedIndex];
            if (selectedDashboard.width - 1 >= 0 &&
                selectedDashboard.height - 1 >= 0 &&
                selectedDashboard.height - 1 >= selectedDashboard.minHeight &&
                selectedDashboard.width - 1 >= selectedDashboard.minWidth) {
              setState(() {
                // if below max axis count
                dashboards[_selectedIndex].width--;
                dashboards[_selectedIndex].height--;
              });
            }
          },
        ),
        IconButton(
          icon: Icon(FontAwesomeIcons.trashAlt),
          onPressed: () {},
        ),
      ],
      leading: IconButton(
          icon: Icon(Icons.arrow_back), onPressed: () => changeSelected(-1)),
    );
    appBar = normalAppBar;
  }

  rearrange(int movedPosition, int droppedPosition) {
    print("movedPosition:$movedPosition droppedPosition:$droppedPosition");

    dashboards[movedPosition].position = droppedPosition;

    var newDashboard = <Dashboard>[];
    if (movedPosition > droppedPosition) {
      newDashboard.addAll(dashboards.getRange(0, droppedPosition));
      newDashboard.add(dashboards[movedPosition]);

      int newDashboardLength = newDashboard.length;
      for (int i = droppedPosition; i < movedPosition; i++) {
        dashboards[i].position = newDashboardLength++;
        newDashboard.add(dashboards[i]);
      }
      newDashboard.addAll(dashboards.getRange(movedPosition + 1, dashboards.length));
    } else {
      newDashboard.addAll(dashboards.getRange(0, movedPosition));

      int newDashboardLength = newDashboard.length;
      for (int i = movedPosition+1; i < droppedPosition+1; i++) {
        dashboards[i].position = newDashboardLength++;
        newDashboard.add(dashboards[i]);
      }
      newDashboard.add(dashboards[movedPosition]);

      newDashboard
          .addAll(dashboards.getRange(droppedPosition + 1, dashboards.length));
    }

    setState(() {
      dashboards = newDashboard;
      _selectedIndex = droppedPosition;
    });

    dashboards.forEach((d) => print(d.title));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: StaggeredGridView.countBuilder(
          crossAxisCount: _crossAxisCount,
          itemBuilder: (BuildContext context, int index) {
            // return a widget
            return TileItem(
              dashboards[index],
              isSelected: _selectedIndex == index,
              onSelected: changeSelected,
              positionChangedCallback: rearrange,
            );
          },
          staggeredTileBuilder: (int index) {
            // return a widget
            return StaggeredTile.count(
                dashboards[index].width, dashboards[index].height);
          },
          itemCount: dashboards.length,
        ),
      ),
    );
  }
}

typedef PositionChangedCallback = Function(
    int movedPosition, int droppedPosition);

class TileItem extends StatelessWidget {
  final Dashboard dashboard;
  final bool isSelected;
  final ValueChanged<int> onSelected;
  final PositionChangedCallback positionChangedCallback;

  TileItem(this.dashboard,
      {@required this.isSelected,
      @required this.onSelected,
      @required this.positionChangedCallback});

  @override
  Widget build(BuildContext context) {
    Widget content = DragTarget(
      builder: (context, candidateData, rejectedData) {
        return Stack(
          children: <Widget>[
            Card(
              margin: EdgeInsets.all(2.0),
              child: InkWell(
                child: Center(child: Text(dashboard.title)),
                onLongPress:
                    isSelected ? null : () => onSelected(dashboard.position),
              ),
              color: Colors.grey,
            ),
            isSelected
                ? Center(
                    child: Icon(Icons.open_with),
                  )
                : Container()
          ],
        );
      },
      onWillAccept: (data) {
        return true;
      },
      onAccept: (int position) {
        // change position
        positionChangedCallback(position, dashboard.position);
      },
    );

    if (isSelected) {
      return Draggable(
        childWhenDragging: Container(),
        feedback: Container(
          height: 30.0,
          width: 30.0,
          color: Colors.red,
        ),
        child: Container(
          child: content,
          decoration: BoxDecoration(border: Border.all(color: Colors.red)),
        ),
        data: dashboard.position,
      );
    }

    return content;
  }
}
