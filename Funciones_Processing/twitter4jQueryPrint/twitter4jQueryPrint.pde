/* 
Query a especific word from random array on twitter, then get massage print. Leslie Garcia - 2011 
Genera una busqueda utilizando palabras del string, genera un resultado y lo imprime. Leslie Garcia - 2011 */

import processing.serial.*;
import twitter4j.conf.*;
import twitter4j.internal.async.*;
import twitter4j.internal.org.json.*;
import twitter4j.internal.logging.*;
import twitter4j.http.*;
import twitter4j.api.*;
import twitter4j.util.*;
import twitter4j.internal.http.*;
import twitter4j.*;

// pegar informacion del dev.twitter.com
// explicacion de como configurar el dev http://dalab.ws/dtv2/2011/02/twitter4j-para-processing/
String consumer_key = "oKYNpI5s7";
String consumer_secret = "LZJb0fQT0xBNGN";
String oauth_token = "83521479-KqVM9N83waKm";
String oauth_token_secret = "mgERslIneJ9Y63frNW";

//string de terminos para busquedas
String[] positivo = {
  "optimismo","amor","claridad", "soñar"};
String[] negativo = {
  "soledad","confusion","vacio", "desesperacion"};
String[] positivoN = {
  "cinismo","sarcasmo","indiferencia"};
String[] negativoN = {
  "equilibrio","desapego","busqueda"};

// Valores aleatorios para la busqueda

int index1 = int(random(positivo.length));
int index2 = int(random(negativo.length));
int index3 = int(random(positivoN.length));
int index4 = int(random(negativoN.length));

// seleccion de array a partir de valores analogos


void setup(){

  // parametros generales de la pantalla
  //serial.begin(9600);
  size(800,100);
  PFont font = loadFont("ISOCPEUR-18.vlw");
  textFont(font, 19);


  // configuración del twitter4j
  Twitter twitter = new TwitterFactory().getOAuthAuthorizedInstance (
  consumer_key, consumer_secret, new AccessToken( oauth_token, oauth_token_secret) );
  try{

    Query query = new Query(negativo[index2]);//cargar el resultado de un string con random
    query.setGeoCode(new GeoLocation(50.0, 10.0), 1000.0, Query.KILOMETERS);
    query.setRpp(100);
    query.setLang("es"); // busqueda español
    QueryResult result = twitter.search(query);

    ArrayList tweets = (ArrayList) result.getTweets();

    for(int i = 0;i<tweets.size();i++){
      Tweet t = (Tweet) tweets.get(i);
      String user = t.getFromUser();
      String msg = t.getText();
      Date d = t.getCreatedAt();
      println("Tweet by" + user + "at" + d + ": " + msg);
      background(0);
      fill(255, 0, 0);
      text(msg, 10, 70);

    }
  }
  catch(TwitterException te){
    println("couldn't connect: " +te);

  }

}

void draw(){


}



