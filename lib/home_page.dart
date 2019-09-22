import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:test_cities/auth.dart';
import 'package:http/http.dart' as http;
import 'package:data_tables/data_tables.dart';

class City {
  City(this.name, this.longitude, this.latitude, this.country);
  final String name;
  final String longitude;
  final String latitude;
  final int country;
  bool selected = false;
}

class HomePage extends StatefulWidget {
  HomePage({this.auth, this.onSignOut});
  final BaseAuth auth;
  final VoidCallback onSignOut;

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int _sortColumnIndex;
  bool _sortAscending = true;
  List<City> _items = [];
  List<City> _cities = [];
  int _rowsOffset = 0;

  void _sort<T>(
      Comparable<T> getField(City d), int columnIndex, bool ascending) {
    _items.sort((City a, City b) {
      if (!ascending) {
        final City c = a;
        a = b;
        b = c;
      }
      final Comparable<T> aValue = getField(a);
      final Comparable<T> bValue = getField(b);
      return Comparable.compare(aValue, bValue);
    });
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    void _signOut() async {
      try {
        await this.widget.auth.signOut();
        this.widget.onSignOut();
      } catch (e) {
        print(e);
      }
    }

    http.get(
      'https://humanitarianbooking.external-api.org/v1/cities/',
      headers: {
        "x-api-key": "",
        "Authorization": "Token ",
        "Accept-Encoding": "identity"
      },
    ).then((result) {
      setState(() {
        var jsonBoj = json.decode(result.body);
        for (var i = 0; i < jsonBoj["results"].length; i++) {
          _cities.add(new City(
              jsonBoj["results"][i]["name"],
              jsonBoj["results"][i]["latitude"].toString(),
              jsonBoj["results"][i]["longtitude"].toString(),
              jsonBoj["results"][i]["country"]));
        }
        _items = _cities;
      });
    });

    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Cities'),
        actions: <Widget>[
          new FlatButton(
              onPressed: _signOut,
              child: new Text('Logout',
                  style: new TextStyle(fontSize: 17.0, color: Colors.white)))
        ],
      ),
      body: NativeDataTable.builder(
        rowsPerPage: _rowsPerPage,
        itemCount: _items?.length ?? 0,
        firstRowIndex: _rowsOffset,
        handleNext: () async {
          setState(() {
            _rowsOffset += _rowsPerPage;
          });

          await new Future.delayed(new Duration(seconds: 3));
        },
        handlePrevious: () {
          setState(() {
            _rowsOffset -= _rowsPerPage;
          });
        },
        itemBuilder: (int index) {
          final City city = _items[index];
          return DataRow.byIndex(
              index: index,
              selected: city.selected,
              onSelectChanged: (bool value) {
                if (city.selected != value) {
                  setState(() {
                    city.selected = value;
                  });
                }
              },
              cells: <DataCell>[
                DataCell(Text('${city.name}')),
                DataCell(Text('${city.latitude}')),
                DataCell(Text('${city.longitude}')),
                DataCell(Text('${city.country}')),
              ]);
        },
        header: const Text('Cities'),
        sortColumnIndex: _sortColumnIndex,
        sortAscending: _sortAscending,
        onRefresh: () async {
          await new Future.delayed(new Duration(seconds: 3));
          setState(() {
            _items = _cities;
          });
          return null;
        },
        onRowsPerPageChanged: (int value) {
          setState(() {
            _rowsPerPage = value;
          });
          print("New Rows: $value");
        },
        onSelectAll: (bool value) {
          for (var row in _items) {
            setState(() {
              row.selected = value;
            });
          }
        },
        rowCountApproximate: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {},
          ),
        ],
        selectedActions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              setState(() {
                for (var item in _items
                    ?.where((d) => d?.selected ?? false)
                    ?.toSet()
                    ?.toList()) {
                  _items.remove(item);
                }
              });
            },
          ),
        ],
        columns: <DataColumn>[
          DataColumn(
              label: const Text('name'),
              onSort: (int columnIndex, bool ascending) =>
                  _sort<String>((City d) => d.name, columnIndex, ascending)),
          DataColumn(
              label: const Text('latitude'),
              tooltip: 'latitude',
              numeric: false),
          DataColumn(label: const Text('longitude'), numeric: false),
          DataColumn(label: const Text('country'), numeric: true),
        ],
      ),
    );
  }
}
