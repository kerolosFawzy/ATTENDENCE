class Location {
  String name ;
  double longitude ;
  double latitude;
  double radius ;
  Location({this.name , this.longitude , this.latitude , this.radius});

  toJson() {
    return {
      "name": name,
      "longitude": longitude,
      "latitude": latitude,
      "radius": radius,
    };
  }
}