# Notes on how to create a release #

## Versioning ##
Versioning must follow the x.x.x format, breaking changes should be a major release.  
When publishing a release, tag the release with the exact version number, the New Version check performs an exact string match against the latest tag and if different shows the prompt.  
Pre-releases are still shown as an available new version and should be used where caution is advised at installing this version.
To publish a beta release that you do not want to be shown as available to all users suffix beta to the tag, x.x.xbeta  

## Homebrew Cask ##
Only full releases (not pre or beta) should be pushed as a cask update.

TODO - document cask update
