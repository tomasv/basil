
Basil.watch_for(/(joke|juoksis|juokauj|juokin|juokites|juok|juokinga)/) {
  says [":DDDDD", "geras bajeris (y)", "lol", "tai ne juokinga, mano brolis taip zuvo"].sample
}

Basil.watch_for(/(\(rofl\)|:DD+)/) { says ["ko cia zvengiat?", "o kas cia juokingo?", ":S"].sample }
