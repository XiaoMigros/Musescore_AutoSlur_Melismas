//==============================================
//  Auto-slur Melismas
//
//  Copyleft (🄯) 2021 Michele Spagnolo
//  Modified 2023, XiaoMigros
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//==============================================

import QtQuick 2.0
import MuseScore 3.0

MuseScore {
	menuPath: "Plugins.Auto-Slur Melismas"
	description: qsTr("This plugin automatically add slurs to vocal melismas")
	version: "1.1"
	requiresScore: true

	Component.onCompleted : {
		if (mscoreMajorVersion >= 4) {
			title = qsTr("Auto-Slur Melismas") ;
			categoryCode = "notes-rests";
		} //if
	}//Component
	
	property int maxMelLength: 5 // Change this variable as needed!
	
	onRun: {
		var cursor = curScore.newCursor()
		var endTick = curScore.lastSegment.tick+1; // Get the tick to the end of the score
		
		for (var staff in curScore.nstaves) { // Cycle through all staves
			for (var voice = 0; voice < 4; voice++) {
				var melismaList = []
				var melismaLength = []
				cursor.staffIdx = staff
				cursor.voice = voice
				cursor.rewind(Cursor.SCORE_START)
				
				while (cursor.element) {
					if (cursor.element.lyrics.length > 0) { // if there's a syllable then:                         
						var melStart = cursor.tick
						var melLength = 0
						cursor.next()
						while (cursor.segment && cursor.element.type == Element.CHORD  && cursor.element.lyrics.length == 0 && melLength <= maxMelLength) {
							melLength += 1
							cursor.next()
						}
						melismaList.push(melStart) // When the melisma is recognized, it is saved in this array
						melismaLength.push(melLength)
						console.log(melStart)
						console.log(melLength)
					} else {
						console.log("no lyrics")
						cursor.next()
					}
				}

				for (var i in melismaList) { //now let's enter all the slurs on the current staff
					cursor.rewindToTick(melismaList[i]) //cursor goes to start of melismas
					curScore.selection.clear()
					curScore.selection.select(cursor.element.notes[0]) //select the note
					for (var j in melismaLength[i]) {
						cmd("select-next-chord") //extends the range selection as many times as the length of the melisma (extremely inefficient)
					}
					cmd("add-slur") // equivalent of the 's' keyboard shortcut
				}
			}//for voice
		}//for staff
	}//onRun
}//MuseScore
