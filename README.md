    Kotobani - a game in which you create words to increase your points
    Copyright (C) 2014  sammy fischer (sammy@cosmic-bandito.com)

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.
   
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of 
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the  
    GNU General Public License for more details.                   
                                                                   
    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http:www.gnu.org/licenses/>.

ADDITIONAL LICENSES:
--------------------
The music, sound effects, rainbow and the flying yoga frog seen in the pause panel are from the wonderful assets from the game Glitch and licensed under Creative Common. You can find out more at http://www.glitch.com


GAMEPLAY:
---------
create words by clicking on adjacent letters. 
Diagonals are allowed, changing the direction is also allowed. Words must be at least 3 letters long. 
Double click on the last letter to validate.
Right click to clear the selection.
Press P to pause

Rainbow tiles multiplies the score of the final words. Each rainbow tile increase the multiplicator by 1, starting at 2. So a 3 letter word would bring 3 points, if it uses a rainbow tile, you will get 6 points (3x2),  if you can get 2 rainbow tiles in it, you will get 3x3 points, etc ...
Note that the longer the word the more points a tile brings anyway.

In case you think it is a clone of Popcap "Bookworm", you may congratulate yourself. It is indeed heavily influenced by Bookworm. The main differences apart from a few game mechanics, is that Kotobani is cross-platform, GPL v3-free, and should be able to cope with any language not based on ideogrammes. Japanese is a good example : Kotobani should work with Hiragana and Katakana charsets but will most probably not "work" with Kanji (although honestly I don't know how to split the japanese dictionaries)

Supported languages so far
* English
* German
* French

let me know if you want others. The Dictionaries are extracted from the aspell rws files and take time and some work to prepare.

CHANGELOG:
----------
1.1.1:
* fixed the tile disappearing bug
* added the choice to keep the intro music while playing instead of the Dirge

1.1.0:
* fixed the bugs found by Mole
* added visual sliding
* added bonus (rainbow) tiles 

1.0.0:
* game should be playable and (mostly bug free)

Beta_2:

* added a relaxed mode without time limit
* labeled the music and sound buttons according to their state
* added the game mode and difficulty to the parameters being saved in options.gd
* created the help panels
* fixed a bug with the flying frog


THINGS I'D LIKE TO ADD IN THE NEXT RELEASE:
-------------------------------------------
* a "tile falling" animation (at the moment it is not clear that the tiles are sliding down when a word has been found)
* random amount of lengthy (5+) words on grid rebuild, to make sure there are some ( although the chances that there are anyway right now is high. they can just be VERY difficult to find)