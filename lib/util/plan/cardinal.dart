sealed class Cardinal {

  static String getCardinal(double bearing){

    final Map<double, String> cardinalMap = {
      360: "N", 0: "N", 45: "NW", 90:
      "W", 135: "SW", 180: "S", 225: "SE",
      270: "W", 315: "NW"
    };

    if(cardinalMap.containsKey(bearing)){
      return cardinalMap[bearing]!;
    }

    if(isInRange(0, 90, bearing)){
      return bearing > 45 ? "ENE" : "NNE";
    }
    else if(isInRange(90, 180, bearing)){
      return bearing > 135 ? "ESE" : "SSE";
    }
    else if(isInRange(180, 270, bearing)){
      return bearing > 225 ? "WSW" : "SSW";
    }
    else if(isInRange(270, 360, bearing)){
      return bearing > 315 ? "NNW" : "WNW";
    }
    else {
      return "";
    }
  }

  static bool isInRange(double start, double end, double bearing){
    return (start < bearing && bearing < end);
  }
}