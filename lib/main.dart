import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:weather_icons/weather_icons.dart';
import 'package:country_state_city/country_state_city.dart' as csc;


// put this shitty class in another file.
class Weather{

  static var weatherColor = const Color.fromRGBO(31, 28, 44, 1);
  static IconData weatherIcon = WeatherIcons.alien; 

  static String state = "Istanbul"; // default state
  static double temp = 0.0; // default temp

}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      title: 'weather-app',
      theme: ThemeData(

        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'GoofyWeather'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  // ignore: non_constant_identifier_names 
  final api_Key = ''; // you can get free api from openweathermap.org.

  String weatherText = "";

  void fetchData(double lat, double lon)async{

      final response = await http.get(Uri.parse('http://api.openweathermap.org/data/2.5/weather?lat=${lat}&lon=${lon}&APPID=${api_Key}&units=metric'));

      var json = jsonDecode(response.body) as Map<String, dynamic>;
      weatherText = json['weather'][0]['main'];
      
      Weather.temp = json['main']['temp'];

      // this is a mess

      setState(() {
        switch(weatherText){

          case "Clouds":
            Weather.weatherColor = const Color.fromRGBO(31, 28, 44, 1);
            Weather.weatherIcon = WeatherIcons.cloudy;
            break;

          case "Clear":
            Weather.weatherColor = const Color.fromRGBO(247, 183, 51, 1);
            Weather.weatherIcon = WeatherIcons.cloud;
            break;

          case "Rain":
              Weather.weatherColor = const Color.fromRGBO(0, 91, 234, 1);
              Weather.weatherIcon = WeatherIcons.rain;
            break;

          case "Thunderstorm":
              Weather.weatherColor = const Color.fromRGBO(97, 97, 97, 1);
              Weather.weatherIcon = WeatherIcons.thunderstorm;          
            break;

          case "Snow":
              Weather.weatherColor = const Color.fromARGB(255, 153, 153, 153);
              Weather.weatherIcon = WeatherIcons.snow;
            break;

          case "Drizzle":
              Weather.weatherColor = const Color.fromRGBO(7, 103, 133, 1);
              Weather.weatherIcon = WeatherIcons.raindrop;
            break;

          case "Haze":
              Weather.weatherColor = const Color.fromRGBO(102, 166, 255, 1);
              Weather.weatherIcon = WeatherIcons.day_haze;            
            break;                                                

          case "Mist":
              Weather.weatherColor = const Color.fromRGBO(60, 211, 173, 1);
              Weather.weatherIcon = WeatherIcons.day_haze;
            break; 

          default:
            Weather.weatherColor = Colors.white;  
            break;
        }
      });

  }


  void changeWeatherLoc(String state, String? lat, String? lon)async{
    
    Navigator.pop(context);
    Weather.state = state;

    if (lat != null && lon != null) {
      fetchData(double.parse(lat), double.parse(lon));
    }

  }

  void showCountries()async{

    final countries = await csc.getAllCountries();

    await showDialog(
      context: context,
      builder: (BuildContext context){
        return SimpleDialog(
          title: Text("choose a country"),
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 300,
              child: ListView.builder(
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(),  
                scrollDirection: Axis.vertical,                               
                itemBuilder: (ctx, index) {
                  
                  return SimpleDialogOption(
                    onPressed: () => showLocations(countries[index].isoCode),
                    child: Center(
                      child: Text(countries[index].name),
                    )
                  );
                },
                itemCount: countries.length

                )
            )
          ]
        );
      }
    );

  }


  void showLocations(String countryCode)async{

    Navigator.pop(context);

    final states = await csc.getStatesOfCountry(countryCode);

      await showDialog(
        context: context,
        builder: (BuildContext context){
          return SimpleDialog(
            title: Text("choose a state"),
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 300,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),  
                  scrollDirection: Axis.vertical,                               
                  itemBuilder: (ctx, index) {
                    
                    return SimpleDialogOption(
                      onPressed: () => changeWeatherLoc(states[index].name, states[index].latitude, states[index].longitude),
                      child: Center(
                        child: Text(states[index].name),
                      )
                    );
                  },
                  itemCount: states.length

                  )
              )
            ]
          );
        }
      );
  }

  @override
  void initState(){

    super.initState();
    fetchData(41,28); // 41-28 is coordinates of Istanbul (latitude, longitude)
  }
   

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Weather.weatherColor,
      body: Stack(

          children: <Widget>[
             
            // hamburger icon
              Positioned(
              top: 30,
              right: 15,
              
              child: IconButton(
                icon: const Icon(IconData(0xe3dc, fontFamily: 'MaterialIcons')),
                color: Colors.white,
                iconSize: 30, 
                onPressed: () { 
                    showCountries();
                 }
              ),
            ),

            // icon
            Positioned(
              top: 30,
              left: 0,
              right: 0,
              
              child: Icon(
                Weather.weatherIcon,
                color: Colors.white,
                size: 50,
              ),
            ),


            // weather text
            Positioned( 
              bottom: 60,
              left: 10,
              child: Text(
                weatherText,
                style: const TextStyle(fontSize: 50, color: Colors.white),
              ),
            ),

            // desc test
            Positioned( 
              bottom: 40,
              left: 10,
              child: Text(
                Weather.state,
                style: const TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),

            // temperature text
              Positioned(
              top: 80,
              left: 0,
              right: 0,
              child: Text(
                "${Weather.temp}°" ,textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 30, color: Colors.white),
              ),
            ),

          ],
        
      ),
    );
  }
}
