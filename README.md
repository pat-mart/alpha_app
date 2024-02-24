An app for astronomers I developed over the summer. Its name comes from H-alpha, a red wavelength emitted by hydrogen that is often found in galaxies and nebulae. 

"Alpha" was copyright-protected, so I settled for Alpha for Astronomy. 

 Its purpose is to eliminate the need of fiddling with several different apps when planning astronomy. It integrates weather, observational, and planning software into one simple app. 

Alpha for Astronomy uses Flutter's Cupertino library extensively. Most of its backend is written in Dart, but I also created an API in Python (https://api.alpha-astro.com) for providing data regarding heliocentric objects. I used [pyephem](https://rhodesmill.org/pyephem/) within a Flask server and hosted it with AWS. 

I have since developed an open-source Dart package called [alpha_lib](https://pub.dev/packages/alpha_lib/versions) that allows for offline positional calculations of "fixed" (non-heliocentric) objects. 
