# GlobeTime

GlobeTime is a lightweight macOS menu bar app for checking local times around
the world. Search for a city, add it to your favorites, and keep the time zones
you use most one click away.

## Features

- Native macOS menu bar experience with a globe icon
- Live local time for favorite cities
- Searchable worldwide city database
- Add and remove favorites
- No Dock icon and no account required

## Requirements

- macOS 14 Sonoma or newer
- Xcode 15 or newer for development

## Build and Run

1. Clone this repository.
2. Open `Zonic.xcodeproj` in Xcode.
3. Select the `Zonic` scheme and the `My Mac` destination.
4. Press `Command-R`.

GlobeTime will appear as a globe in the menu bar. Click it to search for cities
and manage favorites. The built app is named `GlobeTime.app`.

## Data

Favorite cities are stored locally in the app's Application Support directory.
The included location database is sourced from Wikidata and compiled through
[countries-states-cities-database](https://github.com/dr5hn/countries-states-cities-database).

## Acknowledgments

GlobeTime is based on [Zonic](https://github.com/AbhayVAshokan/Zonic) by
Abhay V Ashokan. The original source code is available under the MIT License.
The included database is available under the ODC Open Database License 1.0.
See [LICENSE](LICENSE) for the complete notices.
