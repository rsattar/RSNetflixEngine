ObjectiveFlickr
===============

ObjectiveFlickr is a useful library to communicate with the Netflix API.

Quick Start: How to get RSNetflixEngine and set it up
=====================================

1. Check out the code from github:

        git clone git://github.com/rsattar/RSNetflixEngine.git

2. Supply your own API key and shared secret and application name. You'll need to copy
   `APIKeys.h.template` as `APIKeys.h`, and fill in the three macros there. If you don't 
   have these yet, get one from Netflix at <http://developer.netflix.com/member/register> .

3. Build and run RSNetflixEngine. The XCode project is an executable iOS project that runs
   sample code and lets you try out the functionality of RSNetflixEngine.


How do you use it in your own project
=====================================

Unfortunately XCode isn't as awesome in cross-project development as other IDEs, so the
easiest way is to actually just copy the source code to your project.

1. Copy all the relevant source files into your own project. You need everything that 
   under the "Source" group within XCode. This includes RSNetflixEngine, RSURLLoader, 
   RSNetflixAPIContext, RSNetflixAPIRequest, etc. 
2. You also need to copy `APIKeys.h`, or have those macros defined somewhere (see 
   `APIKeys.h.template`).
3. Instantiate a `RSNetflixAPIContext` instance, and create an `RSNetflixEngine`
   instance (or `RSNetflixAPIRequest` if you want to do things a bit more low level,
   or aren't implemented in `RSNetflixEngine` yet.)
   
Making API Calls
================

RSNetflixEngine can be used in 2 different ways: 

* By creating `RSNetflixAPIRequest` objects for each API request. This requires you know
  more about the Netflix API, as this is just a fancy convenience class to build a
  query and send it to the Netflix api server.
* By creating an `RSNetflixEngine` instance, which provides more convenient methods for
  each type of API request. This class creates `RSNetflixAPIRequest` instances for you,
  by supplying properly formatted information.

Responses from Netflix in either approach can be handled using delegate callbacks, or
blocks.