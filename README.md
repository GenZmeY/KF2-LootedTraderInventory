# Looted Trader Inventory

[![Steam Workshop](https://img.shields.io/static/v1?message=workshop&logo=steam&labelColor=gray&color=blue&logoColor=white&label=steam%20)](https://steamcommunity.com/sharedfiles/filedetails/?id=2864857909)
[![Steam Downloads](https://img.shields.io/steam/downloads/2864857909)](https://steamcommunity.com/sharedfiles/filedetails/?id=2864857909)
[![Steam Favorites](https://img.shields.io/steam/favorites/2864857909)](https://steamcommunity.com/sharedfiles/filedetails/?id=2864857909)
[![MegaLinter](https://github.com/GenZmeY/KF2-LootedTraderInventory/actions/workflows/mega-linter.yml/badge.svg?branch=master)](https://github.com/GenZmeY/KF2-LootedTraderInventory/actions/workflows/mega-linter.yml)
[![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/GenZmeY/KF2-LootedTraderInventory)](https://github.com/GenZmeY/KF2-LootedTraderInventory/tags)
[![GitHub](https://img.shields.io/github/license/GenZmeY/KF2-LootedTraderInventory)](LICENSE)

## Description
This is a heavily stripped down version of [CTI](https://github.com/GenZmeY/KF2-CustomTraderInventory) that only allows you to remove the trader's weapons, not add them. This only exists in hopes of being whitelisted.  

## Usage & Setup
[See steam workshop page](https://steamcommunity.com/sharedfiles/filedetails/?id=2864857909)

## Build
**Note:** If you want to build/test/brew/publish a mutator without git-bash and/or scripts, follow [these instructions](https://tripwireinteractive.atlassian.net/wiki/spaces/KF2SW/pages/26247172/KF2+Code+Modding+How-to) instead of what is described here.
1. Install [Killing Floor 2](https://store.steampowered.com/app/232090/Killing_Floor_2/), Killing Floor 2 - SDK and [git for windows](https://git-scm.com/download/win);
2. open git-bash and go to any folder where you want to store sources:  
`cd <ANY_FOLDER_YOU_WANT>`  
3. Clone this repository and go to the source folder:  
`git clone https://github.com/GenZmeY/KF2-LootedTraderInventory && cd KF2-LootedTraderInventory`
4. Download dependencies:  
`git submodule init && git submodule update`  
5. Compile:  
`./tools/builder -c`  
5. The compiled files will be here:  
`C:\Users\<USERNAME>\Documents\My Games\KillingFloor2\KFGame\Unpublished\BrewedPC\Script\`

## License
[![license](https://www.gnu.org/graphics/gplv3-with-text-136x68.png)](LICENSE)
