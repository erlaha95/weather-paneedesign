/*:
  ![Playground icon](Icon.jpg)
 
 # Welcome...
 
 
 ## What we ask you to do:
 OpenWeatherMap is a service that allows you to obtain weather data for a specific location.
 
 We ask you to create an app that relay on this API, the app should allow you to run a search using an UISearchBar or an UITextField. The obtained data (weather, wind, temperature, and other data) should be displayed on an UITableView (or UICollectionView depending on the graphics to be used).
 
 Among the data that the API can return there are also the geographic coordinates of the location, you have to give the option to show the location on a MKMapView dropping a Pin.
 
 The project includes some graphic assets that will be useful for graphic design, see Assets.xcassets
 
 **Be aware of the auto-layout, you must take into account the different display sizes or future iPad alignment.**
 
** **
 
 # API
 
 **EndPoint:** http://api.openweathermap.org/data/2.5/weather
 
 
 **ApiKey:** 5abdd2e83c8121d39bdbb4854344dcff
 
 **Query Elements:**
 * **q**:   City for which the weather is requested. Ex: London, Rome, Los Angeles ...
 * **apikey**:   Access key to make the request.
 
  **Request sample:**
 http://api.openweathermap.org/data/2.5/weather?q=London&apikey=5abdd2e83c8121d39bdbb4854344dcff
 
 **Response sample:** See JsonExample.txt file
 
 ## ATTENTION: The url for the request is in HTTP
 
 ** **
 
 Concerning the graphic design, you will find below some examples from which to draw inspiration.
 
  # Nice-to-have
  
  Implement a CoreData structure that save HTTP requests as follows:
  
  * **Requests that will expire**: all requests about weather, wind, temperature will be saved on local db and next requests (before expire date - 1 hour) gets data from local 
  * **Requests persistent**: all requests about geographic coordinates of the location will be saved on local and next requests ever gets data from local
 
 Happy coding :)
 
 ![Example 1](Example-1.jpg)
 ![Example 2](Example-2.png)
 ![Example 3](Example-3.png)
 ![Example 4](Example-4.png)
 ![Example 5](Example-5.png)
 ![Example 6](Example-6.jpg)

 */
