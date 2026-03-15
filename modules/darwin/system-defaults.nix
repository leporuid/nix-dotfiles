{ 
  system = {
    defaults = {
      loginwindow = {
        GuestEnabled = false;
      };

      finder = {
        AppleShowAllFiles = true; # hidden files
        AppleShowAllExtensions = true; # file extensions
        #_FXShowPosixPathInTitle = true; # title bar full path
        ShowPathbar = true; # breadcrumb nav at bottom
        ShowStatusBar = true; # file count & disk space
    	# This magic string makes it search the current folder by default
    	FXDefaultSearchScope = "SCcf";
    	# Use the column view by default (the obviously correct and best view)
    	FXPreferredViewStyle = "clmv";
      };
      
      dock.autohide = true;

      NSGlobalDomain = {
        ApplePressAndHoldEnabled = true;
    	AppleShowAllExtensions = true;
    	NSAutomaticCapitalizationEnabled = false;
    	NSAutomaticPeriodSubstitutionEnabled = false;
    	NSAutomaticSpellingCorrectionEnabled = false;
    	NSWindowShouldDragOnGesture = true;
    	InitialKeyRepeat = 15;
    	KeyRepeat = 2;
    	# Explicitly enabling media keys because the media keycodes themselves are
    	# used for some shortcuts
    	"com.apple.keyboard.fnState" = false;
      };
    };
  };
}