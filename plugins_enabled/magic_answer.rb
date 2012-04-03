Basil.respond_to(/^ar (.*)/) {

  if @match_data[1] == 'jau penktadienis?'
    if Time.now.friday?
      replies "taip! (beer)"
    else
      replies "dar ne"
    end
  else
    answers = ["taip", "ne", "gal", "koks durnas klausimas, ilgai galvojai?",
                "kodel tu kankini mane?", "kodel tave tai domina?", "gal nori pasikalbeti apie tai?",
                "aisku", "nezinau", "nesakysiu"]
      replies answers.sample
    
  end

}.description = 'atsako i visus klausimus'
