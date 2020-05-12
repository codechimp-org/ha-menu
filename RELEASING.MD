# Notes on how to create a release #

## Versioning ##
Versioning must follow the x.x.x format, breaking changes should be a major release.  
When publishing a release, tag the release with the exact version number, the New Version check performs an exact string match against the latest tag and if different shows the prompt.  

Pre-releases are only shown if you have the "Show beta version notifications" checked and should be used with caution.  
To publish a beta release that you do not want to be shown as available to all users suffix beta to the tag, x.x.xbeta  
You do not have to suffix the app version and if the beta release is suitable for a full release the tag can be edited to remove the beta suffix.

## Homebrew Cask ##
Full releases (not pre-releases) are automatically updated from the atom feed.  
