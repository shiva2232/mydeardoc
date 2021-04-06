import 'package:flutter/material.dart';

class Tile {
  List<ListTile> tile;
  Tile({List<ListTile> list, ListTile listTile}) {
    try {
      if (list == null && listTile == null) {
        this.tile = List.empty(growable: true);
      } else if (list != null) {
        this.tile.add(listTile);
      } else {
        this.tile.addAll(list);
      }
    } catch (e) {
      print("ERROR while creating tile.");
    }
  }

  addTile(ListTile listTile) {
    this.tile.add(listTile);
    return this.tile;
  }

  setTiles(List<ListTile> list) {
    this.tile.clear();
    try {
      this.tile.addAll(list);
      return true;
    } catch (error) {
      return false;
    }
  }

  List<ListTile> tiles() {
    return this.tile;
  }

  bool isEmpty() {
    return this.tile.isEmpty;
  }

  bool setEmpty() {
    this.tile.clear();
    return true;
  }

  addTiles(List<ListTile> list) {
    this.tile.addAll(list);
  }

  bool clone(List<ListTile> list) {
    try {
      this.tile.addAll(list);
      return true;
    } catch (error) {
      return false;
    }
  }
}
