package hxp;


import sys.io.Process;


class PlatformHelper {
	
	
	public static var hostArchitecture (get_hostArchitecture, null):Architecture;
	public static var hostPlatform (get_hostPlatform, null):Platform;
	
	private static var _hostArchitecture:Architecture;
	private static var _hostPlatform:Platform;
	
	
	private static function get_hostArchitecture ():Architecture {
		
		if (_hostArchitecture == null) {
			
			switch (hostPlatform) {
				
				case WINDOWS:
					
					var architecture = Sys.getEnv ("PROCESSOR_ARCHITEW6432");
					
					if (architecture != null && architecture.indexOf ("64") > -1) {
						
						_hostArchitecture = X64;
						
					} else {
						
						_hostArchitecture = X86;
						
					}
					
				case LINUX, MAC:
					
					#if nodejs
					
					switch (js.Node.process.arch) {
						
						case "arm":
							
							_hostArchitecture = Architecture.ARMV7;
						
						case "x64":
							
							_hostArchitecture = X64;
						
						default:
							
							_hostArchitecture = X86;
						
					}
					
					#else
					
					var process = new Process ("uname", [ "-m" ]);
					var output = process.stdout.readAll ().toString ();
					var error = process.stderr.readAll ().toString ();
					process.exitCode ();
					process.close ();
					
					if (output.indexOf ("armv6") > -1) {
						
						_hostArchitecture = Architecture.ARMV6;
						
					} else if (output.indexOf ("armv7") > -1) {
						
						_hostArchitecture = Architecture.ARMV7;
						
					} else if (output.indexOf ("64") > -1) {
						
						_hostArchitecture = X64;
						
					} else {
						
						_hostArchitecture = X86;
						
					}
					
					#end
					
				default:
					
					_hostArchitecture = Architecture.ARMV6;
				
			}
			
			Log.info ("", " - \x1b[1mDetected host architecture:\x1b[0m " + Std.string (_hostArchitecture).toUpperCase ());
			
		}
		
		return _hostArchitecture;
		
	}
	
	
	private static function get_hostPlatform ():Platform {
		
		if (_hostPlatform == null) {
			
			if (new EReg ("window", "i").match (Sys.systemName ())) {
				
				_hostPlatform = WINDOWS;
				
			} else if (new EReg ("linux", "i").match (Sys.systemName ())) {
				
				_hostPlatform = LINUX;
				
			} else if (new EReg ("mac", "i").match (Sys.systemName ())) {
				
				_hostPlatform = MAC;
				
			}
			
			Log.info ("", " - \x1b[1mDetected host platform:\x1b[0m " + Std.string (_hostPlatform).toUpperCase ());
			
		}
		
		return _hostPlatform;
		
	}
	
	
}


private enum Architecture {
	
	ARMV6;
	ARMV7;
	X86;
	X64;
	
}


@:enum private abstract Platform(String) from String to String {
	
	public var WINDOWS = "windows";
	public var MAC = "mac";
	public var LINUX = "linux";
	
}