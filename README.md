# pjsipScript-iOS
A script that automatically generates PJSIP static libraries with SSL enabled and header files for iOS.

# References:
- Script is developed by referring PJSIP wiki for iOS (https://trac.pjsip.org/repos/wiki/Getting-Started/iPhone)

- build-libssl.sh script is taken from tutorial posted by pjsip for adding support for SSL
  http://x2on.de/2010/07/13/tutorial-iphone-app-with-compiled-openssl-1-0-0a-library/

- PJSIP lib integration with iOS project is referred from Xianwen's blog on “How to Make an iOS VoIP App With Pjsip” all 5 parts.
 http://www.xianwenchen.com/blog/2014/06/09/how-to-make-an-ios-voip-app-with-pjsip-part-1/

#  What is PJSIP? (Taken from http://www.pjsip.org/)
- PJSIP is a free and open source multimedia communication library written in C language implementing standard based protocols such as SIP, SDP, RTP, STUN, TURN, and ICE. It combines signaling protocol (SIP) with rich multimedia framework and NAT traversal functionality into high level API that is portable and suitable for almost any type of systems ranging from desktops, embedded systems, to mobile handsets.

# What is pjsipScript.sh?
- A script developed to ease building PJSIP libraries which can be used for developing iOS VoIP applications. There are ready scripts available for Android as well <a href="https://github.com/VoiSmart/pjsip-android-builder">here</a>.

# What this pjsipScript.sh do?
- Run build-libssl.sh, this script will download, compile and build OpenSSL for all available iOS device architectures (arm64, armv7 and armv7s) and iOS Simulator(i386 and x86_64) in order to add support for SSL this is must. It will generate a fat library for libcrypto.a and libssl.a placed at location “${working_dir}/lib/“. NOTE: If in case you don’t want SSL support, all you need to do is remove below line of code from pjsipScript.sh and run the script:
  1. ./build-libssl.sh (line no. 4)
  2. #define PJ_HAS_SSL_SOCK 1 (line no. 30)
- Checkout available source code from SVN ​https://svn.pjsip.org/repos/pjproject/trunk
- Create config_site.h with necessary line of code
- Build static libs for below target architectures:
  1. "arm64" "armv7" "armv7s" for device
  2. "i386" "x86_64" for simulator
- Generate a fat library for all different PJSIP static libs and place them under single folder at path ${working_dir}/trunk/lib. Even above mentioned ssl libs are copied under this very folder.
- Copy all required header files to one path i.e. ${working_dir}/trunk/pjsip-include

# How to use generated libs and include files?

Just run the script from terminal and sit back till it has completed its process/ execution. Now, we have folder name “lib” and “pjsip-include” in “${working_dir}/trunk”, lib folder contains all required static libs and pjsip-include folder contains all required header files. Later just follow below instructions to integrate generated libs to your project. These instructions are taken from Xianwen's blog which I’ve mentioned in references (How to Make an iOS VoIP App With Pjsip: Part 4)

- Simply drag those libxxx.a into the Frameworks group, and Xcode will automatically link them during compile. 
- To use the “pjsip-include”, copy this folder into the project directory. This way, our project can be successfully compiled regardless of the outer environment.
- In order to use pjsip, you need to update your Header Search Path of your project, so that it can reach all the header files contained in the “pjsip-include”
- Pjsip makes use of the iOS built in frameworks, to perform tasks like using the network, audio, etc. We need to link these required frameworks in order to run our app. Add these frameworks in the “Build Phases” tab
  1. AVFoundation.framework
  2. CFNetwork.framework
  3. AudioToolbox.framework
- Build your project and it should build successfully.

You can go through Xianwen's blog “How to Make an iOS VoIP App With Pjsip: Part 5” which explains very nicely on how to implement call handling using above integrated libs and header files.


# Thanks To

1. <a href="https://github.com/xianwen">Xianwen Chen</a> for providing easy to understand and very helpful articles on VoIP on <a href="http://xianwenchen.com/">Xianwen's blog</a>. 

2. http://www.pjsip.org/ for very informative documentation and tutorials for each platform.
