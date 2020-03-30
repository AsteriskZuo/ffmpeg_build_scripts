# ffmpeg_build_scripts
Build library for iOS and Android on macOS

## Brief description:
1. The script passed the MAC 10.14.6 test
2. Some environmental dependencies are not officially explained. For example: yasm, gas-preprocessor. Pl.
3. Version 5.31 of perl is not working properly. It is recommended to use 5.18
4. It is recommended to install brew version of ffmpeg 4.2.2 on your Mac
5. Please refer to the ffmpeg_directory_design file for the script directory design. Open it using the mindmaster.
6. Not include x264 etc. external library, but future must be support.

## Prerequisites:  
1. GNU bash (version 3.2.57 test success on macOS)                     
2. gas-preprocessor for iOS, which can be download by github           
3. yasm for iOS, which can be installed using brew                     
4. nasm for Android, which can be installed using brew                 
5. perl 5.18 (version 5.31 test fail) for gas-preprocessor.pl script   
6. python 2.7 for make_standalone_toolchain.py script                  
7. pkg-config for iOS and Android, which can be installed using brew   
8. curl for iOS and Android, which can be installed using brew         
9. tar for iOS and Android, which can be installed using brew    
## Reference
Url: http://yasm.tortall.net/    
Url: https://developer.android.com/ndk/guides/cmake    
Url: https://developer.android.com/ndk/guides/abis    
Url: https://developer.android.com/ndk/guides/other_build_systems    
Url: https://developer.android.com/ndk/guides/standalone_toolchain    
Url: https://gcc.gnu.org/onlinedocs/gcc/index.html     
Url: https://llvm.org/docs/genindex.html    
Url: https://blog.csdn.net/taiyang1987912/article/details/39551385     
Url: https://github.com/libav/gas-preprocessor              
Url: https://github.com/nldzsz/ffmpeg-build-scripts            
Url: https://github.com/kewlbear/FFmpeg-iOS-build-script         

