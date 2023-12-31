An app for astronomers I developed over the summer. Its name comes from H-alpha, a red wavelength emitted by hydrogen that is often found in galaxies and nebulae. 

"Alpha" was copyright-protected, so I settled for Alpha for Astronomy. 

 Its purpose is to eliminate the need of fiddling with several different apps when planning astronomy. It integrates weather, observational, and planning software into one simple app. 

Alpha for Astronomy uses Flutter's Cupertino library extensively. I developed a specialized web API, https://api.alpha-astro.com, for providing data to this app. I used Flask and hosted it on Amazon using Elastic Beanstalk and Route 53.

My reasoning behind developing this API was that it would be easier to use AstroPy and PyEphem (in conjunction with Flask) than learn how to do astronomy math on my own. This was not entirely true, and development of the API delayed the projecy considerably. 

I have since developed an [open-source dart package](https://pub.dev/packages/alpha_lib/versions) that allows for offline positional calculations of "fixed" (non-heliocentric) objects. 
