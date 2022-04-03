# WeatherAPIExample

Example of a minimal Dancer2 application which requests weather data from the BOM and provides a filtered, sorted JSON array in the `response` key and an error message in an `error` key if the data cannot be retrieved.

Weather service: http://weather.johnhorner.info or https://weather.johnhorner.info

Notes:

1. The JSON from the BOM could not be accessed directly by a Perl user agent due to the use of Akamai CDN so I had to both:
   * provide a user-agent string which corresponded to a desktop browser
   * configure the Perl user-agent module to accept cookies.
2. This is currently against the BOM's Terms Of Service (see http://reg.bom.gov.au/weather-services/announcements/ “Website notification of change”
3 March 2021) so please note this has only been done for the sake of completing this task.
3. The specification said both “use only data from Sydney Olympic Park” and “provide a JSON array of stations” and those things appeared mutually exclusive so I provided a list of observations.
4. Although the `local_date_time_full` is probably guaranteed unique, it's a good principle for everything to have a GUID so I added a GUID to the listing which will be unique to each access, the GUID is not tied to any particular observation or request.
5. The specification listed only success and failure where failure meant failure to access that specific URL via HTTP but I added another case where the URL was accessed successfully, i.e. 200 HTTP response but the content wasn't JSON, as for instance the case where the URL might return HTML.
6. The application is running in Apache using a VirtualHost directive as in:

        <VirtualHost weather.johnhorner.info:80>
            ServerName weather.johnhorner.info
            DocumentRoot /var/www/johnhorner.info/weather/Weather/public
            <Location />
               SetHandler perl-script
               PerlResponseHandler Plack::Handler::Apache2
               PerlSetVar psgi_app /var/www/johnhorner.info/weather/Weather/bin/app.psgi
            </Location>
            ErrorLog  /var/log/apache2/weather-error.log
            CustomLog /var/log/apache2/weather-access_log common
        </VirtualHost>
   
   7. In the case of no observation having an `apparent_t` over 20 an empty array will be returned, not an error message.
